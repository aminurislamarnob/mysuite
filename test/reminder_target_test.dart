import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/services/reminder_target.dart';

void main() {
  test('each reminder kind opens its module', () {
    expect(ReminderTarget.parse('dose:7')!.route, '/medicine');
    expect(ReminderTarget.parse('task:7')!.route, '/tasks');
    expect(ReminderTarget.parse('habit:7')!.route, '/habits');
    expect(ReminderTarget.parse('bill:7')!.route, '/expenses');
    expect(ReminderTarget.parse('loan:7')!.route, '/expenses');
  });

  test('a note opens in its editor', () {
    final target = ReminderTarget.parse('note:42')!;
    expect(target.route, '/note_editor');
    expect(target.extra, 42);
  });

  test('modules other than notes pass nothing through', () {
    expect(ReminderTarget.parse('task:7')!.extra, isNull);
  });

  test('anything malformed is ignored rather than routed', () {
    expect(ReminderTarget.parse(null), isNull);
    expect(ReminderTarget.parse(''), isNull);
    expect(ReminderTarget.parse('task'), isNull);
    expect(ReminderTarget.parse(':7'), isNull);
    expect(ReminderTarget.parse('task:seven'), isNull);
    expect(ReminderTarget.parse('focus:1'), isNull);
  });
}
