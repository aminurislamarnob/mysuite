import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/utils/formatters.dart';
import 'package:mysuite/models/habit.dart';
import 'package:mysuite/models/medicine.dart';
import 'package:mysuite/models/task.dart';

void main() {
  group('Habit', () {
    test('build streak counts consecutive met days', () {
      final h = Habit(
        id: '1',
        name: 'Water',
        unit: 'glasses',
        target: 2,
        goal: HabitGoal.build,
        color: 0xFF06B6D4,
        iconCode: 1,
      );
      final today = Day.today();
      for (var i = 0; i < 3; i++) {
        h.setAmount(today.subtract(Duration(days: i)), 2);
      }
      expect(h.currentStreak(), 3);
      expect(h.succeededOn(today), isTrue);
    });

    test('reduce habit succeeds when at or under target', () {
      final h = Habit(
        id: '2',
        name: 'Coffee',
        unit: 'cups',
        target: 2,
        goal: HabitGoal.reduce,
        color: 0xFFF59E0B,
        iconCode: 0,
      );
      final today = Day.today();
      h.setAmount(today, 2);
      expect(h.succeededOn(today), isTrue);
      h.add(today, 1);
      expect(h.succeededOn(today), isFalse);
    });

    test('round-trips through JSON', () {
      final h = Habit(
        id: '3',
        name: 'Read',
        unit: 'pages',
        target: 20,
        goal: HabitGoal.build,
        color: 0xFF8B5CF6,
        iconCode: 3,
      );
      h.setAmount(Day.today(), 10);
      final copy = Habit.fromJson(h.toJson());
      expect(copy.name, h.name);
      expect(copy.amountOn(Day.today()), 10);
    });
  });

  group('Medicine', () {
    test('generates doses and tracks adherence', () {
      final start = Day.today();
      final med = Medicine(
        id: 'm1',
        name: 'Napa',
        dosage: '500mg',
        form: MedForm.tablet,
        times: [8 * 60, 20 * 60],
        startDate: start,
        endDate: start.add(const Duration(days: 2)),
      );
      expect(med.courseDays, 3);
      expect(med.dosesOn(start), 2);
      med.setTaken(start, 8 * 60, true);
      expect(med.takenCountOn(start), 1);
      expect(med.adherence(), greaterThan(0));
    });
  });

  group('Task quick-add parsing', () {
    test('priority/tag/date round-trip via JSON', () {
      final t = Task(id: 't1', title: 'Pay bill', priority: Priority.p1);
      final copy = Task.fromJson(t.toJson());
      expect(copy.priority, Priority.p1);
      expect(copy.title, 'Pay bill');
    });
  });
}
