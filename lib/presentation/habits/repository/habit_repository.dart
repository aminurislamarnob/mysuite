import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(ref.watch(databaseProvider));
});

class HabitRepository {
  final AppDatabase _db;

  HabitRepository(this._db);

  Stream<List<Habit>> watchHabits({bool includeArchived = false}) {
    final q = _db.select(_db.habits);
    if (!includeArchived) q.where((t) => t.isArchived.equals(false));
    q.orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.watch();
  }

  /// One-shot form of [watchHabits], for callers that need the list once.
  Future<List<Habit>> habits({bool includeArchived = false}) {
    final q = _db.select(_db.habits);
    if (!includeArchived) q.where((t) => t.isArchived.equals(false));
    q.orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.get();
  }

  Future<Habit?> getHabit(int id) =>
      (_db.select(_db.habits)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> createHabit(HabitsCompanion habit) =>
      _db.into(_db.habits).insert(habit);

  Future<void> updateHabit(int id, HabitsCompanion habit) =>
      (_db.update(_db.habits)..where((t) => t.id.equals(id))).write(habit);

  Future<void> deleteHabit(int id) =>
      (_db.delete(_db.habits)..where((t) => t.id.equals(id))).go();

  Stream<List<HabitLog>> watchLogs(int habitId) =>
      (_db.select(_db.habitLogs)
            ..where((t) => t.habitId.equals(habitId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .watch();

  Future<List<HabitLog>> logs(int habitId) =>
      (_db.select(_db.habitLogs)
            ..where((t) => t.habitId.equals(habitId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .get();

  Stream<List<HabitLog>> watchLogsForDay(DateTime day) {
    final date = Fmt.dateOnly(day);
    return (_db.select(
      _db.habitLogs,
    )..where((t) => t.date.equals(date))).watch();
  }

  Future<HabitLog?> logForDay(int habitId, DateTime day) {
    final date = Fmt.dateOnly(day);
    return (_db.select(_db.habitLogs)
          ..where((t) => t.habitId.equals(habitId) & t.date.equals(date)))
        .getSingleOrNull();
  }

  /// Adds [delta] to the day's total, creating the row on first log.
  ///
  /// A single row per habit per day keeps streak and heatmap maths simple and
  /// makes the `+1` button idempotent to re-render.
  Future<void> addToDay(int habitId, double delta, {DateTime? day}) async {
    final date = Fmt.dateOnly(day ?? DateTime.now());
    await _db.transaction(() async {
      final existing =
          await (_db.select(_db.habitLogs)
                ..where((t) => t.habitId.equals(habitId) & t.date.equals(date)))
              .getSingleOrNull();

      if (existing == null) {
        if (delta <= 0) return;
        await _db
            .into(_db.habitLogs)
            .insert(
              HabitLogsCompanion.insert(
                habitId: habitId,
                date: date,
                amount: Value(delta),
              ),
            );
        return;
      }

      final next = existing.amount + delta;
      if (next <= 0) {
        await (_db.delete(
          _db.habitLogs,
        )..where((t) => t.id.equals(existing.id))).go();
      } else {
        await (_db.update(_db.habitLogs)
              ..where((t) => t.id.equals(existing.id)))
            .write(HabitLogsCompanion(amount: Value(next)));
      }
    });
  }

  /// Overwrites a day's total outright, used by the bulk back-fill editor.
  Future<void> setDayAmount(
    int habitId,
    DateTime day,
    double amount, {
    String? note,
  }) async {
    final date = Fmt.dateOnly(day);
    await _db.transaction(() async {
      final existing =
          await (_db.select(_db.habitLogs)
                ..where((t) => t.habitId.equals(habitId) & t.date.equals(date)))
              .getSingleOrNull();

      if (amount <= 0) {
        if (existing != null) {
          await (_db.delete(
            _db.habitLogs,
          )..where((t) => t.id.equals(existing.id))).go();
        }
        return;
      }
      if (existing == null) {
        await _db
            .into(_db.habitLogs)
            .insert(
              HabitLogsCompanion.insert(
                habitId: habitId,
                date: date,
                amount: Value(amount),
                note: Value(note),
              ),
            );
      } else {
        await (_db.update(
          _db.habitLogs,
        )..where((t) => t.id.equals(existing.id))).write(
          HabitLogsCompanion(
            amount: Value(amount),
            note: note == null ? const Value.absent() : Value(note),
          ),
        );
      }
    });
  }

  Future<List<HabitLog>> logsBetween(DateTime from, DateTime to) =>
      (_db.select(_db.habitLogs)..where(
            (t) =>
                t.date.isBiggerOrEqualValue(Fmt.dateOnly(from)) &
                t.date.isSmallerOrEqualValue(Fmt.dateOnly(to)),
          ))
          .get();

  Future<List<Habit>> habitsWithReminders() =>
      (_db.select(_db.habits)..where(
            (t) => t.reminderMinutes.isNotNull() & t.isArchived.equals(false),
          ))
          .get();

  /// Seeds the pre-built habits offered during onboarding.
  static const presets =
      <
        ({
          String name,
          String icon,
          int color,
          String unit,
          int goalType,
          double target,
          double? caffeine,
        })
      >[
        (
          name: 'Water',
          icon: 'water',
          color: 0xFF3AAFB9,
          unit: 'glasses',
          goalType: 0,
          target: 8,
          caffeine: null,
        ),
        (
          name: 'Coffee',
          icon: 'coffee',
          color: 0xFFF2A03D,
          unit: 'cups',
          goalType: 1,
          target: 2,
          caffeine: 95,
        ),
        (
          name: 'Tea',
          icon: 'tea',
          color: 0xFF3BB273,
          unit: 'cups',
          goalType: 0,
          target: 2,
          caffeine: 47,
        ),
        (
          name: 'Exercise',
          icon: 'exercise',
          color: 0xFFE5484D,
          unit: 'minutes',
          goalType: 0,
          target: 30,
          caffeine: null,
        ),
        (
          name: 'Reading',
          icon: 'reading',
          color: 0xFF9A6DD7,
          unit: 'pages',
          goalType: 0,
          target: 20,
          caffeine: null,
        ),
        (
          name: 'Meditation',
          icon: 'meditation',
          color: 0xFF5B7CE0,
          unit: 'minutes',
          goalType: 0,
          target: 10,
          caffeine: null,
        ),
        (
          name: 'Smoking',
          icon: 'smoking',
          color: 0xFF6C6C6C,
          unit: 'cigarettes',
          goalType: 1,
          target: 0,
          caffeine: null,
        ),
      ];
}
