import 'package:mysuite/core/ai/ai_request_context.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/settings/app_settings.dart';

/// Hand-built rows for the AI tests, mirroring what `_seedDefaults` creates
/// on first launch so the offline parser and the prompt see the same names
/// a fresh install has.
ExpenseCategory category(int id, String name, {bool income = false}) =>
    ExpenseCategory(
      id: id,
      name: name,
      icon: 'shopping_bag',
      color: 0xFF9A6DD7,
      isIncome: income,
      sortOrder: id,
    );

Account account(int id, String name, String type) => Account(
  id: id,
  name: name,
  type: type,
  balance: 0,
  currency: 'BDT',
  color: 0xFF9A6DD7,
  isArchived: false,
);

Person person(int id, String name, {bool self = false}) => Person(
  id: id,
  name: name,
  relation: self ? 'Self' : 'Family',
  color: 0xFFFF6547,
  type: 'household',
  isSelf: self,
);

Habit habit(int id, String name, {String? unit}) => Habit(
  id: id,
  name: name,
  icon: 'star',
  color: 0xFF3BB273,
  unit: unit,
  goalType: 0,
  targetAmount: 1,
  frequencyType: 0,
  weekdayMask: 127,
  timesPerWeek: 7,
  isArchived: false,
  createdAt: DateTime(2026, 1, 1),
);

Project project(int id, String name) => Project(
  id: id,
  name: name,
  color: 0xFF5B7CE0,
  icon: 'folder',
  sortOrder: id,
);

/// Saturday 5 September 2026, 14:32 local time.
final fixedNow = DateTime(2026, 9, 5, 14, 32);

AiRequestContext seededContext({DateTime? now, Set<AppModule>? enabled}) =>
    AiRequestContext(
      now: now ?? fixedNow,
      enabledModules: enabled ?? AppModule.values.toSet(),
      categories: [
        category(1, 'Food'),
        category(2, 'Transport'),
        category(3, 'Bills'),
        category(4, 'Groceries'),
        category(5, 'Health'),
        category(6, 'Other'),
        category(7, 'Salary', income: true),
      ],
      accounts: [
        account(1, 'Cash', 'cash'),
        account(2, 'bKash', 'bkash'),
        account(3, 'Nagad', 'nagad'),
        account(4, 'Bank', 'bank'),
      ],
      people: [person(1, 'Arnob', self: true), person(2, 'Ammu')],
      habits: [
        habit(1, 'Water', unit: 'glasses'),
        habit(2, 'Reading', unit: 'pages'),
      ],
      projects: [project(1, 'Inbox'), project(2, 'Work')],
      profiles: [person(1, 'Arnob', self: true), person(2, 'Ammu')],
    );

/// The reply the prompt's own worked example describes, as a provider in
/// strict mode would return it, with the task due on [fixedNow]'s day.
const canonicalJson = _canonicalTemplate;

/// The same reply with the task and reminder on [day], for tests that run
/// against the real clock: the executor warns about a reminder in the past,
/// so a pinned date would flip those tests once that hour went by.
String canonicalJsonFor(DateTime day) {
  final iso =
      '${day.year}-${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
  return _canonicalTemplate.replaceAll('2026-09-05', iso);
}

const _canonicalTemplate = '''
{
  "actions": [
    {"kind": "add_expense", "title": "Lunch", "amount": 200, "kind_detail": "expense",
     "category": "Food", "account": "bKash", "person": null, "date": null, "time": null,
     "reminder": null, "priority": null, "recurrence": null, "tags": null, "note_body": null,
     "medicine_form": null, "dosage": null, "dosage_unit": null, "times_per_day": null,
     "dose_times": null, "days": null, "meal_relation": null, "habit": null,
     "habit_amount": null, "focus_minutes": null},
    {"kind": "add_task", "title": "Call the doctor", "amount": null, "kind_detail": null,
     "category": null, "account": null, "person": null, "date": "2026-09-05", "time": "17:00",
     "reminder": "2026-09-05T17:00", "priority": null, "recurrence": null, "tags": null,
     "note_body": null, "medicine_form": null, "dosage": null, "dosage_unit": null,
     "times_per_day": null, "dose_times": null, "days": null, "meal_relation": null,
     "habit": null, "habit_amount": null, "focus_minutes": null},
    {"kind": "add_medicine", "title": "Napa", "amount": null, "kind_detail": null,
     "category": null, "account": null, "person": null, "date": null, "time": null,
     "reminder": null, "priority": null, "recurrence": null, "tags": null, "note_body": null,
     "medicine_form": null, "dosage": null, "dosage_unit": null, "times_per_day": 3,
     "dose_times": null, "days": 5, "meal_relation": "after", "habit": null,
     "habit_amount": null, "focus_minutes": null}
  ],
  "reply": "",
  "needs_clarification": false
}
''';
