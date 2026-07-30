import 'package:flutter/foundation.dart';

/// How the doses of a course repeat.
enum MedFrequency {
  /// N fixed times a day, taken from [ScheduleSpec.doseMinutes].
  timesPerDay,

  /// Every X hours starting from the first entry in [ScheduleSpec.doseMinutes].
  everyXHours,

  /// Only on the weekdays selected in [ScheduleSpec.weekdayMask].
  specificWeekdays,

  /// Every other day starting from [ScheduleSpec.start].
  alternateDays,
}

/// When the dose should be taken relative to a meal.
enum MealRelation { none, before, after, with_ }

extension MealRelationX on MealRelation {
  String get token => switch (this) {
    MealRelation.none => 'none',
    MealRelation.before => 'before',
    MealRelation.after => 'after',
    MealRelation.with_ => 'with',
  };

  String get label => switch (this) {
    MealRelation.none => '',
    MealRelation.before => 'Before food',
    MealRelation.after => 'After food',
    MealRelation.with_ => 'With food',
  };

  static MealRelation fromToken(String t) => switch (t) {
    'before' => MealRelation.before,
    'after' => MealRelation.after,
    'with' => MealRelation.with_,
    _ => MealRelation.none,
  };
}

/// A pure description of a medicine course. Deliberately free of database
/// types so the generator can be unit-tested without a database.
@immutable
class ScheduleSpec {
  final DateTime start;
  final DateTime end;
  final MedFrequency frequency;

  /// Times of day expressed as minutes from midnight, e.g. 480 == 08:00.
  final List<int> doseMinutes;

  /// Only meaningful when [frequency] is [MedFrequency.everyXHours].
  final int intervalHours;

  /// Bit 0 = Monday … bit 6 = Sunday. Only used for
  /// [MedFrequency.specificWeekdays].
  final int weekdayMask;

  /// Calendar days to skip entirely (travel or holiday mode).
  final Set<DateTime> skipDates;

  const ScheduleSpec({
    required this.start,
    required this.end,
    this.frequency = MedFrequency.timesPerDay,
    this.doseMinutes = const [480],
    this.intervalHours = 8,
    this.weekdayMask = 127,
    this.skipDates = const {},
  });

  /// Parses the comma-separated `"480,840,1200"` form used in the database.
  static List<int> parseTimes(String raw) {
    return raw
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .where((m) => m >= 0 && m < 1440)
        .toList()
      ..sort();
  }

  static String encodeTimes(List<int> minutes) =>
      (minutes.toList()..sort()).join(',');

  static Set<DateTime> parseSkipDates(String raw) {
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  static String encodeSkipDates(Set<DateTime> dates) => dates
      .map(
        (d) =>
            '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      )
      .join(',');
}

/// Expands a [ScheduleSpec] into the concrete dose timestamps of the course.
///
/// This is the engine behind the Monthly Schedule Generator: every calendar,
/// timeline, table and per-medicine view renders the list it returns.
class ScheduleGenerator {
  const ScheduleGenerator._();

  static List<DateTime> generate(ScheduleSpec spec) {
    final startDay = _dateOnly(spec.start);
    final endDay = _dateOnly(spec.end);
    if (endDay.isBefore(startDay)) return const [];

    final times = spec.doseMinutes.isEmpty ? const [480] : spec.doseMinutes;
    final result = <DateTime>[];

    if (spec.frequency == MedFrequency.everyXHours) {
      final interval = spec.intervalHours.clamp(1, 24);
      // Anchor the rolling schedule at the first requested time of day.
      var cursor = startDay.add(Duration(minutes: times.first));
      final hardEnd = endDay.add(const Duration(days: 1));
      while (cursor.isBefore(hardEnd)) {
        if (!spec.skipDates.contains(_dateOnly(cursor))) result.add(cursor);
        cursor = cursor.add(Duration(hours: interval));
      }
      return result;
    }

    var day = startDay;
    var dayIndex = 0;
    while (!day.isAfter(endDay)) {
      if (_dayIsActive(spec, day, dayIndex) && !spec.skipDates.contains(day)) {
        for (final m in times) {
          result.add(day.add(Duration(minutes: m)));
        }
      }
      day = day.add(const Duration(days: 1));
      dayIndex++;
    }
    result.sort();
    return result;
  }

  static bool _dayIsActive(ScheduleSpec spec, DateTime day, int dayIndex) {
    switch (spec.frequency) {
      case MedFrequency.specificWeekdays:
        // DateTime.weekday is 1 (Mon) … 7 (Sun); bit 0 represents Monday.
        return (spec.weekdayMask & (1 << (day.weekday - 1))) != 0;
      case MedFrequency.alternateDays:
        return dayIndex.isEven;
      case MedFrequency.timesPerDay:
      case MedFrequency.everyXHours:
        return true;
    }
  }

  /// Total doses the course will require, used for the inventory forecast.
  static int totalDoses(ScheduleSpec spec) => generate(spec).length;

  /// The date stock runs out, given [inventory] units and [unitsPerDose].
  /// Returns null when the supply covers the whole course.
  static DateTime? runOutDate(
    ScheduleSpec spec,
    int inventory,
    double unitsPerDose,
  ) {
    if (unitsPerDose <= 0) return null;
    final doses = generate(spec);
    var remaining = inventory.toDouble();
    for (final dose in doses) {
      remaining -= unitsPerDose;
      if (remaining < 0) return dose;
    }
    return null;
  }

  /// Flags doses of different medicines scheduled within [window] of each
  /// other, which is how the conflict warning on the schedule preview is built.
  static List<DoseConflict> findConflicts(
    Map<String, List<DateTime>> byMedicine, {
    Duration window = const Duration(minutes: 30),
  }) {
    final flat = <({String name, DateTime at})>[];
    byMedicine.forEach((name, times) {
      for (final t in times) {
        flat.add((name: name, at: t));
      }
    });
    flat.sort((a, b) => a.at.compareTo(b.at));

    final conflicts = <DoseConflict>[];
    for (var i = 0; i < flat.length; i++) {
      for (var j = i + 1; j < flat.length; j++) {
        final delta = flat[j].at.difference(flat[i].at).abs();
        if (delta > window) break;
        if (flat[i].name != flat[j].name) {
          conflicts.add(
            DoseConflict(
              first: flat[i].name,
              second: flat[j].name,
              at: flat[i].at,
            ),
          );
        }
      }
    }
    return conflicts;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

@immutable
class DoseConflict {
  final String first;
  final String second;
  final DateTime at;

  const DoseConflict({
    required this.first,
    required this.second,
    required this.at,
  });
}
