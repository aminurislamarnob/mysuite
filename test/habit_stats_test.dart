import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/presentation/habits/utils/habit_stats.dart';

/// Builds a habit row directly, bypassing the database so the streak maths can
/// be tested in isolation.
Habit buildHabit({
  int goalType = 0,
  double target = 1,
  int frequencyType = 0,
  int weekdayMask = 127,
  required DateTime createdAt,
}) {
  return Habit(
    id: 1,
    name: 'Test',
    icon: 'coffee',
    color: 0xFF10B981,
    unit: 'cups',
    goalType: goalType,
    targetAmount: target,
    frequencyType: frequencyType,
    weekdayMask: weekdayMask,
    timesPerWeek: 7,
    isArchived: false,
    createdAt: createdAt,
  );
}

HabitLog log(DateTime date, double amount) =>
    HabitLog(id: 0, habitId: 1, date: date, amount: amount);

void main() {
  DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  final today = dayOnly(DateTime.now());
  DateTime ago(int days) => today.subtract(Duration(days: days));

  group('build habits', () {
    test('counts consecutive days that hit the target', () {
      final habit = buildHabit(target: 2, createdAt: ago(10));
      final stats = HabitStats.compute(habit, [
        log(today, 2),
        log(ago(1), 3),
        log(ago(2), 2),
      ]);

      expect(stats.currentStreak, 3);
      expect(stats.todayAmount, 2);
    });

    test('a day short of the target breaks the streak', () {
      final habit = buildHabit(target: 2, createdAt: ago(10));
      final stats = HabitStats.compute(habit, [
        log(today, 2),
        log(ago(1), 1), // below target
        log(ago(2), 2),
      ]);

      expect(stats.currentStreak, 1);
    });

    test('an unlogged today does not break yesterday\'s streak', () {
      final habit = buildHabit(target: 2, createdAt: ago(10));
      final stats = HabitStats.compute(habit, [
        log(ago(1), 2),
        log(ago(2), 2),
      ]);

      // Today is still in progress, so the streak counts back from yesterday.
      expect(stats.currentStreak, 2);
      expect(stats.todayAmount, 0);
    });

    test('best streak survives a later break', () {
      final habit = buildHabit(target: 1, createdAt: ago(6));
      final stats = HabitStats.compute(habit, [
        log(ago(6), 1),
        log(ago(5), 1),
        log(ago(4), 1),
        log(ago(3), 1),
        // ago(2) missed
        log(ago(1), 1),
      ]);

      expect(stats.bestStreak, 4);
      expect(stats.currentStreak, 1);
    });

    test('completion rate counts scheduled days only', () {
      final habit = buildHabit(target: 1, createdAt: ago(3));
      final stats = HabitStats.compute(habit, [
        log(ago(3), 1),
        log(ago(2), 1),
      ]);

      // 4 scheduled days (ago3..today), 2 successful.
      expect(stats.completionRate, closeTo(0.5, 0.001));
    });
  });

  group('reduce habits', () {
    test('staying under the limit keeps the streak alive', () {
      final habit = buildHabit(goalType: 1, target: 2, createdAt: ago(3));
      final stats = HabitStats.compute(habit, [
        log(today, 1),
        log(ago(1), 2),
      ]);

      // ago(2) and ago(3) have no logs at all, which counts as success.
      expect(stats.currentStreak, 4);
      expect(stats.overLimit(habit), isFalse);
    });

    test('exceeding the limit breaks the streak and flags the overrun', () {
      final habit = buildHabit(goalType: 1, target: 2, createdAt: ago(3));
      final stats = HabitStats.compute(habit, [log(today, 5)]);

      expect(stats.currentStreak, 0);
      expect(stats.overLimit(habit), isTrue);
    });

    test('the streak stops at the habit creation date', () {
      final habit = buildHabit(goalType: 1, target: 2, createdAt: ago(2));
      final stats = HabitStats.compute(habit, [log(today, 0)]);

      // Only today, ago(1) and ago(2) exist, so the streak cannot exceed 3.
      expect(stats.currentStreak, lessThanOrEqualTo(3));
    });
  });

  group('derived figures', () {
    test('caffeine and cost scale with the logged amount', () {
      final habit = Habit(
        id: 1,
        name: 'Coffee',
        icon: 'coffee',
        color: 0xFFF59E0B,
        unit: 'cups',
        goalType: 1,
        targetAmount: 2,
        frequencyType: 0,
        weekdayMask: 127,
        timesPerWeek: 7,
        costPerUnit: 50,
        caffeineMgPerUnit: 95,
        isArchived: false,
        createdAt: ago(5),
      );
      final stats = HabitStats.compute(habit, [log(today, 3)]);

      expect(stats.caffeineToday(habit), 285);
      expect(stats.costToday(habit), 150);
    });

    test('heatmap intensity is zero on days with no log', () {
      final habit = buildHabit(target: 4, createdAt: ago(5));
      final stats = HabitStats.compute(habit, [log(today, 2)]);

      expect(stats.intensityOn(ago(1), habit), 0);
      expect(stats.intensityOn(today, habit), closeTo(0.5, 0.001));
    });
  });
}
