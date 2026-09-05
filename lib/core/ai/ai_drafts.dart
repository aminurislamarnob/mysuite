import 'package:flutter/foundation.dart';

import '../../presentation/expenses/repository/expense_repository.dart';
import '../../presentation/medicine/utils/schedule_generator.dart';
import '../../presentation/tasks/utils/recurrence.dart';
import '../settings/app_settings.dart';
import '../utils/formatters.dart';
import 'ai_action.dart';

/// An action with every name turned into an id: what a preview card shows,
/// what an editor sheet is prefilled from, and what the executor saves.
sealed class AiDraft {
  const AiDraft();

  AiActionKind get kind;
  AppModule get module => kind.module;
  String get title;

  /// The second line of the preview card.
  String summary(String currencySymbol);
}

final class ExpenseDraft extends AiDraft {
  final double amount;
  final int txKind;
  final int? categoryId;
  final String? categoryName;
  final int accountId;
  final String accountName;
  final int? personId;
  final String? personName;
  final String? note;
  final DateTime date;

  const ExpenseDraft({
    required this.amount,
    this.txKind = TxKind.expense,
    this.categoryId,
    this.categoryName,
    required this.accountId,
    required this.accountName,
    this.personId,
    this.personName,
    this.note,
    required this.date,
  });

  @override
  AiActionKind get kind => AiActionKind.addExpense;

  @override
  String get title =>
      note ?? categoryName ?? (txKind == TxKind.income ? 'Income' : 'Expense');

  @override
  String summary(String currencySymbol) => [
    Fmt.money(amount, currencySymbol),
    if (txKind == TxKind.income) 'Income',
    ?categoryName,
    accountName,
    if (personName != null) 'for $personName',
    Fmt.relativeDay(date),
  ].join(' · ');
}

final class TaskDraft extends AiDraft {
  @override
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool hasDueTime;
  final DateTime? reminder;
  final int priority;
  final String? recurrenceRule;
  final List<String> tags;
  final int? projectId;
  final String? projectName;

  const TaskDraft({
    required this.title,
    this.description,
    this.dueDate,
    this.hasDueTime = false,
    this.reminder,
    this.priority = 4,
    this.recurrenceRule,
    this.tags = const [],
    this.projectId,
    this.projectName,
  });

  @override
  AiActionKind get kind => AiActionKind.addTask;

  @override
  String summary(String currencySymbol) {
    final parts = <String>[
      if (dueDate != null) Fmt.due(dueDate!, withTime: hasDueTime),
      if (reminder != null) 'Reminder ${Fmt.time(reminder!)}',
      if (priority < 4) 'P$priority',
      if (recurrenceRule != null) Recurrence.label(recurrenceRule),
      ?projectName,
      if (tags.isNotEmpty) tags.map((t) => '#$t').join(' '),
    ];
    return parts.isEmpty ? 'No date' : parts.join(' · ');
  }
}

final class NoteDraft extends AiDraft {
  @override
  final String title;
  final String body;
  final DateTime? reminderAt;
  final List<String> tags;

  const NoteDraft({
    required this.title,
    this.body = '',
    this.reminderAt,
    this.tags = const [],
  });

  @override
  AiActionKind get kind => AiActionKind.addNote;

  @override
  String summary(String currencySymbol) {
    final firstLine = body.split('\n').first.trim();
    final parts = <String>[
      if (firstLine.isNotEmpty && firstLine != title) firstLine,
      if (reminderAt != null)
        'Reminder ${Fmt.due(reminderAt!, withTime: true)}',
    ];
    return parts.isEmpty ? 'Empty note' : parts.join(' · ');
  }
}

final class MedicineDraft extends AiDraft {
  final String name;
  final String form;
  final double dosage;
  final String dosageUnit;
  final List<int> doseMinutes;
  final DateTime start;
  final DateTime end;
  final MealRelation meal;
  final int? profileId;
  final String? profileName;
  final String? notes;

  const MedicineDraft({
    required this.name,
    this.form = 'tablet',
    this.dosage = 1,
    this.dosageUnit = 'tablet',
    this.doseMinutes = const [480],
    required this.start,
    required this.end,
    this.meal = MealRelation.none,
    this.profileId,
    this.profileName,
    this.notes,
  });

  @override
  AiActionKind get kind => AiActionKind.addMedicine;

  @override
  String get title => name;

  int get days => end.difference(start).inDays + 1;

  ScheduleSpec get spec =>
      ScheduleSpec(start: start, end: end, doseMinutes: doseMinutes);

  String get dosageLabel => '${Fmt.amountInput(dosage)} $dosageUnit';

  @override
  String summary(String currencySymbol) => [
    dosageLabel,
    '${doseMinutes.length}x daily ${doseMinutes.map(Fmt.minutesOfDay).join(', ')}',
    '$days ${days == 1 ? 'day' : 'days'}',
    if (meal != MealRelation.none) meal.label,
    if (profileName != null) 'for $profileName',
  ].join(' · ');
}

final class HabitLogDraft extends AiDraft {
  final int habitId;
  final String habitName;
  final double amount;
  final String? unit;

  const HabitLogDraft({
    required this.habitId,
    required this.habitName,
    this.amount = 1,
    this.unit,
  });

  @override
  AiActionKind get kind => AiActionKind.logHabit;

  @override
  String get title => habitName;

  @override
  String summary(String currencySymbol) =>
      '+${Fmt.amountInput(amount)}${unit == null ? '' : ' $unit'} today';
}

final class FocusDraft extends AiDraft {
  final int minutes;

  const FocusDraft({this.minutes = 25});

  @override
  AiActionKind get kind => AiActionKind.startFocus;

  @override
  String get title => 'Focus session';

  @override
  String summary(String currencySymbol) => '$minutes minutes';
}

/// A draft plus what the resolver wants the user to know before saving.
@immutable
class ActionPreview {
  final AiDraft draft;
  final List<String> warnings;

  /// True when the draft cannot be saved at all: its module is switched off
  /// or a required row (a habit, an account) does not exist.
  final bool blocked;

  const ActionPreview({
    required this.draft,
    this.warnings = const [],
    this.blocked = false,
  });

  bool get clean => warnings.isEmpty && !blocked;

  ActionPreview copyWith({AiDraft? draft}) => ActionPreview(
    draft: draft ?? this.draft,
    warnings: warnings,
    blocked: blocked,
  );
}

/// What a batch save did: one slot per draft, in order, null where that
/// draft failed, plus a human-readable line per failure.
@immutable
class AiSaveOutcome {
  final List<SavedItem?> results;
  final List<String> failures;

  const AiSaveOutcome({required this.results, required this.failures});

  List<SavedItem> get saved => results.whereType<SavedItem>().toList();
}

/// Something that was written, and where to go to see it.
@immutable
class SavedItem {
  final AiActionKind kind;
  final int? id;
  final String title;
  final String route;
  final Object? extra;

  const SavedItem({
    required this.kind,
    this.id,
    required this.title,
    required this.route,
    this.extra,
  });
}
