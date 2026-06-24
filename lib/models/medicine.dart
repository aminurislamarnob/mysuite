import '../core/utils/formatters.dart';

enum MedForm { tablet, capsule, syrup, injection, drops, inhaler }

enum MealRule { none, before, after, withFood }

extension MedFormX on MedForm {
  String get label => switch (this) {
        MedForm.tablet => 'Tablet',
        MedForm.capsule => 'Capsule',
        MedForm.syrup => 'Syrup',
        MedForm.injection => 'Injection',
        MedForm.drops => 'Drops',
        MedForm.inhaler => 'Inhaler',
      };
}

extension MealRuleX on MealRule {
  String get label => switch (this) {
        MealRule.none => 'Any time',
        MealRule.before => 'Before food',
        MealRule.after => 'After food',
        MealRule.withFood => 'With food',
      };
}

/// A medicine course. Doses are generated from [times] across [startDate]..
/// [endDate] (the spec's "Monthly Schedule Generator"). Intake is tracked
/// per-day, per-time in [_taken] using a "yyyy-MM-dd@HH:mm" key.
class Medicine {
  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.form,
    required this.times,
    required this.startDate,
    required this.endDate,
    this.mealRule = MealRule.none,
    this.profile = 'Self',
    this.stock,
    Map<String, bool>? taken,
  }) : _taken = taken ?? {};

  final String id;
  String name;
  String dosage;
  MedForm form;

  /// Daily reminder times as minutes-from-midnight (e.g. 8:00 => 480).
  List<int> times;
  DateTime startDate;
  DateTime endDate;
  MealRule mealRule;
  String profile;
  int? stock;
  final Map<String, bool> _taken;

  bool isActiveOn(DateTime day) {
    final d = Day.only(day);
    return !d.isBefore(Day.only(startDate)) && !d.isAfter(Day.only(endDate));
  }

  String _slot(DateTime day, int minutes) => '${Day.key(day)}@$minutes';

  bool takenAt(DateTime day, int minutes) => _taken[_slot(day, minutes)] == true;

  void setTaken(DateTime day, int minutes, bool value) {
    final key = _slot(day, minutes);
    if (value) {
      _taken[key] = true;
    } else {
      _taken.remove(key);
    }
  }

  int dosesOn(DateTime day) => isActiveOn(day) ? times.length : 0;

  int takenCountOn(DateTime day) =>
      times.where((t) => takenAt(day, t)).length;

  int get courseDays => Day.only(endDate).difference(Day.only(startDate)).inDays + 1;

  /// Overall adherence across elapsed days of the course (0..1).
  double adherence() {
    final today = Day.today();
    var scheduled = 0;
    var done = 0;
    for (var d = Day.only(startDate);
        !d.isAfter(Day.only(endDate)) && !d.isAfter(today);
        d = d.add(const Duration(days: 1))) {
      scheduled += times.length;
      done += takenCountOn(d);
    }
    if (scheduled == 0) return 0;
    return done / scheduled;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'form': form.name,
        'times': times,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'mealRule': mealRule.name,
        'profile': profile,
        'stock': stock,
        'taken': _taken,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'] as String,
        name: json['name'] as String,
        dosage: json['dosage'] as String? ?? '',
        form: MedForm.values.byName(json['form'] as String? ?? 'tablet'),
        times: (json['times'] as List?)?.cast<int>() ?? const [],
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        mealRule: MealRule.values.byName(json['mealRule'] as String? ?? 'none'),
        profile: json['profile'] as String? ?? 'Self',
        stock: json['stock'] as int?,
        taken: (json['taken'] as Map?)?.map(
          (k, v) => MapEntry(k as String, v as bool),
        ),
      );
}

/// A single dose occurrence resolved for a given day — used to build the
/// dashboard "next dose" list and the day's timeline.
class DoseSlot {
  DoseSlot({
    required this.medicine,
    required this.day,
    required this.minutes,
  });

  final Medicine medicine;
  final DateTime day;
  final int minutes;

  DateTime get time =>
      DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
  bool get taken => medicine.takenAt(day, minutes);
}
