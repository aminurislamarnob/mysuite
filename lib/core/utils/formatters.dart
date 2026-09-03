import 'package:intl/intl.dart';

/// Date, time and money formatting used across every module.
class Fmt {
  const Fmt._();

  static final _time = DateFormat('h:mm a');
  static final _dayMonth = DateFormat('MMM d');
  static final _dayMonthYear = DateFormat('MMM d, y');
  static final _weekday = DateFormat('EEE');
  static final _fullDate = DateFormat('EEEE, MMMM d');
  static final _monthYear = DateFormat('MMMM y');
  static final _iso = DateFormat('yyyy-MM-dd');

  static String time(DateTime d) => _time.format(d);
  static String dayMonth(DateTime d) => _dayMonth.format(d);
  static String dayMonthYear(DateTime d) => _dayMonthYear.format(d);
  static String weekday(DateTime d) => _weekday.format(d);
  static String fullDate(DateTime d) => _fullDate.format(d);
  static String monthYear(DateTime d) => _monthYear.format(d);
  static String iso(DateTime d) => _iso.format(d);

  /// Minutes-from-midnight rendered as a wall clock time.
  static String minutesOfDay(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final period = h < 12 ? 'AM' : 'PM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }

  /// "Today", "Tomorrow", "Yesterday", else a short date.
  static String relativeDay(DateTime d) {
    final today = dateOnly(DateTime.now());
    final target = dateOnly(d);
    final diff = target.difference(today).inDays;
    return switch (diff) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ when diff > 1 && diff < 7 => _weekday.format(d),
      _ =>
        target.year == today.year
            ? _dayMonth.format(d)
            : _dayMonthYear.format(d),
    };
  }

  /// Due-date label with the time appended when the task carries one.
  static String due(DateTime d, {bool withTime = false}) =>
      withTime ? '${relativeDay(d)} · ${time(d)}' : relativeDay(d);

  static String money(double amount, String symbol) {
    final f = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return f.format(amount);
  }

  /// An amount for a text field: no symbol and no grouping, with decimals
  /// only when the amount has them. [double.toString] gives the shortest
  /// string that parses back to the same number, so prefilling a field with
  /// this and reading it back cannot change the figure.
  static String amountInput(double amount) =>
      amount.truncateToDouble() == amount
      ? amount.toStringAsFixed(0)
      : amount.toString();

  static String compactMoney(double amount, String symbol) {
    if (amount.abs() >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  /// "1h 25m", "45m", "0m"
  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  static String durationFromMinutes(int minutes) =>
      duration(Duration(minutes: minutes));

  static String timerClock(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String percent(double fraction) =>
      '${(fraction * 100).clamp(0, 999).toStringAsFixed(0)}%';

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime startOfWeek(DateTime d) {
    final day = dateOnly(d);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime endOfMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 0, 23, 59, 59);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Up to two letters standing in for a name on an avatar. Empty for a name
  /// that is blank or has no letters in it, which the caller shows a glyph for
  /// rather than an empty circle.
  static String initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    // First and last, so "Md. Aminur Islam" reads as MI rather than MA.
    final letters = words.length == 1
        ? [words.first[0]]
        : [words.first[0], words.last[0]];
    return letters.join().toUpperCase();
  }
}
