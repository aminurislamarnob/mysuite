import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/utils/formatters.dart';

void main() {
  group('compactMoney', () {
    test('puts the sign before the symbol, as money() does', () {
      // Insights showed '৳-1.3k' next to an Expenses screen showing '-৳1,325'.
      expect(Fmt.compactMoney(-1325, '৳'), '-৳1.3k');
      expect(Fmt.compactMoney(-42, '৳'), '-৳42');
      expect(Fmt.compactMoney(-2500000, r'$'), r'-$2.5M');
    });

    test('positive amounts carry no sign', () {
      expect(Fmt.compactMoney(1325, '৳'), '৳1.3k');
      expect(Fmt.compactMoney(0, '৳'), '৳0');
    });
  });

  test('headerDate abbreviates the month so it fits beside the actions', () {
    // 'Wednesday, September 30' at 17px overflowed the greeting row once a
    // third action button joined it.
    expect(Fmt.headerDate(DateTime(2026, 9, 30)), 'Wednesday, Sep 30');
    expect(Fmt.fullDate(DateTime(2026, 9, 30)), 'Wednesday, September 30');
  });
}
