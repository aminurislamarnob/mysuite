import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Locale-aware formatting helpers. Currency defaults to BDT (৳) per the spec's
/// local-relevance focus, but the symbol is parameterized for multi-currency.
class Fmt {
  Fmt._();

  static final _date = DateFormat('EEE, d MMM');
  static final _dateFull = DateFormat('d MMM yyyy');
  static final _month = DateFormat('MMMM yyyy');
  static final _weekday = DateFormat('EEE');

  static String date(DateTime d) => _date.format(d);
  static String dateFull(DateTime d) => _dateFull.format(d);
  static String month(DateTime d) => _month.format(d);
  static String weekday(DateTime d) => _weekday.format(d);

  static String time(BuildContext context, TimeOfDay t) => t.format(context);

  static String timeOfDate(BuildContext context, DateTime d) =>
      TimeOfDay.fromDateTime(d).format(context);

  static String money(num amount, {String symbol = '৳'}) {
    final f = NumberFormat.currency(symbol: symbol, decimalDigits: 0);
    return f.format(amount);
  }

  static String relativeDay(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1 && diff < 7) return _weekday.format(d);
    return _date.format(d);
  }

  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  static String clock(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// Date-only helpers used across modules for streaks, heatmaps and "today".
class Day {
  Day._();

  static DateTime only(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime today() => only(DateTime.now());
  static String key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static bool same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
