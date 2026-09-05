import 'dart:convert';

import '../../presentation/expenses/repository/expense_repository.dart';
import '../../presentation/medicine/utils/schedule_generator.dart';
import '../../presentation/tasks/utils/recurrence.dart';
import 'ai_action.dart';
import 'ai_client.dart';

/// Turns the model's JSON into [AiAction]s.
///
/// Tolerant by design: a provider in strict mode returns exactly the schema,
/// but DeepSeek's JSON mode and a fenced reply from a chatty model do not.
/// One bad action is dropped rather than failing the whole command; only a
/// body that is not a JSON object at all is an error.
class AiResponseParser {
  const AiResponseParser._();

  static AiCommandResult parse(
    String text, {
    required AiSource source,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final decoded = _decode(text);

    final rawActions = decoded['actions'];
    final actions = <AiAction>[];
    if (rawActions is List) {
      for (final raw in rawActions) {
        if (raw is! Map) continue;
        final action = _action(Map<String, Object?>.from(raw), reference);
        if (action != null) actions.add(action);
      }
    }

    return AiCommandResult(
      actions: actions,
      reply: _string(decoded['reply']) ?? '',
      needsClarification: decoded['needs_clarification'] == true,
      source: source,
    );
  }

  static Map<String, Object?> _decode(String text) {
    var body = text.trim();
    // Strip a ```json fence if the model wrapped its answer in one.
    final fence = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$').firstMatch(body);
    if (fence != null) body = fence.group(1)!.trim();
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const AiMalformedException('The reply was not valid JSON.');
    }
    if (decoded is! Map) {
      throw const AiMalformedException('The reply was not a JSON object.');
    }
    return Map<String, Object?>.from(decoded);
  }

  static AiAction? _action(Map<String, Object?> m, DateTime now) {
    final kind = AiActionKindX.fromWire(m['kind'] as String?);
    if (kind == null) return null;
    final title = _string(m['title']);

    switch (kind) {
      case AiActionKind.addExpense:
        final amount = _number(m['amount']);
        if (amount == null || amount <= 0) return null;
        return AddExpenseAction(
          amount: amount,
          txKind: _string(m['kind_detail'])?.toLowerCase() == 'income'
              ? TxKind.income
              : TxKind.expense,
          category: _string(m['category']),
          account: _string(m['account']),
          person: _string(m['person']),
          note: title,
          date: _date(_string(m['date'])),
        );

      case AiActionKind.addTask:
        if (title == null) return null;
        final due = _dateTime(_string(m['date']), _string(m['time']), now);
        return AddTaskAction(
          title: title,
          dueDate: due?.at,
          hasTime: due?.hasTime ?? false,
          reminder: _localDateTime(_string(m['reminder'])),
          priority: (_number(m['priority'])?.round() ?? 4).clamp(1, 4),
          recurrence: _recurrence(_string(m['recurrence'])),
          tags: _strings(m['tags']),
        );

      case AiActionKind.addNote:
        final body = _string(m['note_body']) ?? '';
        if (title == null && body.isEmpty) return null;
        return AddNoteAction(
          title: title ?? _titleFrom(body),
          body: body,
          reminder: _localDateTime(_string(m['reminder'])),
          tags: _strings(m['tags']),
        );

      case AiActionKind.addMedicine:
        if (title == null) return null;
        final times = _strings(
          m['dose_times'],
        ).map(AiDates.minutesOf).whereType<int>().toList();
        final meal = _string(m['meal_relation'])?.toLowerCase();
        return AddMedicineAction(
          name: title,
          form: _string(m['medicine_form'])?.toLowerCase(),
          dosage: _number(m['dosage']),
          dosageUnit: _string(m['dosage_unit']),
          timesPerDay: _number(m['times_per_day'])?.round(),
          doseMinutes: times.isEmpty ? null : (times..sort()),
          days: _number(m['days'])?.round(),
          mealRelation: meal == null
              ? null
              : MealRelationX.fromToken(meal).token,
          person: _string(m['person']),
          notes: _string(m['note_body']),
        );

      case AiActionKind.logHabit:
        final habit = _string(m['habit']);
        if (habit == null) return null;
        return LogHabitAction(
          habit: habit,
          amount: _number(m['habit_amount']) ?? 1,
        );

      case AiActionKind.startFocus:
        return StartFocusAction(
          minutes: _number(m['focus_minutes'])?.round() ?? 25,
        );
    }
  }

  // --- Field coercion ------------------------------------------------------

  static String? _string(Object? v) {
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  static double? _number(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', ''));
    return null;
  }

  static List<String> _strings(Object? v) =>
      v is List ? v.map(_string).whereType<String>().toList() : const [];

  static String _titleFrom(String body) {
    final words = body.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(6).join(' ');
  }

  static DateTime? _date(String? s) {
    if (s == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
    if (m == null) return null;
    return DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }

  /// `yyyy-MM-ddTHH:mm` as local time. `DateTime.parse` would also accept a
  /// trailing `Z` and shift the hour, which is never what a reminder means.
  static DateTime? _localDateTime(String? s) {
    if (s == null) return null;
    final m = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})[T ](\d{1,2}):(\d{2})',
    ).firstMatch(s);
    if (m == null) return _date(s);
    return DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      int.parse(m.group(4)!),
      int.parse(m.group(5)!),
    );
  }

  /// Combines a date and a time. A time with no date means today, or
  /// tomorrow if that moment has already passed, the same rule the task
  /// quick-add parser applies.
  static ({DateTime at, bool hasTime})? _dateTime(
    String? date,
    String? time,
    DateTime now,
  ) {
    final day = _date(date);
    final minutes = AiDates.minutesOf(time);
    if (day == null && minutes == null) return null;
    if (minutes == null) return (at: day!, hasTime: false);
    final base = day ?? DateTime(now.year, now.month, now.day);
    var at = base.add(Duration(minutes: minutes));
    if (day == null && at.isBefore(now)) at = at.add(const Duration(days: 1));
    return (at: at, hasTime: true);
  }

  static String? _recurrence(String? rule) {
    if (rule == null) return null;
    final r = rule.toLowerCase();
    if (Recurrence.presets.containsKey(r)) return r;
    if (RegExp(r'^every:\d+$').hasMatch(r)) return r;
    if (RegExp(r'^nth:\d:\d$').hasMatch(r)) return r;
    return null;
  }
}
