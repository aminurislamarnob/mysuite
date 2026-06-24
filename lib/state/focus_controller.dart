import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/storage/local_store.dart';
import '../core/utils/formatters.dart';
import '../models/focus_session.dart';

class FocusController extends ChangeNotifier {
  FocusController(this._store) {
    _load();
  }

  static const _key = 'focus_sessions';
  static const _uuid = Uuid();
  final LocalStore _store;
  final List<FocusSession> _sessions = [];

  /// Daily focus goal in minutes (spec: "Daily focus goal with progress").
  int dailyGoalMinutes = 120;

  List<FocusSession> get sessions {
    final list = [..._sessions];
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  void _load() {
    _sessions
      ..clear()
      ..addAll(_store.readList(_key).map(FocusSession.fromJson));
  }

  Future<void> _persist() =>
      _store.writeList(_key, _sessions.map((s) => s.toJson()).toList());

  FocusSession record({
    required DateTime startedAt,
    required int seconds,
    String? taskId,
    String? taskTitle,
  }) {
    final session = FocusSession(
      id: _uuid.v4(),
      startedAt: startedAt,
      seconds: seconds,
      taskId: taskId,
      taskTitle: taskTitle,
    );
    _sessions.add(session);
    _persist();
    notifyListeners();
    return session;
  }

  int secondsOn(DateTime day) => _sessions
      .where((s) => Day.same(s.startedAt, day))
      .fold(0, (sum, s) => sum + s.seconds);

  int secondsToday() => secondsOn(Day.today());

  int sessionsToday() =>
      _sessions.where((s) => Day.same(s.startedAt, DateTime.now())).length;

  int secondsThisWeek() {
    final weekAgo = Day.today().subtract(const Duration(days: 6));
    return _sessions
        .where((s) => !Day.only(s.startedAt).isBefore(weekAgo))
        .fold(0, (sum, s) => sum + s.seconds);
  }

  double todayGoalProgress() {
    if (dailyGoalMinutes <= 0) return 0;
    return (secondsToday() / (dailyGoalMinutes * 60)).clamp(0, 1).toDouble();
  }

  /// Focused seconds per day for the last [days] days (oldest first).
  List<int> dailyHistory(int days) {
    final today = Day.today();
    return List.generate(days, (i) {
      final d = today.subtract(Duration(days: days - 1 - i));
      return secondsOn(d);
    });
  }
}
