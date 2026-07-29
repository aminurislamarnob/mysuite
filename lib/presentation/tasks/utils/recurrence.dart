/// Recurrence rules for tasks.
///
/// A deliberately small token vocabulary rather than full RFC-5545 RRULE:
/// these are the patterns the spec calls for, and they round-trip as plain
/// strings in a single column.
///
///   daily            every day
///   weekdays         Mon–Fri
///   weekly           same weekday each week
///   biweekly         same weekday every two weeks
///   monthly          same day-of-month
///   yearly           same day and month
///   every:N          every N days
///   nth:W:D          the Wth weekday D of the month, e.g. "nth:2:1" is the
///                    2nd Monday (D uses DateTime.weekday, 1 = Monday)
class Recurrence {
  const Recurrence._();

  static const presets = <String, String>{
    'daily': 'Every day',
    'weekdays': 'Every weekday',
    'weekly': 'Every week',
    'biweekly': 'Every 2 weeks',
    'monthly': 'Every month',
    'yearly': 'Every year',
  };

  static String label(String? rule) {
    if (rule == null || rule.isEmpty) return 'Does not repeat';
    if (presets.containsKey(rule)) return presets[rule]!;
    if (rule.startsWith('every:')) {
      final n = int.tryParse(rule.substring(6));
      return n == null ? 'Custom' : 'Every $n days';
    }
    if (rule.startsWith('nth:')) {
      final parts = rule.split(':');
      if (parts.length == 3) {
        final week = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);
        if (week != null && day != null) {
          return 'Every ${_ordinal(week)} ${_weekdayName(day)}';
        }
      }
    }
    return 'Custom';
  }

  /// The next due date strictly after [from], or null when the rule is unknown.
  static DateTime? nextOccurrence(String rule, DateTime from) {
    if (rule.isEmpty) return null;

    switch (rule) {
      case 'daily':
        return from.add(const Duration(days: 1));
      case 'weekdays':
        var next = from.add(const Duration(days: 1));
        while (next.weekday == DateTime.saturday ||
            next.weekday == DateTime.sunday) {
          next = next.add(const Duration(days: 1));
        }
        return next;
      case 'weekly':
        return from.add(const Duration(days: 7));
      case 'biweekly':
        return from.add(const Duration(days: 14));
      case 'monthly':
        return _addMonths(from, 1);
      case 'yearly':
        return _addMonths(from, 12);
    }

    if (rule.startsWith('every:')) {
      final n = int.tryParse(rule.substring(6));
      if (n == null || n <= 0) return null;
      return from.add(Duration(days: n));
    }

    if (rule.startsWith('nth:')) {
      final parts = rule.split(':');
      if (parts.length != 3) return null;
      final week = int.tryParse(parts[1]);
      final weekday = int.tryParse(parts[2]);
      if (week == null || weekday == null) return null;
      // Search forward from next month so we always move past `from`.
      var candidate = _nthWeekdayOfMonth(from.year, from.month, week, weekday);
      if (candidate == null || !candidate.isAfter(from)) {
        final nextMonth = _addMonths(DateTime(from.year, from.month, 1), 1);
        candidate = _nthWeekdayOfMonth(
            nextMonth.year, nextMonth.month, week, weekday);
      }
      if (candidate == null) return null;
      // Carry the original time-of-day across.
      return DateTime(candidate.year, candidate.month, candidate.day,
          from.hour, from.minute);
    }

    return null;
  }

  /// Adds months while clamping the day, so 31 Jan + 1 month is 28/29 Feb
  /// rather than rolling into March.
  static DateTime _addMonths(DateTime d, int months) {
    final totalMonths = d.month - 1 + months;
    final year = d.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, d.day > lastDay ? lastDay : d.day, d.hour,
        d.minute);
  }

  static DateTime? _nthWeekdayOfMonth(
      int year, int month, int nth, int weekday) {
    final first = DateTime(year, month, 1);
    final offset = (weekday - first.weekday + 7) % 7;
    final day = 1 + offset + (nth - 1) * 7;
    final lastDay = DateTime(year, month + 1, 0).day;
    if (day > lastDay) return null;
    return DateTime(year, month, day);
  }

  static String _ordinal(int n) => switch (n) {
        1 => '1st',
        2 => '2nd',
        3 => '3rd',
        _ => '${n}th',
      };

  static String _weekdayName(int weekday) => const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][(weekday - 1).clamp(0, 6)];
}
