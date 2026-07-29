import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/presentation/medicine/utils/schedule_generator.dart';

void main() {
  final start = DateTime(2026, 3, 1); // a Sunday

  group('ScheduleGenerator', () {
    test('expands N times a day across the course', () {
      final doses = ScheduleGenerator.generate(ScheduleSpec(
        start: start,
        end: DateTime(2026, 3, 7),
        doseMinutes: const [480, 1200],
      ));

      expect(doses.length, 14); // 7 days x 2
      expect(doses.first, DateTime(2026, 3, 1, 8));
      expect(doses[1], DateTime(2026, 3, 1, 20));
      expect(doses.last, DateTime(2026, 3, 7, 20));
    });

    test('honours skip dates for travel mode', () {
      final doses = ScheduleGenerator.generate(ScheduleSpec(
        start: start,
        end: DateTime(2026, 3, 5),
        doseMinutes: const [480],
        skipDates: {DateTime(2026, 3, 3), DateTime(2026, 3, 4)},
      ));

      expect(doses.length, 3);
      expect(doses.any((d) => d.day == 3), isFalse);
      expect(doses.any((d) => d.day == 4), isFalse);
    });

    test('every X hours rolls across midnight', () {
      final doses = ScheduleGenerator.generate(ScheduleSpec(
        start: start,
        end: DateTime(2026, 3, 2),
        frequency: MedFrequency.everyXHours,
        doseMinutes: const [480],
        intervalHours: 8,
      ));

      // 08:00 and 16:00 on the 1st, then midnight, 08:00 and 16:00 on the
      // 2nd. The next tick is midnight on the 3rd, past the end of the course.
      expect(doses.length, 5);
      expect(doses[2], DateTime(2026, 3, 2, 0));
      expect(doses.last, DateTime(2026, 3, 2, 16));
    });

    test('specific weekdays only generates on the selected days', () {
      // Bit 0 selects Monday.
      final doses = ScheduleGenerator.generate(ScheduleSpec(
        start: start,
        end: DateTime(2026, 3, 31),
        frequency: MedFrequency.specificWeekdays,
        doseMinutes: const [480],
        weekdayMask: 1 << 0,
      ));

      expect(doses.every((d) => d.weekday == DateTime.monday), isTrue);
      expect(doses.length, 5); // Mondays in March 2026
    });

    test('alternate days skips every other day', () {
      final doses = ScheduleGenerator.generate(ScheduleSpec(
        start: start,
        end: DateTime(2026, 3, 7),
        frequency: MedFrequency.alternateDays,
        doseMinutes: const [480],
      ));

      expect(doses.map((d) => d.day), [1, 3, 5, 7]);
    });

    test('returns nothing when the course ends before it starts', () {
      final doses = ScheduleGenerator.generate(ScheduleSpec(
        start: DateTime(2026, 3, 10),
        end: DateTime(2026, 3, 1),
      ));
      expect(doses, isEmpty);
    });

    test('predicts the date stock runs out', () {
      final spec = ScheduleSpec(
        start: start,
        end: DateTime(2026, 3, 10),
        doseMinutes: const [480, 1200],
      );

      // 5 units cover the first 5 doses; the 6th — the evening of day 3 — is
      // the one there is no stock left for.
      expect(ScheduleGenerator.runOutDate(spec, 5, 1), DateTime(2026, 3, 3, 20));
      expect(ScheduleGenerator.runOutDate(spec, 100, 1), isNull);
    });

    test('detects two medicines scheduled close together', () {
      final conflicts = ScheduleGenerator.findConflicts({
        'Amoxicillin': [DateTime(2026, 3, 1, 8)],
        'Ibuprofen': [DateTime(2026, 3, 1, 8, 15)],
        'Vitamin D': [DateTime(2026, 3, 1, 14)],
      });

      expect(conflicts.length, 1);
      expect({conflicts.first.first, conflicts.first.second},
          {'Amoxicillin', 'Ibuprofen'});
    });

    test('does not flag the same medicine against itself', () {
      final conflicts = ScheduleGenerator.findConflicts({
        'Amoxicillin': [DateTime(2026, 3, 1, 8), DateTime(2026, 3, 1, 8, 10)],
      });
      expect(conflicts, isEmpty);
    });
  });

  group('ScheduleSpec encoding', () {
    test('round-trips dose times', () {
      expect(ScheduleSpec.parseTimes('1200,480,840'), [480, 840, 1200]);
      expect(ScheduleSpec.encodeTimes([1200, 480]), '480,1200');
    });

    test('ignores malformed or out-of-range times', () {
      expect(ScheduleSpec.parseTimes('480,abc,,9999,-5'), [480]);
    });

    test('round-trips skip dates', () {
      final dates = {DateTime(2026, 3, 3), DateTime(2026, 12, 25)};
      final encoded = ScheduleSpec.encodeSkipDates(dates);
      expect(ScheduleSpec.parseSkipDates(encoded), dates);
    });
  });
}
