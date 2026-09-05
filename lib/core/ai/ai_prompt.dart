import 'package:intl/intl.dart';

import '../settings/app_settings.dart';
import 'ai_action.dart';
import 'ai_request_context.dart';

/// Builds the two halves of every request.
///
/// The system prompt is the app's vocabulary and rules; the user message is
/// the transcript alone. Keeping the transcript out of the system half means
/// the stable part is identical between requests, which is what lets a
/// provider cache it.
class AiPromptBuilder {
  const AiPromptBuilder._();

  static String system(AiRequestContext c) {
    final b = StringBuffer();
    final now = c.now;
    final offset = now.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hh = offset.inHours.abs().toString().padLeft(2, '0');
    final mm = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    b.writeln(
      'You convert one spoken command for the mySuite personal organiser '
      'into structured actions. Reply only with the JSON the schema asks for.',
    );
    b.writeln();
    b.writeln(
      'Today is ${AiDates.date(now)} (${DateFormat.EEEE().format(now)}), '
      'local time ${AiDates.time(now)}, UTC offset $sign$hh:$mm.',
    );
    b.writeln(
      'Currency: ${c.currencySymbol} (BDT). "taka", "tk" and "৳" all mean it.',
    );
    b.writeln(
      'The user may speak English, Bangla script, or Banglish (Bangla in '
      'Latin letters). Write titles in the language the user used.',
    );
    b.writeln();

    b.writeln('Rules:');
    b.writeln('- One action per thing the user asked for; several are fine.');
    b.writeln(
      '- Names of categories, accounts, people, habits and projects must be '
      'copied exactly from the lists below. If nothing matches, use null; '
      'never invent a new one.',
    );
    b.writeln(
      '- Dates are absolute yyyy-MM-dd; resolve "tomorrow", "next Friday" '
      'and similar against today. Times are 24-hour HH:mm.',
    );
    b.writeln(
      '- "Remind me" means add_task with a reminder at the spoken time, and '
      'the same date and time as the due date.',
    );
    b.writeln(
      '- For add_medicine give times_per_day and leave dose_times null unless '
      'the user said clock times; the app fills in sensible hours.',
    );
    b.writeln(
      '- Spent, paid, bought, cost mean an expense; earned, received, salary, '
      'refund mean income.',
    );
    b.writeln(
      '- Set needs_clarification only when an amount or a name that the '
      'action cannot work without is missing. Otherwise guess sensibly and '
      'say nothing.',
    );
    b.writeln('- reply is at most one short sentence, usually empty.');

    final allowed = AiActionKind.values.where((k) => c.isEnabled(k.module));
    final blocked = AiActionKind.values.where((k) => !c.isEnabled(k.module));
    b.writeln('- Allowed kinds: ${allowed.map((k) => k.wire).join(', ')}.');
    if (blocked.isNotEmpty) {
      b.writeln(
        '- Not allowed (module switched off, do not use): '
        '${blocked.map((k) => k.wire).join(', ')}.',
      );
    }
    b.writeln();

    if (c.isEnabled(AppModule.expenses)) {
      _list(
        b,
        'Expense categories',
        c.categories.where((x) => !x.isIncome).map((x) => x.name),
      );
      _list(
        b,
        'Income categories',
        c.categories.where((x) => x.isIncome).map((x) => x.name),
      );
      _list(b, 'Accounts', c.accounts.map((x) => x.name));
    }
    _list(
      b,
      'People',
      c.people.map((p) => p.isSelf ? '${p.name} (me)' : p.name),
    );
    if (c.isEnabled(AppModule.habits)) {
      _list(
        b,
        'Habits',
        c.habits.map((h) => h.unit == null ? h.name : '${h.name} (${h.unit})'),
      );
    }
    if (c.isEnabled(AppModule.tasks)) {
      _list(b, 'Projects', c.projects.map((p) => p.name));
    }
    if (c.isEnabled(AppModule.medicine)) {
      _list(b, 'Medicine profiles', c.profiles.map((p) => p.name));
    }
    b.writeln();

    // Worked examples only for kinds the user can actually use, so the
    // prompt never demonstrates an action it has just forbidden.
    final examples = <(String, String)>[
      if (c.isEnabled(AppModule.expenses))
        (
          'spent 200 taka on lunch with bKash',
          'add_expense {title "Lunch", amount 200, kind_detail "expense", '
              'category "Food", account "bKash"}',
        ),
      if (c.isEnabled(AppModule.tasks))
        (
          'remind me to call the doctor at 5',
          'add_task {title "Call the doctor", date "${AiDates.date(now)}", '
              'time "17:00", reminder "${AiDates.date(now)}T17:00"}',
        ),
      if (c.isEnabled(AppModule.medicine))
        (
          'add Napa 3 times a day for 5 days after food',
          'add_medicine {title "Napa", times_per_day 3, days 5, '
              'meal_relation "after"}',
        ),
      if (c.isEnabled(AppModule.expenses))
        (
          'rickshaw bhara 40 taka cash',
          'add_expense {title "Rickshaw fare", amount 40, kind_detail '
              '"expense", category "Transport", account "Cash"}',
        ),
      if (c.isEnabled(AppModule.habits))
        (
          'drank two glasses of water',
          'log_habit {habit "Water", habit_amount 2}',
        ),
    ];
    if (examples.isNotEmpty) {
      b.writeln('Examples (today is ${AiDates.date(now)}):');
      if (examples.length >= 2) {
        // One combined sentence first, so multi-action commands are expected.
        b.writeln(
          'User: "${examples[0].$1} and ${examples[1].$1}" → actions: '
          '${examples[0].$2}; ${examples[1].$2}.',
        );
      }
      for (final (spoken, action) in examples.skip(2)) {
        b.writeln('User: "$spoken" → actions: $action.');
      }
    }
    return b.toString();
  }

  static String user(String transcript) => transcript.trim();

  static void _list(StringBuffer b, String label, Iterable<String> names) {
    final items = names.map((n) => n.trim()).where((n) => n.isNotEmpty);
    if (items.isEmpty) return;
    b.writeln('$label: ${items.map((n) => '"$n"').join(', ')}');
  }
}
