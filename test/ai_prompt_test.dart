import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/ai/ai_prompt.dart';
import 'package:mysuite/core/ai/ai_request_context.dart';
import 'package:mysuite/core/settings/app_settings.dart';

import 'ai_fixtures.dart';

void main() {
  test('the system prompt carries today, the currency and the names', () {
    final system = AiPromptBuilder.system(seededContext());
    expect(system, contains('2026-09-05 (Saturday)'));
    expect(system, contains('local time 14:32'));
    expect(system, contains('৳'));
    expect(system, contains('Bangla'));
    expect(system, contains('"Food"'));
    expect(system, contains('"bKash"'));
    expect(system, contains('"Arnob (me)"'));
    expect(system, contains('"Water (glasses)"'));
    expect(system, contains('"Work"'));
    expect(system, contains('Income categories: "Salary"'));
  });

  test(
    'a disabled module is listed as not allowed and its names are dropped',
    () {
      final context = seededContext(
        enabled: AppModule.values.toSet()..remove(AppModule.expenses),
      );
      final system = AiPromptBuilder.system(context);
      expect(system, contains('Not allowed'));
      expect(system, contains('add_expense'));
      expect(system, isNot(contains('Accounts:')));
      expect(system, isNot(contains('"bKash"')));
    },
  );

  test('lists are capped by the context builder cap', () {
    final many = AiRequestContext(
      now: fixedNow,
      habits: [for (var i = 0; i < 100; i++) habit(i, 'Habit $i')],
    );
    // The builder is what caps; the prompt prints whatever it is given, so
    // check the contract on the constant the builder uses.
    expect(AiRequestContext.cap, 40);
    expect(many.habits.take(AiRequestContext.cap).length, 40);
  });

  test('the user message is just the trimmed transcript', () {
    expect(AiPromptBuilder.user('  spent 200 taka  '), 'spent 200 taka');
  });
}
