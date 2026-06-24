import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/storage/local_store.dart';
import '../core/utils/formatters.dart';
import '../models/habit.dart';

class HabitsController extends ChangeNotifier {
  HabitsController(this._store) {
    _load();
  }

  static const _key = 'habits';
  static const _uuid = Uuid();
  final LocalStore _store;
  final List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);
  int get count => _habits.length;

  void _load() {
    _habits
      ..clear()
      ..addAll(_store.readList(_key).map(Habit.fromJson));
  }

  Future<void> _persist() =>
      _store.writeList(_key, _habits.map((h) => h.toJson()).toList());

  String newId() => _uuid.v4();

  void upsert(Habit habit) {
    final i = _habits.indexWhere((h) => h.id == habit.id);
    if (i >= 0) {
      _habits[i] = habit;
    } else {
      _habits.add(habit);
    }
    _persist();
    notifyListeners();
  }

  void delete(String id) {
    _habits.removeWhere((h) => h.id == id);
    _persist();
    notifyListeners();
  }

  void log(Habit habit, int delta, {DateTime? day}) {
    habit.add(day ?? DateTime.now(), delta);
    _persist();
    notifyListeners();
  }

  void setAmount(Habit habit, int value, {DateTime? day}) {
    habit.setAmount(day ?? DateTime.now(), value);
    _persist();
    notifyListeners();
  }

  /// Count of build-habits hit + reduce-habits kept under target, today.
  int completedToday() {
    final today = Day.today();
    return _habits.where((h) {
      if (h.goal == HabitGoal.build) return h.succeededOn(today);
      // reduce habits only "count" once logged at least once today
      return h.amountOn(today) > 0 && h.succeededOn(today);
    }).length;
  }
}
