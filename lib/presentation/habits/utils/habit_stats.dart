import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';

/// Streaks, completion rates and derived estimates for a single habit.
///
/// A day counts as "successful" differently depending on the goal type:
///  * build  — the logged amount reaches the target
///  * reduce — the logged amount stays at or under the target (including zero,
///             so a day with no log at all is a win)
@immutable
class HabitStats {
  final int currentStreak;
  final int bestStreak;
  final double completionRate;
  final double todayAmount;
  final double weekTotal;
  final double monthTotal;
  final Map<DateTime, double> byDay;

  const HabitStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.completionRate,
    required this.todayAmount,
    required this.weekTotal,
    required this.monthTotal,
    required this.byDay,
  });

  static const empty = HabitStats(
    currentStreak: 0,
    bestStreak: 0,
    completionRate: 0,
    todayAmount: 0,
    weekTotal: 0,
    monthTotal: 0,
    byDay: {},
  );

  static HabitStats compute(Habit habit, List<HabitLog> logs) {
    final byDay = <DateTime, double>{
      for (final l in logs) Fmt.dateOnly(l.date): l.amount,
    };

    final today = Fmt.dateOnly(DateTime.now());
    final isReduce = habit.goalType == 1;

    bool succeeded(DateTime day) {
      final amount = byDay[day] ?? 0;
      return isReduce
          ? amount <= habit.targetAmount
          : amount >= habit.targetAmount;
    }

    /// Days the habit is actually scheduled for; unscheduled days neither
    /// break nor extend a streak.
    bool scheduled(DateTime day) {
      return switch (habit.frequencyType) {
        1 => (habit.weekdayMask & (1 << (day.weekday - 1))) != 0,
        // "X times per week" has no fixed days, so every day is a chance.
        _ => true,
      };
    }

    // --- Current streak ---
    // A reduce-habit's success today is already known; a build-habit that has
    // not been logged yet today should not break the streak, so start at
    // yesterday when today is still incomplete.
    var cursor = today;
    if (!isReduce && !succeeded(today)) {
      cursor = today.subtract(const Duration(days: 1));
    }
    var current = 0;
    while (true) {
      if (!scheduled(cursor)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      if (!succeeded(cursor)) break;
      // A reduce habit with no history at all should not report an infinite
      // streak, so stop once we run past the habit's creation date.
      if (cursor.isBefore(Fmt.dateOnly(habit.createdAt))) break;
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    // --- Best streak, scanned from creation to today ---
    var best = 0;
    var run = 0;
    var day = Fmt.dateOnly(habit.createdAt);
    var successfulDays = 0;
    var scheduledDays = 0;
    while (!day.isAfter(today)) {
      if (scheduled(day)) {
        scheduledDays++;
        if (succeeded(day)) {
          successfulDays++;
          run++;
          if (run > best) best = run;
        } else {
          run = 0;
        }
      }
      day = day.add(const Duration(days: 1));
    }

    final weekStart = Fmt.startOfWeek(today);
    final monthStart = Fmt.startOfMonth(today);
    double sumFrom(DateTime start) => byDay.entries
        .where((e) => !e.key.isBefore(start) && !e.key.isAfter(today))
        .fold(0.0, (a, e) => a + e.value);

    return HabitStats(
      currentStreak: current,
      bestStreak: best,
      completionRate: scheduledDays == 0 ? 0 : successfulDays / scheduledDays,
      todayAmount: byDay[today] ?? 0,
      weekTotal: sumFrom(weekStart),
      monthTotal: sumFrom(monthStart),
      byDay: byDay,
    );
  }

  /// 0–1 intensity for the heatmap, relative to the habit's target.
  double intensityOn(DateTime day, Habit habit) {
    final amount = byDay[Fmt.dateOnly(day)] ?? 0;
    if (amount <= 0) return 0;
    if (habit.targetAmount <= 0) return 1;
    return (amount / habit.targetAmount).clamp(0.15, 1.0);
  }

  /// Estimated caffeine consumed today, in mg.
  double caffeineToday(Habit habit) =>
      (habit.caffeineMgPerUnit ?? 0) * todayAmount;

  /// Estimated money spent today on this habit.
  double costToday(Habit habit) => (habit.costPerUnit ?? 0) * todayAmount;

  double costThisMonth(Habit habit) => (habit.costPerUnit ?? 0) * monthTotal;

  /// True when a reduce-habit has already passed its daily allowance.
  bool overLimit(Habit habit) =>
      habit.goalType == 1 && todayAmount > habit.targetAmount;
}
