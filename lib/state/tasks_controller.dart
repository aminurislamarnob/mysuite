import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/storage/local_store.dart';
import '../core/utils/formatters.dart';
import '../models/task.dart';

class TasksController extends ChangeNotifier {
  TasksController(this._store) {
    _load();
  }

  static const _key = 'tasks';
  static const _uuid = Uuid();
  final LocalStore _store;
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<String> get projects {
    final set = {'Inbox', for (final t in _tasks) t.project};
    return set.toList();
  }

  void _load() {
    _tasks
      ..clear()
      ..addAll(_store.readList(_key).map(Task.fromJson));
  }

  Future<void> _persist() =>
      _store.writeList(_key, _tasks.map((t) => t.toJson()).toList());

  /// Sort: incomplete first, then by due date (nulls last), then priority.
  int _compare(Task a, Task b) {
    if (a.done != b.done) return a.done ? 1 : -1;
    final ad = a.due, bd = b.due;
    if (ad != null && bd != null && !Day.same(ad, bd)) {
      return ad.compareTo(bd);
    }
    if (ad == null && bd != null) return 1;
    if (ad != null && bd == null) return -1;
    return a.priority.index.compareTo(b.priority.index);
  }

  List<Task> sorted([Iterable<Task>? source]) {
    final list = [...(source ?? _tasks)];
    list.sort(_compare);
    return list;
  }

  List<Task> dueToday() =>
      sorted(_tasks.where((t) => !t.done && (t.isDueToday || t.isOverdue)));

  List<Task> upcoming() {
    final horizon = Day.today().add(const Duration(days: 7));
    return sorted(_tasks.where((t) =>
        !t.done &&
        t.due != null &&
        !Day.only(t.due!).isBefore(Day.today()) &&
        !Day.only(t.due!).isAfter(horizon)));
  }

  List<Task> inbox() =>
      sorted(_tasks.where((t) => !t.done && t.project == 'Inbox'));

  List<Task> byProject(String project) =>
      sorted(_tasks.where((t) => t.project == project));

  int get openCount => _tasks.where((t) => !t.done).length;
  int get dueTodayCount => dueToday().length;

  Task add(Task task) {
    _tasks.add(task);
    _persist();
    notifyListeners();
    return task;
  }

  /// Lightweight natural-language quick add: "Buy milk tomorrow #shopping !p1".
  Task quickAdd(String input) {
    var text = input.trim();
    var priority = Priority.p3;
    var project = 'Inbox';
    final tags = <String>[];
    DateTime? due;

    // Priority: !p1.. or !high/!urgent
    final pri = RegExp(r'!(p[1-4]|high|urgent|low)', caseSensitive: false)
        .firstMatch(text);
    if (pri != null) {
      final v = pri.group(1)!.toLowerCase();
      priority = switch (v) {
        'p1' || 'urgent' || 'high' => Priority.p1,
        'p2' => Priority.p2,
        'p4' || 'low' => Priority.p4,
        _ => Priority.p3,
      };
      text = text.replaceFirst(pri.group(0)!, '');
    }

    // Tags: #tag (first becomes project hint too)
    for (final m in RegExp(r'#(\w+)').allMatches(text)) {
      tags.add(m.group(1)!);
    }
    if (tags.isNotEmpty) project = tags.first;
    text = text.replaceAll(RegExp(r'#\w+'), '');

    // Dates: today / tomorrow / "in N days"
    final lower = text.toLowerCase();
    final today = Day.today();
    if (lower.contains('tomorrow')) {
      due = today.add(const Duration(days: 1));
      text = text.replaceAll(RegExp('tomorrow', caseSensitive: false), '');
    } else if (lower.contains('today')) {
      due = today;
      text = text.replaceAll(RegExp('today', caseSensitive: false), '');
    } else {
      final inDays = RegExp(r'in (\d+) days?', caseSensitive: false)
          .firstMatch(text);
      if (inDays != null) {
        due = today.add(Duration(days: int.parse(inDays.group(1)!)));
        text = text.replaceFirst(inDays.group(0)!, '');
      }
    }

    final title = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return add(Task(
      id: _uuid.v4(),
      title: title.isEmpty ? 'Untitled task' : title,
      due: due,
      priority: priority,
      project: project,
      tags: tags,
    ));
  }

  void update(Task task) {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i >= 0) _tasks[i] = task;
    _persist();
    notifyListeners();
  }

  void toggleDone(Task task) {
    task.done = !task.done;
    task.completedAt = task.done ? DateTime.now() : null;
    _persist();
    notifyListeners();
  }

  void delete(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _persist();
    notifyListeners();
  }

  void addFocusTime(String taskId, int seconds) {
    final t = _tasks.firstWhereOrNull((t) => t.id == taskId);
    if (t == null) return;
    t.focusedSeconds += seconds;
    _persist();
    notifyListeners();
  }

  double completionRateThisWeek() {
    final weekAgo = Day.today().subtract(const Duration(days: 6));
    final recent = _tasks.where((t) =>
        t.completedAt != null && !Day.only(t.completedAt!).isBefore(weekAgo));
    final created = _tasks.where((t) => true).length;
    if (created == 0) return 0;
    return recent.length / created;
  }
}

extension _FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
