import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';

final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepository(ref.watch(databaseProvider));
});

class FocusRepository {
  final AppDatabase _db;

  FocusRepository(this._db);

  /// Work sessions only; break intervals are excluded from every stat.
  Stream<List<FocusSession>> watchSessions({int limit = 50}) =>
      (_db.select(_db.focusSessions)
            ..where((t) => t.isBreak.equals(false))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startTime,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(limit))
          .watch();

  Future<List<FocusSession>> sessionsBetween(DateTime from, DateTime to) =>
      (_db.select(_db.focusSessions)..where(
            (t) =>
                t.isBreak.equals(false) &
                t.startTime.isBiggerOrEqualValue(from) &
                t.startTime.isSmallerThanValue(to),
          ))
          .get();

  Future<List<FocusSession>> allSessions() => (_db.select(
    _db.focusSessions,
  )..where((t) => t.isBreak.equals(false))).get();

  Future<int> startSession({
    required int durationMinutes,
    required String mode,
    int? taskId,
    bool isBreak = false,
  }) => _db
      .into(_db.focusSessions)
      .insert(
        FocusSessionsCompanion.insert(
          durationMinutes: Value(durationMinutes),
          startTime: DateTime.now(),
          taskId: Value(taskId),
          mode: Value(mode),
          isBreak: Value(isBreak),
        ),
      );

  Future<void> finishSession(
    int id, {
    required int actualSeconds,
    required bool completed,
    String? note,
    int? rating,
  }) => (_db.update(_db.focusSessions)..where((t) => t.id.equals(id))).write(
    FocusSessionsCompanion(
      endTime: Value(DateTime.now()),
      actualSeconds: Value(actualSeconds),
      isCompleted: Value(completed),
      note: note == null ? const Value.absent() : Value(note),
      rating: rating == null ? const Value.absent() : Value(rating),
    ),
  );

  Future<void> annotate(int id, {String? note, int? rating}) =>
      (_db.update(_db.focusSessions)..where((t) => t.id.equals(id))).write(
        FocusSessionsCompanion(
          note: note == null ? const Value.absent() : Value(note),
          rating: rating == null ? const Value.absent() : Value(rating),
        ),
      );

  /// Abandons a session that was never finished, so it does not pollute stats.
  Future<void> discardSession(int id) =>
      (_db.delete(_db.focusSessions)..where((t) => t.id.equals(id))).go();

  Future<Duration> focusedOn(DateTime day) async {
    final start = Fmt.dateOnly(day);
    final sessions = await sessionsBetween(
      start,
      start.add(const Duration(days: 1)),
    );
    return Duration(seconds: sessions.fold(0, (a, s) => a + s.actualSeconds));
  }
}
