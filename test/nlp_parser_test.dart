import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/presentation/tasks/utils/nlp_parser.dart';
import 'package:mysuite/presentation/tasks/utils/recurrence.dart';

void main() {
  // 2026-03-02 is a Monday.
  final now = DateTime(2026, 3, 2, 9);

  group('NlpParser', () {
    test('parses the example from the spec', () {
      final r = NlpParser.parse(
        'Buy milk tomorrow 5pm #shopping !high',
        now: now,
      );

      expect(r.title, 'Buy milk');
      expect(r.dueDate, DateTime(2026, 3, 3, 17));
      expect(r.hasTime, isTrue);
      expect(r.priority, 1);
      expect(r.tags, ['shopping']);
    });

    test('parses weekday names as the next occurrence', () {
      final r = NlpParser.parse('Call the clinic friday', now: now);
      expect(r.dueDate, DateTime(2026, 3, 6));
      expect(r.title, 'Call the clinic');
    });

    test('a bare weekday never resolves to today', () {
      final r = NlpParser.parse('Review monday', now: now);
      expect(r.dueDate, DateTime(2026, 3, 9));
    });

    test('parses recurrence and estimate tokens', () {
      final r = NlpParser.parse('Standup *daily ~15m', now: now);
      expect(r.recurrenceRule, 'daily');
      expect(r.estimateMinutes, 15);
      expect(r.title, 'Standup');
    });

    test('parses "every 3 days" phrasing', () {
      final r = NlpParser.parse('Water plants every 3 days', now: now);
      expect(r.recurrenceRule, 'every:3');
      expect(r.title, 'Water plants');
    });

    test('parses a textual date', () {
      final r = NlpParser.parse('Renew passport 25 Dec', now: now);
      expect(r.dueDate, DateTime(2026, 12, 25));
      expect(r.title, 'Renew passport');
    });

    test('parses a numeric date', () {
      final r = NlpParser.parse('Pay rent 15/4', now: now);
      expect(r.dueDate, DateTime(2026, 4, 15));
    });

    test('collects multiple tags', () {
      final r = NlpParser.parse('Book flights #travel #work', now: now);
      expect(r.tags, ['travel', 'work']);
      expect(r.title, 'Book flights');
    });

    test('hour-only estimates convert to minutes', () {
      final r = NlpParser.parse('Deep work ~2h', now: now);
      expect(r.estimateMinutes, 120);
    });

    test('keeps the whole input when nothing is recognised', () {
      final r = NlpParser.parse('Think about it', now: now);
      expect(r.title, 'Think about it');
      expect(r.dueDate, isNull);
      expect(r.priority, 4);
      expect(r.tags, isEmpty);
    });
  });

  group('Recurrence', () {
    test('daily and weekly advance correctly', () {
      expect(
        Recurrence.nextOccurrence('daily', DateTime(2026, 3, 2)),
        DateTime(2026, 3, 3),
      );
      expect(
        Recurrence.nextOccurrence('weekly', DateTime(2026, 3, 2)),
        DateTime(2026, 3, 9),
      );
    });

    test('weekdays skips the weekend', () {
      // Friday 2026-03-06 -> Monday 2026-03-09
      expect(
        Recurrence.nextOccurrence('weekdays', DateTime(2026, 3, 6)),
        DateTime(2026, 3, 9),
      );
    });

    test('monthly clamps to the shortest month', () {
      expect(
        Recurrence.nextOccurrence('monthly', DateTime(2026, 1, 31)),
        DateTime(2026, 2, 28),
      );
    });

    test('every:N advances by N days', () {
      expect(
        Recurrence.nextOccurrence('every:10', DateTime(2026, 3, 2)),
        DateTime(2026, 3, 12),
      );
    });

    test('nth weekday of the month', () {
      // The 2nd Monday of March 2026 is the 9th.
      expect(
        Recurrence.nextOccurrence('nth:2:1', DateTime(2026, 3, 2)),
        DateTime(2026, 3, 9),
      );
    });

    test('unknown rules return null', () {
      expect(
        Recurrence.nextOccurrence('nonsense', DateTime(2026, 3, 2)),
        isNull,
      );
    });

    test('labels read naturally', () {
      expect(Recurrence.label(null), 'Does not repeat');
      expect(Recurrence.label('weekdays'), 'Every weekday');
      expect(Recurrence.label('every:3'), 'Every 3 days');
      expect(Recurrence.label('nth:2:1'), 'Every 2nd Monday');
    });
  });
}
