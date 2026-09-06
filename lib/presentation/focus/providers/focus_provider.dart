import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/formatters.dart';
import '../../tasks/repository/task_repository.dart';
import '../repository/focus_repository.dart';

/// The timer presets from the spec.
enum FocusMode { pomodoro, fiftyTwo, deep, flow, reverse, custom }

extension FocusModeX on FocusMode {
  String get label => switch (this) {
    FocusMode.pomodoro => 'Pomodoro',
    FocusMode.fiftyTwo => '52 / 17',
    FocusMode.deep => 'Deep work',
    FocusMode.flow => 'Flow',
    FocusMode.reverse => 'Reverse',
    FocusMode.custom => 'Custom',
  };

  String get token => name;

  int get workMinutes => switch (this) {
    FocusMode.pomodoro => 25,
    FocusMode.fiftyTwo => 52,
    FocusMode.deep => 90,
    FocusMode.flow => 0, // counts up, no fixed length
    FocusMode.reverse => 25,
    FocusMode.custom => 25,
  };

  int get breakMinutes => switch (this) {
    FocusMode.pomodoro => 5,
    FocusMode.fiftyTwo => 17,
    FocusMode.deep => 20,
    FocusMode.flow => 0,
    FocusMode.reverse => 5,
    FocusMode.custom => 5,
  };

  /// Long break after four work intervals, Pomodoro-style.
  int get longBreakMinutes => this == FocusMode.pomodoro ? 15 : breakMinutes;

  /// Flow mode counts upward instead of down.
  bool get countsUp => this == FocusMode.flow;

  /// Reverse Pomodoro opens with the break.
  bool get breakFirst => this == FocusMode.reverse;
}

enum TimerPhase { idle, work, breakTime, finished }

@immutable
class FocusState {
  final FocusMode mode;
  final TimerPhase phase;
  final bool running;
  final int elapsedSeconds;
  final int targetSeconds;
  final int completedIntervals;
  final int? taskId;
  final int? sessionId;
  final int customMinutes;

  const FocusState({
    this.mode = FocusMode.pomodoro,
    this.phase = TimerPhase.idle,
    this.running = false,
    this.elapsedSeconds = 0,
    this.targetSeconds = 25 * 60,
    this.completedIntervals = 0,
    this.taskId,
    this.sessionId,
    this.customMinutes = 25,
  });

  int get remainingSeconds => mode.countsUp
      ? elapsedSeconds
      : (targetSeconds - elapsedSeconds).clamp(0, 1 << 30);

  /// What the big clock shows: counts up in flow mode, down otherwise.
  String get display =>
      Fmt.timerClock(mode.countsUp ? elapsedSeconds : remainingSeconds);

  double get progress => mode.countsUp || targetSeconds == 0
      ? 0
      : (elapsedSeconds / targetSeconds).clamp(0.0, 1.0);

  bool get isBreak => phase == TimerPhase.breakTime;

  FocusState copyWith({
    FocusMode? mode,
    TimerPhase? phase,
    bool? running,
    int? elapsedSeconds,
    int? targetSeconds,
    int? completedIntervals,
    int? taskId,
    bool clearTask = false,
    int? sessionId,
    bool clearSession = false,
    int? customMinutes,
  }) {
    return FocusState(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      running: running ?? this.running,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      completedIntervals: completedIntervals ?? this.completedIntervals,
      taskId: clearTask ? null : (taskId ?? this.taskId),
      sessionId: clearSession ? null : (sessionId ?? this.sessionId),
      customMinutes: customMinutes ?? this.customMinutes,
    );
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusState>((ref) {
      return FocusTimerNotifier(ref);
    });

class FocusTimerNotifier extends StateNotifier<FocusState> {
  FocusTimerNotifier(this._ref) : super(const FocusState());

  final Ref _ref;
  Timer? _ticker;

  FocusRepository get _repo => _ref.read(focusRepositoryProvider);

  void setMode(FocusMode mode) {
    if (state.phase != TimerPhase.idle) return;
    final minutes = mode == FocusMode.custom
        ? state.customMinutes
        : mode.workMinutes;
    state = state.copyWith(
      mode: mode,
      targetSeconds: minutes * 60,
      elapsedSeconds: 0,
    );
  }

  void setCustomMinutes(int minutes) {
    state = state.copyWith(
      customMinutes: minutes,
      targetSeconds: state.mode == FocusMode.custom
          ? minutes * 60
          : state.targetSeconds,
    );
  }

  void linkTask(int? taskId) {
    state = taskId == null
        ? state.copyWith(clearTask: true)
        : state.copyWith(taskId: taskId);
  }

  Future<void> start() async {
    if (state.running) return;

    // Resuming a paused session keeps the same database row.
    if (state.phase == TimerPhase.idle) {
      final startsWithBreak = state.mode.breakFirst;
      final phase = startsWithBreak ? TimerPhase.breakTime : TimerPhase.work;
      final minutes = startsWithBreak
          ? state.mode.breakMinutes
          : (state.mode == FocusMode.custom
                ? state.customMinutes
                : state.mode.workMinutes);

      final id = await _repo.startSession(
        durationMinutes: minutes,
        mode: state.mode.token,
        taskId: state.taskId,
        isBreak: startsWithBreak,
      );
      state = state.copyWith(
        phase: phase,
        sessionId: id,
        elapsedSeconds: 0,
        targetSeconds: minutes * 60,
      );
    }

    state = state.copyWith(running: true);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final elapsed = state.elapsedSeconds + 1;
    state = state.copyWith(elapsedSeconds: elapsed);

    // Flow mode runs until the user stops it.
    if (state.mode.countsUp) return;
    if (elapsed >= state.targetSeconds) unawaited(_completePhase());
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(running: false);
  }

  /// Ends the current interval and rolls into the next phase.
  Future<void> _completePhase() async {
    _ticker?.cancel();
    await _persist(completed: true);
    await _chime();

    final wasWork = state.phase == TimerPhase.work;
    final intervals = wasWork
        ? state.completedIntervals + 1
        : state.completedIntervals;

    if (state.mode == FocusMode.flow) {
      state = state.copyWith(
        phase: TimerPhase.finished,
        running: false,
        clearSession: true,
      );
      return;
    }

    // A long break lands after every fourth work interval.
    final nextIsBreak = wasWork;
    final breakMinutes = intervals > 0 && intervals % 4 == 0
        ? state.mode.longBreakMinutes
        : state.mode.breakMinutes;
    final nextMinutes = nextIsBreak
        ? breakMinutes
        : (state.mode == FocusMode.custom
              ? state.customMinutes
              : state.mode.workMinutes);

    state = state.copyWith(
      phase: nextIsBreak ? TimerPhase.breakTime : TimerPhase.work,
      completedIntervals: intervals,
      elapsedSeconds: 0,
      targetSeconds: nextMinutes * 60,
      running: false,
      clearSession: true,
    );

    await _ref
        .read(notificationServiceProvider)
        .notifyNow(
          id: 900001,
          title: nextIsBreak ? 'Time for a break' : 'Break over',
          body: nextIsBreak
              ? 'Nice work. Take $breakMinutes minutes.'
              : 'Ready for another $nextMinutes minutes?',
        );
  }

  /// Stops early, banking whatever time was actually focused.
  Future<void> stop() async {
    _ticker?.cancel();
    await _persist(completed: state.mode.countsUp);
    state = FocusState(
      mode: state.mode,
      customMinutes: state.customMinutes,
      taskId: state.taskId,
      targetSeconds: state.targetSeconds,
      phase: TimerPhase.finished,
    );
  }

  /// Writes the session and credits the linked task with the time.
  Future<void> _persist({required bool completed}) async {
    final id = state.sessionId;
    if (id == null) return;

    await _repo.finishSession(
      id,
      actualSeconds: state.elapsedSeconds,
      completed: completed,
    );

    // Only work time counts toward a task's logged minutes.
    if (state.phase == TimerPhase.work && state.taskId != null) {
      final minutes = state.elapsedSeconds ~/ 60;
      if (minutes > 0) {
        await _ref
            .read(taskRepositoryProvider)
            .addLoggedMinutes(state.taskId!, minutes);
      }
    }
  }

  Future<void> _chime() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/chime.mp3'));
    } on Exception {
      // A missing bundled sound must never interrupt the timer.
    }
  }

  /// Attaches a note and rating to the session that just ended.
  Future<void> annotateLast(int sessionId, {String? note, int? rating}) async {
    await _repo.annotate(sessionId, note: note, rating: rating);
  }

  void reset() {
    _ticker?.cancel();
    state = FocusState(
      mode: state.mode,
      customMinutes: state.customMinutes,
      taskId: state.taskId,
      targetSeconds:
          (state.mode == FocusMode.custom
              ? state.customMinutes
              : state.mode.workMinutes) *
          60,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

// --- Ambient sound ----------------------------------------------------------

/// Looping background sound.
///
/// The six loops ship in `assets/sounds/`. Playback can still fail — another
/// app can hold audio focus, and a desktop target may have no output device —
/// so [AmbientNotifier.toggle] reports that rather than throwing into a
/// running session.
final ambientPlayerProvider = StateNotifierProvider<AmbientNotifier, String?>((
  ref,
) {
  return AmbientNotifier();
});

class AmbientNotifier extends StateNotifier<String?> {
  AmbientNotifier() : super(null);

  final _player = AudioPlayer();

  /// Keyed by the token the Focus screen's pills use. Paths are relative to
  /// `assets/`, which is the prefix `AssetSource` prepends.
  static const tracks = <String, String>{
    'rain': 'sounds/rain.wav',
    'cafe': 'sounds/cafe.wav',
    'forest': 'sounds/forest.wav',
    'white': 'sounds/white_noise.wav',
    'brown': 'sounds/brown_noise.wav',
    'ocean': 'sounds/ocean.wav',
  };

  Future<bool> toggle(String key) async {
    if (state == key) {
      await _player.stop();
      state = null;
      return true;
    }
    final asset = tracks[key];
    if (asset == null) return false;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(asset));
      state = key;
      return true;
    } on Exception {
      state = null;
      return false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = null;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

// --- Stats ------------------------------------------------------------------

final recentSessionsProvider = StreamProvider<List<FocusSession>>((ref) {
  return ref.watch(focusRepositoryProvider).watchSessions();
});

@immutable
class FocusStats {
  final Duration today;
  final Duration week;
  final Duration total;
  final int sessionsToday;
  final int sessionsWeek;
  final int streakDays;
  final Map<DateTime, Duration> byDay;
  final Map<int, Duration> byHour;

  const FocusStats({
    required this.today,
    required this.week,
    required this.total,
    required this.sessionsToday,
    required this.sessionsWeek,
    required this.streakDays,
    required this.byDay,
    required this.byHour,
  });

  static const empty = FocusStats(
    today: Duration.zero,
    week: Duration.zero,
    total: Duration.zero,
    sessionsToday: 0,
    sessionsWeek: 0,
    streakDays: 0,
    byDay: {},
    byHour: {},
  );

  /// The hour of day with the most focused time, if there is any history.
  int? get bestHour {
    if (byHour.isEmpty) return null;
    final sorted = byHour.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}

final focusStatsProvider = StreamProvider<FocusStats>((ref) async* {
  final repo = ref.watch(focusRepositoryProvider);

  await for (final _ in repo.watchSessions(limit: 1)) {
    final sessions = await repo.allSessions();
    final today = Fmt.dateOnly(DateTime.now());
    final weekStart = Fmt.startOfWeek(DateTime.now());

    final byDay = <DateTime, Duration>{};
    final byHour = <int, Duration>{};
    var total = 0;
    var todaySeconds = 0;
    var weekSeconds = 0;
    var todayCount = 0;
    var weekCount = 0;

    for (final s in sessions) {
      final seconds = s.actualSeconds;
      if (seconds <= 0) continue;
      total += seconds;

      final day = Fmt.dateOnly(s.startTime);
      byDay[day] = (byDay[day] ?? Duration.zero) + Duration(seconds: seconds);
      byHour[s.startTime.hour] =
          (byHour[s.startTime.hour] ?? Duration.zero) +
          Duration(seconds: seconds);

      if (day == today) {
        todaySeconds += seconds;
        todayCount++;
      }
      if (!day.isBefore(weekStart)) {
        weekSeconds += seconds;
        weekCount++;
      }
    }

    // A streak counts back from today over days with any focused time.
    var streak = 0;
    var cursor = today;
    if ((byDay[today] ?? Duration.zero) == Duration.zero) {
      cursor = today.subtract(const Duration(days: 1));
    }
    while ((byDay[cursor] ?? Duration.zero) > Duration.zero) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    yield FocusStats(
      today: Duration(seconds: todaySeconds),
      week: Duration(seconds: weekSeconds),
      total: Duration(seconds: total),
      sessionsToday: todayCount,
      sessionsWeek: weekCount,
      streakDays: streak,
      byDay: byDay,
      byHour: byHour,
    );
  }
});

/// Daily focus goal in minutes, adjustable from the focus screen.
final focusGoalProvider = StateProvider<int>((ref) => 120);
