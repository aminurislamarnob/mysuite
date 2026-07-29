import 'package:flutter/foundation.dart';

/// The structured result of parsing a quick-add string such as
/// `"Buy milk tomorrow 5pm #shopping !high *daily"`.
@immutable
class ParsedTask {
  final String title;
  final DateTime? dueDate;
  final bool hasTime;
  final int priority;
  final List<String> tags;
  final String? recurrenceRule;
  final int? estimateMinutes;

  const ParsedTask({
    required this.title,
    this.dueDate,
    this.hasTime = false,
    this.priority = 4,
    this.tags = const [],
    this.recurrenceRule,
    this.estimateMinutes,
  });
}

/// Parses natural-language quick-add input into task fields.
///
/// Everything it recognises is stripped from the title so the saved task reads
/// cleanly. Tokens can appear in any order.
class NlpParser {
  const NlpParser._();

  static const _weekdays = <String, int>{
    'monday': DateTime.monday,
    'mon': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'tue': DateTime.tuesday,
    'tues': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'wed': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'thu': DateTime.thursday,
    'thurs': DateTime.thursday,
    'friday': DateTime.friday,
    'fri': DateTime.friday,
    'saturday': DateTime.saturday,
    'sat': DateTime.saturday,
    'sunday': DateTime.sunday,
    'sun': DateTime.sunday,
  };

  static const _months = <String, int>{
    'jan': 1, 'january': 1, 'feb': 2, 'february': 2, 'mar': 3, 'march': 3,
    'apr': 4, 'april': 4, 'may': 5, 'jun': 6, 'june': 6, 'jul': 7, 'july': 7,
    'aug': 8, 'august': 8, 'sep': 9, 'sept': 9, 'september': 9, 'oct': 10,
    'october': 10, 'nov': 11, 'november': 11, 'dec': 12, 'december': 12,
  };

  static ParsedTask parse(String input, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    var text = input.trim();

    final tags = <String>[];
    var priority = 4;
    String? recurrence;
    int? estimate;
    DateTime? date;
    var hasTime = false;

    // --- #tags -------------------------------------------------------------
    text = text.replaceAllMapped(RegExp(r'#([\w\-]+)'), (m) {
      tags.add(m.group(1)!);
      return ' ';
    });

    // --- !priority ---------------------------------------------------------
    text = text.replaceAllMapped(
      RegExp(r'!(p[1-4]|high|urgent|med|medium|low)\b', caseSensitive: false),
      (m) {
        priority = switch (m.group(1)!.toLowerCase()) {
          'p1' || 'high' || 'urgent' => 1,
          'p2' || 'med' || 'medium' => 2,
          'p3' || 'low' => 3,
          _ => 4,
        };
        return ' ';
      },
    );

    // --- *recurrence -------------------------------------------------------
    text = text.replaceAllMapped(
      RegExp(r'\*(daily|weekdays|weekly|biweekly|monthly|yearly)\b',
          caseSensitive: false),
      (m) {
        recurrence = m.group(1)!.toLowerCase();
        return ' ';
      },
    );
    // Bare "every day" / "every 3 days" phrasing.
    text = text.replaceAllMapped(
      RegExp(r'\bevery\s+(day|week|month|year|(\d+)\s+days?)\b',
          caseSensitive: false),
      (m) {
        final whole = m.group(1)!.toLowerCase();
        final n = m.group(2);
        recurrence = n != null
            ? 'every:$n'
            : switch (whole) {
                'day' => 'daily',
                'week' => 'weekly',
                'month' => 'monthly',
                _ => 'yearly',
              };
        return ' ';
      },
    );

    // --- ~estimate ---------------------------------------------------------
    text = text.replaceAllMapped(
      RegExp(r'~(\d+)\s*(m|min|mins|minutes|h|hr|hrs|hours)\b',
          caseSensitive: false),
      (m) {
        final n = int.parse(m.group(1)!);
        final unit = m.group(2)!.toLowerCase();
        estimate = unit.startsWith('h') ? n * 60 : n;
        return ' ';
      },
    );

    // --- Explicit dates: 25/12, 25-12-2026, "25 Dec", "Dec 25" -------------
    final numericDate = RegExp(r'\b(\d{1,2})[/\-](\d{1,2})(?:[/\-](\d{2,4}))?\b')
        .firstMatch(text);
    if (numericDate != null) {
      final day = int.parse(numericDate.group(1)!);
      final month = int.parse(numericDate.group(2)!);
      var year = reference.year;
      final rawYear = numericDate.group(3);
      if (rawYear != null) {
        year = rawYear.length == 2 ? 2000 + int.parse(rawYear) : int.parse(rawYear);
      }
      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        var candidate = DateTime(year, month, day);
        if (rawYear == null && candidate.isBefore(_dateOnly(reference))) {
          candidate = DateTime(year + 1, month, day);
        }
        date = candidate;
        text = text.replaceFirst(numericDate.group(0)!, ' ');
      }
    }

    if (date == null) {
      final monthNames = _months.keys.join('|');
      final textualDate = RegExp(
        r'\b(?:(\d{1,2})\s+(' + monthNames + r')|(' + monthNames +
            r')\s+(\d{1,2}))\b',
        caseSensitive: false,
      ).firstMatch(text);
      if (textualDate != null) {
        final day = int.parse(
            textualDate.group(1) ?? textualDate.group(4)!);
        final monthToken =
            (textualDate.group(2) ?? textualDate.group(3)!).toLowerCase();
        final month = _months[monthToken]!;
        var candidate = DateTime(reference.year, month, day);
        if (candidate.isBefore(_dateOnly(reference))) {
          candidate = DateTime(reference.year + 1, month, day);
        }
        date = candidate;
        text = text.replaceFirst(textualDate.group(0)!, ' ');
      }
    }

    // --- Relative days -----------------------------------------------------
    if (date == null) {
      final relative = RegExp(
              r'\b(today|tonight|tomorrow|tmr|yesterday|next week|next month)\b',
              caseSensitive: false)
          .firstMatch(text);
      if (relative != null) {
        final token = relative.group(1)!.toLowerCase();
        final base = _dateOnly(reference);
        date = switch (token) {
          'today' => base,
          'tonight' => base,
          'tomorrow' || 'tmr' => base.add(const Duration(days: 1)),
          'yesterday' => base.subtract(const Duration(days: 1)),
          'next week' => base.add(const Duration(days: 7)),
          _ => DateTime(base.year, base.month + 1, base.day),
        };
        if (token == 'tonight') {
          date = date.add(const Duration(hours: 20));
          hasTime = true;
        }
        text = text.replaceFirst(relative.group(0)!, ' ');
      }
    }

    // --- Weekday names, optionally prefixed with "next" --------------------
    if (date == null) {
      final weekdayNames = _weekdays.keys.join('|');
      final match = RegExp(r'\b(next\s+)?(' + weekdayNames + r')\b',
              caseSensitive: false)
          .firstMatch(text);
      if (match != null) {
        final target = _weekdays[match.group(2)!.toLowerCase()]!;
        final base = _dateOnly(reference);
        var delta = (target - base.weekday + 7) % 7;
        // A bare weekday name means the *next* one, never today.
        if (delta == 0) delta = 7;
        if (match.group(1) != null && delta < 7) delta += 7;
        date = base.add(Duration(days: delta));
        text = text.replaceFirst(match.group(0)!, ' ');
      }
    }

    // --- Times: 5pm, 5:30pm, 17:30, "at 9" --------------------------------
    final timeMatch = RegExp(
      r'\b(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b',
      caseSensitive: false,
    ).allMatches(text).where((m) {
      // Only treat it as a time if it has am/pm, a colon, or an "at" prefix.
      final hasMeridiem = m.group(3) != null;
      final hasMinutes = m.group(2) != null;
      final hasAt = m.group(0)!.toLowerCase().startsWith('at');
      final hour = int.parse(m.group(1)!);
      return (hasMeridiem || hasMinutes || hasAt) && hour <= 23;
    }).firstOrNull;

    if (timeMatch != null) {
      var hour = int.parse(timeMatch.group(1)!);
      final minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
      final meridiem = timeMatch.group(3)?.toLowerCase();
      if (meridiem == 'pm' && hour < 12) hour += 12;
      if (meridiem == 'am' && hour == 12) hour = 0;
      if (hour <= 23 && minute <= 59) {
        final base = date ?? _dateOnly(reference);
        var withTime = DateTime(base.year, base.month, base.day, hour, minute);
        // If only a time was given and it has already passed, assume tomorrow.
        if (withTime.isBefore(reference) &&
            timeMatchOnlyTime(withTime, reference)) {
          withTime = withTime.add(const Duration(days: 1));
        }
        date = withTime;
        hasTime = true;
        text = text.replaceFirst(timeMatch.group(0)!, ' ');
      }
    }

    final title = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return ParsedTask(
      title: title.isEmpty ? input.trim() : title,
      dueDate: date,
      hasTime: hasTime,
      priority: priority,
      tags: tags,
      recurrenceRule: recurrence,
      estimateMinutes: estimate,
    );
  }

  /// True when [candidate] is on the same calendar day as [reference], meaning
  /// only a time-of-day was supplied.
  @visibleForTesting
  static bool timeMatchOnlyTime(DateTime candidate, DateTime reference) =>
      candidate.year == reference.year &&
      candidate.month == reference.month &&
      candidate.day == reference.day;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
