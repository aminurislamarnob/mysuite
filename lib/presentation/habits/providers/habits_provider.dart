import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../repository/habit_repository.dart';
import '../utils/habit_stats.dart';

final habitsListProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchHabits();
});

final habitProvider = FutureProvider.family<Habit?, int>((ref, id) {
  return ref.watch(habitRepositoryProvider).getHabit(id);
});

final habitLogsProvider = StreamProvider.family<List<HabitLog>, int>((
  ref,
  habitId,
) {
  return ref.watch(habitRepositoryProvider).watchLogs(habitId);
});

/// Streak, completion rate and totals for one habit, recomputed whenever its
/// logs change.
final habitStatsProvider = StreamProvider.family<HabitStats, int>((
  ref,
  habitId,
) async* {
  final repo = ref.watch(habitRepositoryProvider);
  final habit = await repo.getHabit(habitId);
  if (habit == null) {
    yield HabitStats.empty;
    return;
  }
  await for (final logs in repo.watchLogs(habitId)) {
    yield HabitStats.compute(habit, logs);
  }
});

/// Today's log rows across every habit, used by the dashboard.
final todayHabitLogsProvider = StreamProvider<Map<int, double>>((ref) {
  return ref
      .watch(habitRepositoryProvider)
      .watchLogsForDay(DateTime.now())
      .map((logs) => {for (final l in logs) l.habitId: l.amount});
});

/// Total caffeine estimated for today across all habits that track it.
final caffeineTodayProvider = FutureProvider<double>((ref) async {
  final habits = await ref.watch(habitsListProvider.future);
  final today = await ref.watch(todayHabitLogsProvider.future);
  var total = 0.0;
  for (final h in habits) {
    final mg = h.caffeineMgPerUnit;
    if (mg == null) continue;
    total += mg * (today[h.id] ?? 0);
  }
  return total;
});

/// Estimated spend for today across habits with a per-unit cost.
final habitCostTodayProvider = FutureProvider<double>((ref) async {
  final habits = await ref.watch(habitsListProvider.future);
  final today = await ref.watch(todayHabitLogsProvider.future);
  var total = 0.0;
  for (final h in habits) {
    final cost = h.costPerUnit;
    if (cost == null) continue;
    total += cost * (today[h.id] ?? 0);
  }
  return total;
});
