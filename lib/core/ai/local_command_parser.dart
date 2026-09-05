import '../../presentation/expenses/utils/expense_voice_parser.dart';
import '../../presentation/medicine/utils/schedule_generator.dart';
import '../../presentation/tasks/utils/nlp_parser.dart';
import 'ai_action.dart';
import 'ai_request_context.dart';

/// The offline fallback: no key, no network, the same screen still works.
///
/// It is deliberately a router over the parsers the app already had, not a
/// second natural-language engine. Each clause is sent to whichever of them
/// its cue words point at, and the result is the same [AiAction] list a
/// provider would return, so everything downstream is shared. It understands
/// English and Banglish cues; Bangla script is left to the model.
class LocalCommandParser {
  const LocalCommandParser._();

  static const _verbCues =
      r'spent|paid|bought|remind|add|log|note|start|call|buy|take|drank|had|'
      r'write|pay|earned|received|got|drink|read|walk';

  /// Splits on commas and semicolons, and on "and"-like words only when a
  /// new verb follows, so "bread and butter 120 taka" stays one expense.
  static final _clauseSplit = RegExp(
    r'\s*[,;]\s*|\s+(?:and|then|also|plus|ar|ebong)\s+(?=(?:' +
        _verbCues +
        r')\b)',
    caseSensitive: false,
  );

  static final _leadingConjunction = RegExp(
    r'^(?:and|then|also|plus|ar|ebong)\s+',
    caseSensitive: false,
  );

  static final _medicineCue = RegExp(
    r'\b(?:\d+|once|twice|thrice|one|two|three|four)\s*(?:times?|x)?\s*(?:a|per)\s*day\b|'
    r'\bmg\b|\btablets?\b|\bcapsules?\b|\bsyrup\b|\bmedicine\b|\bfor\s+\d+\s+days?\b',
    caseSensitive: false,
  );
  static final _moneyCue = RegExp(
    r'\b(?:spent|spend|paid|pay|bought|buy|cost|costs|taka|tk|bdt|earned|'
    r'received|salary|income|refund|got paid|kharoch|khoroch|bhara|dam)\b|৳',
    caseSensitive: false,
  );
  static final _amount = RegExp(r'\d[\d,]*(?:\.\d+)?');
  static final _focusCue = RegExp(
    r'\b(?:focus|pomodoro)\b',
    caseSensitive: false,
  );
  static final _noteCue = RegExp(
    r'^(?:note|write down|note down|jot down|jot|remember)(?:\s+that)?\b\s*',
    caseSensitive: false,
  );
  static final _taskPrefix = RegExp(
    r'^(?:remind me to|remind me|reminder to|reminder|add (?:a )?task(?: to)?|'
    r'task|to do|todo|i need to|i have to)\b\s*',
    caseSensitive: false,
  );

  static const _numberWords = <String, int>{
    'one': 1,
    'once': 1,
    'two': 2,
    'twice': 2,
    'three': 3,
    'thrice': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
  };

  static AiCommandResult parse(
    String transcript, {
    required AiRequestContext context,
    DateTime? now,
  }) {
    final reference = now ?? context.now;
    final actions = <AiAction>[];
    var incomplete = false;

    // "1,200" is one number, not a clause break; drop the separator before
    // splitting on commas.
    final flat = transcript.replaceAllMapped(
      RegExp(r'(\d),(\d{3})\b'),
      (m) => '${m.group(1)}${m.group(2)}',
    );
    for (final raw in flat.split(_clauseSplit)) {
      // ", and add Napa" splits at the comma and keeps its conjunction.
      final clause = raw.trim().replaceFirst(_leadingConjunction, '').trim();
      if (clause.isEmpty) continue;
      final action = _route(clause, context, reference);
      if (action == null) {
        incomplete = true;
      } else {
        actions.add(action);
      }
    }

    return AiCommandResult(
      actions: actions,
      needsClarification: actions.isEmpty || incomplete,
      source: const OfflineSource(),
    );
  }

  static AiAction? _route(String clause, AiRequestContext c, DateTime now) {
    final lower = clause.toLowerCase();
    final hasMoney = _moneyCue.hasMatch(lower);

    if (_medicineCue.hasMatch(lower) && !hasMoney) {
      return _medicine(clause, lower);
    }
    if (_focusCue.hasMatch(lower)) return _focus(lower);

    // "Remind me to walk the dog" is a task even when a habit is called
    // Walk, so the task prefix is checked before the habit names.
    if (_taskPrefix.hasMatch(clause) && !hasMoney) {
      return _task(clause, lower, now);
    }

    final habit = _habit(lower, c);
    if (habit != null && !hasMoney) return habit;

    final amount = _amount.firstMatch(lower.replaceAll('৳', ' '));
    if (amount != null &&
        (hasMoney ||
            c.accounts.any((a) => _mentions(lower, a.name)) ||
            c.categories.any((x) => _mentions(lower, x.name)))) {
      return _expense(clause, c);
    }

    if (_noteCue.hasMatch(clause)) return _note(clause);
    return _task(clause, lower, now);
  }

  /// Whole-word containment, so the seeded "Other" category does not match
  /// inside "brother".
  static bool _mentions(String lower, String name) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return false;
    return RegExp('\\b${RegExp.escape(n)}\\b').hasMatch(lower);
  }

  static AiAction? _expense(String clause, AiRequestContext c) {
    final parsed = ExpenseVoiceParser.parse(
      clause,
      categories: c.categories,
      accounts: c.accounts,
    );
    if (parsed.amount == null || parsed.amount! <= 0) return null;
    final category = c.categories
        .where((x) => x.id == parsed.categoryId)
        .firstOrNull;
    final account = c.accounts
        .where((a) => a.id == parsed.accountId)
        .firstOrNull;
    // The account name is bookkeeping, not a description of what was bought.
    var note = parsed.note;
    if (account != null) {
      note = note
          .replaceAll(
            RegExp(
              '\\b(?:${RegExp.escape(account.name)}|${RegExp.escape(account.type)})\\b',
              caseSensitive: false,
            ),
            ' ',
          )
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }
    return AddExpenseAction(
      amount: parsed.amount!,
      txKind: parsed.kind ?? 0,
      category: category?.name,
      account: account?.name,
      note: note.isEmpty ? null : _capitalise(note),
    );
  }

  static AiAction? _medicine(String clause, String lower) {
    int? timesPerDay;
    final times = RegExp(
      r'\b(\d+|once|twice|thrice|one|two|three|four)\s*(?:times?|x)?\s*(?:a|per)\s*day\b',
    ).firstMatch(lower);
    if (times != null) timesPerDay = _number(times.group(1)!);

    final days = RegExp(r'\bfor\s+(\d+)\s+days?\b').firstMatch(lower);

    String? meal;
    if (RegExp(r'\bafter\s+(?:food|meals?|eating)').hasMatch(lower)) {
      meal = MealRelation.after.token;
    } else if (RegExp(r'\bbefore\s+(?:food|meals?|eating)').hasMatch(lower)) {
      meal = MealRelation.before.token;
    } else if (RegExp(r'\bwith\s+(?:food|meals?)').hasMatch(lower)) {
      meal = MealRelation.with_.token;
    }

    double? dosage;
    String? unit;
    final dose = RegExp(
      r'\b(\d+(?:\.\d+)?)\s*(mg|ml|tablets?|capsules?|drops?|spoons?)\b',
    ).firstMatch(lower);
    if (dose != null) {
      dosage = double.tryParse(dose.group(1)!);
      unit = dose.group(2)!.replaceAll(RegExp(r's$'), '');
    }

    String? form;
    for (final f in const [
      'tablet',
      'capsule',
      'syrup',
      'injection',
      'drops',
      'inhaler',
    ]) {
      if (RegExp('\\b$f').hasMatch(lower)) {
        form = f;
        break;
      }
    }

    final name = clause
        .replaceAll(
          RegExp(
            r'\b(?:add|take|start|medicine|for|days?|times?|a day|per day|a|per|'
            r'once|twice|thrice|one|two|three|four|after|before|with|food|meals?|'
            r'eating|mg|ml|tablets?|capsules?|drops?|spoons?|syrup|x|the|my|me|to)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'\d+(?:\.\d+)?'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (name.isEmpty) return null;

    return AddMedicineAction(
      name: _capitalise(name),
      form: form,
      dosage: dosage,
      dosageUnit: unit,
      timesPerDay: timesPerDay,
      days: days == null ? null : int.tryParse(days.group(1)!),
      mealRelation: meal,
    );
  }

  static AiAction _focus(String lower) {
    final m = RegExp(r'(\d+)\s*(?:min|mins|minutes?)\b').firstMatch(lower);
    return StartFocusAction(minutes: m == null ? 25 : int.parse(m.group(1)!));
  }

  /// True when a word of the clause is the habit's name or shares a stem with
  /// it, so "read ten pages" reaches a habit called "Reading".
  static bool _mentionsHabit(String lower, String name) {
    if (name.contains(' ')) return lower.contains(name);
    for (final word in lower.split(RegExp(r'[^a-zঀ-৿]+'))) {
      if (word.isEmpty) continue;
      if (word == name) return true;
      if (word.length >= 4 && name.startsWith(word)) return true;
      if (name.length >= 4 && word.startsWith(name)) return true;
    }
    return false;
  }

  static AiAction? _habit(String lower, AiRequestContext c) {
    for (final h in c.habits) {
      final name = h.name.trim().toLowerCase();
      if (name.isEmpty || !_mentionsHabit(lower, name)) continue;
      var amount = 1.0;
      final digits = RegExp(r'\d+(?:\.\d+)?').firstMatch(lower);
      if (digits != null) {
        amount = double.parse(digits.group(0)!);
      } else {
        for (final e in _numberWords.entries) {
          if (RegExp('\\b${e.key}\\b').hasMatch(lower)) {
            amount = e.value.toDouble();
            break;
          }
        }
      }
      return LogHabitAction(habit: h.name, amount: amount);
    }
    return null;
  }

  static AiAction _note(String clause) {
    final body = clause.replaceFirst(_noteCue, '').trim();
    final words = body.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final title = _capitalise(words.take(6).join(' '));
    return AddNoteAction(title: title.isEmpty ? 'Note' : title, body: body);
  }

  /// A bare "at 5" in speech almost always means the afternoon; the quick-add
  /// parser reads it as 05:00 and then rolls it to tomorrow morning.
  static final _bareSmallHour = RegExp(
    r'\bat\s+([1-7])(?::(\d{2}))?\b(?!\s*[ap]\.?m)',
    caseSensitive: false,
  );

  static AiAction? _task(String clause, String lower, DateTime now) {
    var stripped = clause.replaceFirst(_taskPrefix, '').trim();
    if (stripped.isEmpty) return null;
    stripped = stripped.replaceAllMapped(
      _bareSmallHour,
      (m) => 'at ${m.group(1)}${m.group(2) == null ? '' : ':${m.group(2)}'}pm',
    );
    final parsed = NlpParser.parse(stripped, now: now);
    final wantsReminder = lower.contains('remind') && parsed.hasTime;
    return AddTaskAction(
      title: _capitalise(parsed.title),
      dueDate: parsed.dueDate,
      hasTime: parsed.hasTime,
      reminder: wantsReminder ? parsed.dueDate : null,
      priority: parsed.priority,
      recurrence: parsed.recurrenceRule,
      tags: parsed.tags,
    );
  }

  static int _number(String token) =>
      int.tryParse(token) ?? _numberWords[token] ?? 1;

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
