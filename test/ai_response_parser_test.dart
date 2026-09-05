import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/ai/ai_action.dart';
import 'package:mysuite/core/ai/ai_client.dart';
import 'package:mysuite/core/ai/ai_response_parser.dart';
import 'package:mysuite/presentation/expenses/repository/expense_repository.dart';

import 'ai_fixtures.dart';

void main() {
  const source = OfflineSource();

  test('the canonical reply becomes an expense, a task and a medicine', () {
    final result = AiResponseParser.parse(
      canonicalJson,
      source: source,
      now: fixedNow,
    );
    expect(result.actions, hasLength(3));
    expect(result.needsClarification, isFalse);

    final expense = result.actions[0] as AddExpenseAction;
    expect(expense.amount, 200);
    expect(expense.txKind, TxKind.expense);
    expect(expense.category, 'Food');
    expect(expense.account, 'bKash');
    expect(expense.note, 'Lunch');

    final task = result.actions[1] as AddTaskAction;
    expect(task.title, 'Call the doctor');
    expect(task.dueDate, DateTime(2026, 9, 5, 17));
    expect(task.hasTime, isTrue);
    expect(task.reminder, DateTime(2026, 9, 5, 17));

    final medicine = result.actions[2] as AddMedicineAction;
    expect(medicine.name, 'Napa');
    expect(medicine.timesPerDay, 3);
    expect(medicine.days, 5);
    expect(medicine.mealRelation, 'after');
    expect(medicine.doseMinutes, isNull);
  });

  test('a fenced reply is accepted', () {
    final result = AiResponseParser.parse(
      '```json\n{"actions": [], "reply": "Nothing to add.", '
      '"needs_clarification": true}\n```',
      source: source,
    );
    expect(result.actions, isEmpty);
    expect(result.reply, 'Nothing to add.');
    expect(result.needsClarification, isTrue);
  });

  test('unknown kinds and unusable actions are skipped, not fatal', () {
    final result = AiResponseParser.parse(
      '{"actions": ['
      '{"kind": "add_reminder", "title": "x"},'
      '{"kind": "add_expense", "amount": 0},'
      '{"kind": "add_task"},'
      '{"kind": "log_habit", "habit": "Water", "habit_amount": 2}'
      '], "reply": "", "needs_clarification": false}',
      source: source,
    );
    expect(result.actions, hasLength(1));
    final habit = result.actions.single as LogHabitAction;
    expect(habit.habit, 'Water');
    expect(habit.amount, 2);
  });

  test('a body that is not a JSON object is malformed', () {
    expect(
      () => AiResponseParser.parse('Sure! Here you go.', source: source),
      throwsA(isA<AiMalformedException>()),
    );
    expect(
      () => AiResponseParser.parse('[1, 2]', source: source),
      throwsA(isA<AiMalformedException>()),
    );
  });

  test('a time with no date that has passed rolls to tomorrow', () {
    final result = AiResponseParser.parse(
      '{"actions": [{"kind": "add_task", "title": "Gym", "time": "09:00"}], '
      '"reply": "", "needs_clarification": false}',
      source: source,
      now: fixedNow, // 14:32
    );
    final task = result.actions.single as AddTaskAction;
    expect(task.dueDate, DateTime(2026, 9, 6, 9));
    expect(task.hasTime, isTrue);
  });

  test('a reminder with a Z suffix is still read as local wall time', () {
    final result = AiResponseParser.parse(
      '{"actions": [{"kind": "add_note", "title": "Wifi", '
      '"note_body": "password is hunter2", "reminder": "2026-09-06T08:30:00Z"}], '
      '"reply": "", "needs_clarification": false}',
      source: source,
    );
    final note = result.actions.single as AddNoteAction;
    expect(note.reminder, DateTime(2026, 9, 6, 8, 30));
    expect(note.body, 'password is hunter2');
  });

  test('priority is clamped and bad recurrence dropped', () {
    final result = AiResponseParser.parse(
      '{"actions": [{"kind": "add_task", "title": "Pay rent", "priority": 9, '
      '"recurrence": "fortnightly"}, {"kind": "add_task", "title": "Standup", '
      '"priority": 0, "recurrence": "weekdays"}, {"kind": "add_task", '
      '"title": "Water plants", "recurrence": "every:3"}], '
      '"reply": "", "needs_clarification": false}',
      source: source,
    );
    final a = result.actions[0] as AddTaskAction;
    expect(a.priority, 4);
    expect(a.recurrence, isNull);
    final b = result.actions[1] as AddTaskAction;
    expect(b.priority, 1);
    expect(b.recurrence, 'weekdays');
    expect((result.actions[2] as AddTaskAction).recurrence, 'every:3');
  });

  test('dose times in HH:mm become sorted minutes', () {
    final result = AiResponseParser.parse(
      '{"actions": [{"kind": "add_medicine", "title": "Seclo", '
      '"dose_times": ["20:00", "08:00", "nope"], "medicine_form": "Capsule"}], '
      '"reply": "", "needs_clarification": false}',
      source: source,
    );
    final m = result.actions.single as AddMedicineAction;
    expect(m.doseMinutes, [480, 1200]);
    expect(m.form, 'capsule');
  });

  test('income and a note title fallback', () {
    final result = AiResponseParser.parse(
      '{"actions": [{"kind": "add_expense", "amount": "1,500", '
      '"kind_detail": "income", "category": "Salary"}, '
      '{"kind": "add_note", "note_body": "the meeting moved to monday morning at ten"}], '
      '"reply": "", "needs_clarification": false}',
      source: source,
    );
    final e = result.actions[0] as AddExpenseAction;
    expect(e.amount, 1500);
    expect(e.txKind, TxKind.income);
    final n = result.actions[1] as AddNoteAction;
    expect(n.title, 'the meeting moved to monday morning');
  });
}
