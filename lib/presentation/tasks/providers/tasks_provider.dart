import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../repository/task_repository.dart';

final todayTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchToday();
});

final upcomingTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchUpcoming();
});

final inboxTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchInbox();
});

final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAll();
});

final openTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAll(includeCompleted: false);
});

final projectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(taskRepositoryProvider).watchProjects();
});

final subtasksProvider = StreamProvider.family<List<Task>, int>((
  ref,
  parentId,
) {
  return ref.watch(taskRepositoryProvider).watchSubtasks(parentId);
});

/// Tasks due in the visible month, keyed by day, for the calendar view.
final monthTasksProvider =
    StreamProvider.family<Map<DateTime, List<Task>>, DateTime>((ref, month) {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 1);
      return ref.watch(taskRepositoryProvider).watchInRange(start, end).map((
        tasks,
      ) {
        final grouped = <DateTime, List<Task>>{};
        for (final t in tasks) {
          if (t.dueDate == null) continue;
          grouped.putIfAbsent(Fmt.dateOnly(t.dueDate!), () => []).add(t);
        }
        return grouped;
      });
    });

/// Completion stats for the last [days] days, used by Insights.
final taskStatsProvider = FutureProvider.family<TaskStats, int>((
  ref,
  days,
) async {
  final repo = ref.watch(taskRepositoryProvider);
  final from = Fmt.dateOnly(DateTime.now()).subtract(Duration(days: days - 1));
  final to = Fmt.dateOnly(DateTime.now()).add(const Duration(days: 1));

  final completed = await repo.completedBetween(from, to);
  final open = await repo.watchAll(includeCompleted: false).first;
  final overdue = await repo.overdueCount();

  final perDay = <DateTime, int>{};
  for (final t in completed) {
    if (t.completedAt == null) continue;
    final day = Fmt.dateOnly(t.completedAt!);
    perDay[day] = (perDay[day] ?? 0) + 1;
  }

  return TaskStats(
    completed: completed.length,
    open: open.length,
    overdue: overdue,
    perDay: perDay,
  );
});

class TaskStats {
  final int completed;
  final int open;
  final int overdue;
  final Map<DateTime, int> perDay;

  const TaskStats({
    required this.completed,
    required this.open,
    required this.overdue,
    required this.perDay,
  });

  double get completionRate {
    final total = completed + open;
    return total == 0 ? 0 : completed / total;
  }
}
