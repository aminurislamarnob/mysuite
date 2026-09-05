import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/ai/name_resolver.dart';
import 'package:mysuite/presentation/expenses/utils/expense_voice_parser.dart';

import 'ai_fixtures.dart';

void main() {
  final categories = seededContext().categories;
  final accounts = seededContext().accounts;

  test('exact match ignores case and marks itself exact', () {
    final r = NameResolver.resolve('food', categories, (c) => [c.name]);
    expect(r!.item.name, 'Food');
    expect(r.exact, isTrue);
  });

  test('containment either way, preferring the longest name', () {
    final r = NameResolver.resolve(
      'bkash account',
      accounts,
      (a) => [a.name, a.type],
    );
    expect(r!.item.name, 'bKash');
    expect(r.exact, isFalse);
    final byType = NameResolver.resolve(
      'cash',
      accounts,
      (a) => [a.name, a.type],
    );
    expect(byType!.item.name, 'Cash');
  });

  test('hint words match against the haystack', () {
    final r = NameResolver.resolve(
      null,
      categories,
      (c) => [c.name],
      hints: ExpenseVoiceParser.categoryHints,
      haystack: 'lunch with friends',
    );
    expect(r!.item.name, 'Food');
    expect(r.exact, isFalse);
  });

  test('nothing matches → null, and the list is untouched', () {
    final before = List.of(categories);
    expect(NameResolver.resolve('crypto', categories, (c) => [c.name]), isNull);
    expect(NameResolver.resolve('', categories, (c) => [c.name]), isNull);
    expect(categories, before);
  });
}
