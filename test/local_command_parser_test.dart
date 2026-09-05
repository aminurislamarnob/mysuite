import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/ai/ai_action.dart';
import 'package:mysuite/core/ai/local_command_parser.dart';
import 'package:mysuite/presentation/expenses/repository/expense_repository.dart';

import 'ai_fixtures.dart';

/// The offline parser is what runs with no API key. It must handle the same
/// canonical sentence the prompt teaches the model, clause by clause.
void main() {
  final context = seededContext();

  List<AiAction> parse(String s) =>
      LocalCommandParser.parse(s, context: context, now: fixedNow).actions;

  test('the canonical sentence yields an expense, a task and a medicine', () {
    final actions = parse(
      'spent 200 taka on lunch with bKash and remind me to call the doctor '
      'at 5, and add Napa 3 times a day for 5 days',
    );
    expect(actions.map((a) => a.kind), [
      AiActionKind.addExpense,
      AiActionKind.addTask,
      AiActionKind.addMedicine,
    ]);

    final expense = actions[0] as AddExpenseAction;
    expect(expense.amount, 200);
    expect(expense.category, 'Food');
    expect(expense.account, 'bKash');
    expect(expense.txKind, TxKind.expense);

    final task = actions[1] as AddTaskAction;
    expect(task.title, 'Call the doctor');
    expect(task.dueDate, DateTime(2026, 9, 5, 17));
    expect(task.reminder, DateTime(2026, 9, 5, 17));

    final med = actions[2] as AddMedicineAction;
    expect(med.name, 'Napa');
    expect(med.timesPerDay, 3);
    expect(med.days, 5);
  });

  test('"and" inside a phrase does not split the clause', () {
    final actions = parse('bought bread and butter 120 taka cash');
    expect(actions, hasLength(1));
    final e = actions.single as AddExpenseAction;
    expect(e.amount, 120);
    expect(e.account, 'Cash');
    expect(e.note, 'Bread and butter');
  });

  test('a habit name logs the habit with the spoken amount', () {
    final a = parse('drank 2 glasses of water').single as LogHabitAction;
    expect(a.habit, 'Water');
    expect(a.amount, 2);
    final b = parse('read ten pages').single as LogHabitAction;
    expect(b.habit, 'Reading');
    expect(b.amount, 10);
  });

  test('focus and note cues', () {
    final f =
        parse('start a 40 minute focus session').single as StartFocusAction;
    expect(f.minutes, 40);
    final n =
        parse('note remember the wifi password is hunter2').single
            as AddNoteAction;
    expect(n.body, 'remember the wifi password is hunter2');
    expect(n.title, 'Remember the wifi password is hunter2');
  });

  test('income words make an income', () {
    final a = parse('received salary 50000 in bank').single as AddExpenseAction;
    expect(a.txKind, TxKind.income);
    expect(a.category, 'Salary');
    expect(a.account, 'Bank');
  });

  test('medicine details: dosage, meal, twice a day', () {
    final m =
        parse('take Seclo 20 mg twice a day before food for 10 days').single
            as AddMedicineAction;
    expect(m.name, 'Seclo');
    expect(m.dosage, 20);
    expect(m.dosageUnit, 'mg');
    expect(m.timesPerDay, 2);
    expect(m.mealRelation, 'before');
    expect(m.days, 10);
  });

  test('a thousands separator is not a clause break', () {
    final actions = parse('spent 1,200 taka on rent with bank');
    expect(actions, hasLength(1));
    expect((actions.single as AddExpenseAction).amount, 1200);
  });

  test('"remind me to" wins over a habit name in the sentence', () {
    final t = parse('remind me to drink water at 6').single as AddTaskAction;
    expect(t.title, 'Drink water');
    expect(t.reminder, DateTime(2026, 9, 5, 18));
  });

  test('a category name only matches as a whole word', () {
    // "brother" contains the seeded category "Other".
    final t = parse('call my brother at 5').single;
    expect(t, isA<AddTaskAction>());
  });

  test('anything else is a task, and empty input asks for clarification', () {
    final t = parse('buy milk tomorrow').single as AddTaskAction;
    expect(t.title, 'Buy milk');
    expect(t.dueDate, DateTime(2026, 9, 6));

    final result = LocalCommandParser.parse(
      '',
      context: context,
      now: fixedNow,
    );
    expect(result.actions, isEmpty);
    expect(result.needsClarification, isTrue);
    expect(result.source, isA<OfflineSource>());
  });
}
