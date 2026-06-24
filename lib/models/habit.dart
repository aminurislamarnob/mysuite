import '../core/utils/formatters.dart';

enum HabitGoal { build, reduce }

extension HabitGoalX on HabitGoal {
  String get label => this == HabitGoal.build ? 'Build' : 'Reduce';
}

/// A habit tracked by daily quantity. [target] is a goal to reach (build) or a
/// ceiling to stay under (reduce). Daily totals live in [_log] keyed by date.
class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.unit,
    required this.target,
    required this.goal,
    required this.color,
    required this.iconCode,
    this.step = 1,
    Map<String, int>? log,
  }) : _log = log ?? {};

  final String id;
  String name;
  String unit;
  int target;
  HabitGoal goal;
  int color;
  int iconCode;
  int step;
  final Map<String, int> _log;

  int amountOn(DateTime day) => _log[Day.key(day)] ?? 0;

  void add(DateTime day, int delta) {
    final key = Day.key(day);
    final next = (_log[key] ?? 0) + delta;
    if (next <= 0) {
      _log.remove(key);
    } else {
      _log[key] = next;
    }
  }

  void setAmount(DateTime day, int value) {
    final key = Day.key(day);
    if (value <= 0) {
      _log.remove(key);
    } else {
      _log[key] = value;
    }
  }

  /// A day "succeeds" when build habits reach target, or reduce habits stay at
  /// or below it (and were logged or simply not exceeded).
  bool succeededOn(DateTime day) {
    final amount = amountOn(day);
    return goal == HabitGoal.build ? amount >= target : amount <= target;
  }

  double progressOn(DateTime day) {
    if (target <= 0) return 0;
    final amount = amountOn(day);
    if (goal == HabitGoal.build) {
      return (amount / target).clamp(0, 1).toDouble();
    }
    // For reduce habits, fuller bar = more "used up" of the allowance.
    return (amount / target).clamp(0, 1).toDouble();
  }

  /// Current consecutive-day streak ending today (or yesterday if today is not
  /// yet logged), counting days that met the goal.
  int currentStreak() {
    var streak = 0;
    var day = Day.today();
    // Build habits: today only counts once target met; allow chain from
    // yesterday so an unlogged "in-progress" today doesn't reset the streak.
    if (goal == HabitGoal.build && !succeededOn(day)) {
      day = day.subtract(const Duration(days: 1));
    }
    while (succeededOn(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
      if (streak > 3650) break;
    }
    return streak;
  }

  /// Quantities for the last [days] days (oldest first) for sparkline/heatmap.
  List<int> history(int days) {
    final today = Day.today();
    return List.generate(days, (i) {
      final d = today.subtract(Duration(days: days - 1 - i));
      return amountOn(d);
    });
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'target': target,
        'goal': goal.name,
        'color': color,
        'iconCode': iconCode,
        'step': step,
        'log': _log,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String? ?? '',
        target: json['target'] as int? ?? 1,
        goal: HabitGoal.values.byName(json['goal'] as String? ?? 'build'),
        color: json['color'] as int? ?? 0xFF10B981,
        iconCode: json['iconCode'] as int? ?? 0,
        step: json['step'] as int? ?? 1,
        log: (json['log'] as Map?)?.map(
          (k, v) => MapEntry(k as String, (v as num).toInt()),
        ),
      );
}
