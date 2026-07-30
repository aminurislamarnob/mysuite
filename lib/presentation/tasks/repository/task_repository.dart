import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';
import '../utils/recurrence.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(databaseProvider));
});

class TaskRepository {
  final AppDatabase _db;

  TaskRepository(this._db);

  /// Only top-level rows; subtasks are fetched per parent.
  SimpleSelectStatement<$TasksTable, Task> _root() =>
      _db.select(_db.tasks)..where((t) => t.parentTaskId.isNull());

  Stream<List<Task>> watchToday() {
    final end = Fmt.dateOnly(DateTime.now()).add(const Duration(days: 1));
    // "Today" includes anything overdue, which is what users actually expect.
    return (_root()
          ..where((t) => t.dueDate.isSmallerThanValue(end))
          ..orderBy([
            (t) => OrderingTerm(expression: t.isCompleted),
            (t) => OrderingTerm(expression: t.priority),
            (t) => OrderingTerm(expression: t.dueDate),
          ]))
        .watch();
  }

  Stream<List<Task>> watchUpcoming({int days = 7}) {
    final start = Fmt.dateOnly(DateTime.now()).add(const Duration(days: 1));
    final end = start.add(Duration(days: days));
    return (_root()
          ..where(
            (t) =>
                t.dueDate.isBiggerOrEqualValue(start) &
                t.dueDate.isSmallerThanValue(end) &
                t.isCompleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate),
            (t) => OrderingTerm(expression: t.priority),
          ]))
        .watch();
  }

  /// Quick captures: no due date and no project.
  Stream<List<Task>> watchInbox() {
    return (_root()
          ..where(
            (t) =>
                t.dueDate.isNull() &
                t.projectId.isNull() &
                t.isCompleted.equals(false),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Task>> watchAll({bool includeCompleted = true}) {
    final q = _root();
    if (!includeCompleted) q.where((t) => t.isCompleted.equals(false));
    q.orderBy([
      (t) => OrderingTerm(expression: t.sortOrder),
      (t) => OrderingTerm(expression: t.priority),
    ]);
    return q.watch();
  }

  Stream<List<Task>> watchByProject(int projectId) {
    return (_root()
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.isCompleted),
            (t) => OrderingTerm(expression: t.sortOrder),
          ]))
        .watch();
  }

  Stream<List<Task>> watchInRange(DateTime from, DateTime to) {
    return (_root()
          ..where(
            (t) =>
                t.dueDate.isBiggerOrEqualValue(from) &
                t.dueDate.isSmallerThanValue(to),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .watch();
  }

  Stream<List<Task>> watchSubtasks(int parentId) => (_db.select(
    _db.tasks,
  )..where((t) => t.parentTaskId.equals(parentId))).watch();

  Future<Task?> getTask(int id) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    bool hasDueTime = false,
    DateTime? reminderTime,
    int priority = 4,
    int? projectId,
    int? parentTaskId,
    String? recurrenceRule,
    int? estimateMinutes,
  }) {
    return _db
        .into(_db.tasks)
        .insert(
          TasksCompanion.insert(
            title: title,
            description: Value(description),
            dueDate: Value(dueDate),
            hasDueTime: Value(hasDueTime),
            reminderTime: Value(reminderTime),
            priority: Value(priority),
            projectId: Value(projectId),
            parentTaskId: Value(parentTaskId),
            recurrenceRule: Value(recurrenceRule),
            estimateMinutes: Value(estimateMinutes),
          ),
        );
  }

  Future<void> updateTask(
    int id, {
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? hasDueTime,
    DateTime? reminderTime,
    bool clearReminder = false,
    int? priority,
    int? projectId,
    bool clearProject = false,
    String? recurrenceRule,
    bool clearRecurrence = false,
    int? boardStatus,
    int? estimateMinutes,
    int? sortOrder,
  }) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        title: title == null ? const Value.absent() : Value(title),
        description: description == null
            ? const Value.absent()
            : Value(description),
        dueDate: clearDueDate
            ? const Value(null)
            : (dueDate == null ? const Value.absent() : Value(dueDate)),
        hasDueTime: hasDueTime == null
            ? const Value.absent()
            : Value(hasDueTime),
        reminderTime: clearReminder
            ? const Value(null)
            : (reminderTime == null
                  ? const Value.absent()
                  : Value(reminderTime)),
        priority: priority == null ? const Value.absent() : Value(priority),
        projectId: clearProject
            ? const Value(null)
            : (projectId == null ? const Value.absent() : Value(projectId)),
        recurrenceRule: clearRecurrence
            ? const Value(null)
            : (recurrenceRule == null
                  ? const Value.absent()
                  : Value(recurrenceRule)),
        boardStatus: boardStatus == null
            ? const Value.absent()
            : Value(boardStatus),
        estimateMinutes: estimateMinutes == null
            ? const Value.absent()
            : Value(estimateMinutes),
        sortOrder: sortOrder == null ? const Value.absent() : Value(sortOrder),
      ),
    );
  }

  /// Completing a recurring task closes this occurrence and schedules the next.
  ///
  /// Returns the id of the newly spawned occurrence, when one was created.
  Future<int?> setCompleted(int id, bool completed) async {
    final task = await getTask(id);
    if (task == null) return null;

    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isCompleted: Value(completed),
        completedAt: Value(completed ? DateTime.now() : null),
        boardStatus: Value(completed ? 2 : task.boardStatus),
      ),
    );

    if (!completed || task.recurrenceRule == null) return null;

    final next = Recurrence.nextOccurrence(
      task.recurrenceRule!,
      task.dueDate ?? DateTime.now(),
    );
    if (next == null) return null;

    return createTask(
      title: task.title,
      description: task.description,
      dueDate: next,
      hasDueTime: task.hasDueTime,
      reminderTime: task.reminderTime == null
          ? null
          // Preserve the lead time between the reminder and the due date.
          : next.subtract(task.dueDate!.difference(task.reminderTime!)),
      priority: task.priority,
      projectId: task.projectId,
      recurrenceRule: task.recurrenceRule,
      estimateMinutes: task.estimateMinutes,
    );
  }

  /// Adds focus minutes to a task after a Pomodoro session ends.
  Future<void> addLoggedMinutes(int taskId, int minutes) async {
    final task = await getTask(taskId);
    if (task == null) return;
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(loggedMinutes: Value(task.loggedMinutes + minutes)),
    );
  }

  /// Deletes a task along with any subtasks hanging off it.
  Future<void> deleteTask(int id) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.tasks,
      )..where((t) => t.parentTaskId.equals(id))).go();
      await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Persists a drag-and-drop reorder in one batch.
  Future<void> reorder(List<int> orderedIds) async {
    await _db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          _db.tasks,
          TasksCompanion(sortOrder: Value(i)),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  Future<List<Task>> tasksWithReminders() =>
      (_db.select(_db.tasks)..where(
            (t) => t.reminderTime.isNotNull() & t.isCompleted.equals(false),
          ))
          .get();

  // --- Projects ------------------------------------------------------------

  Stream<List<Project>> watchProjects() => (_db.select(
    _db.projects,
  )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();

  Future<int> createProject(String name, int color, String icon) => _db
      .into(_db.projects)
      .insert(
        ProjectsCompanion.insert(
          name: name,
          color: Value(color),
          icon: Value(icon),
        ),
      );

  Future<void> deleteProject(int id) =>
      (_db.delete(_db.projects)..where((t) => t.id.equals(id))).go();

  // --- Tags ----------------------------------------------------------------

  Future<void> setTaskTags(int taskId, List<String> names) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.taskTags,
      )..where((t) => t.taskId.equals(taskId))).go();
      for (final name
          in names.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet()) {
        final existing = await (_db.select(
          _db.tags,
        )..where((t) => t.name.equals(name))).getSingleOrNull();
        final tagId =
            existing?.id ??
            await _db.into(_db.tags).insert(TagsCompanion.insert(name: name));
        await _db
            .into(_db.taskTags)
            .insert(
              TaskTagsCompanion.insert(taskId: taskId, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  Future<List<Tag>> tagsForTask(int taskId) async {
    final rows = await (_db.select(_db.tags).join([
      innerJoin(_db.taskTags, _db.taskTags.tagId.equalsExp(_db.tags.id)),
    ])..where(_db.taskTags.taskId.equals(taskId))).get();
    return rows.map((r) => r.readTable(_db.tags)).toList();
  }

  // --- Stats ---------------------------------------------------------------

  Future<List<Task>> completedBetween(DateTime from, DateTime to) =>
      (_db.select(_db.tasks)..where(
            (t) =>
                t.completedAt.isBiggerOrEqualValue(from) &
                t.completedAt.isSmallerThanValue(to),
          ))
          .get();

  Future<int> overdueCount() async {
    final rows =
        await (_db.select(_db.tasks)..where(
              (t) =>
                  t.dueDate.isSmallerThanValue(DateTime.now()) &
                  t.isCompleted.equals(false),
            ))
            .get();
    return rows.length;
  }
}
