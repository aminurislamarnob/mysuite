import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/people/people_repository.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';
import '../utils/schedule_generator.dart';

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return MedicineRepository(ref.watch(databaseProvider));
});

/// Dose status values, mirroring `MedicineDoses.status`.
class DoseStatus {
  static const pending = 0;
  static const taken = 1;
  static const skipped = 2;
}

class MedicineRepository {
  final AppDatabase _db;

  MedicineRepository(this._db);

  // --- Profiles ------------------------------------------------------------
  // A profile is a household member from the shared People table.

  PeopleRepository get _people => PeopleRepository(_db);

  Stream<List<Person>> watchProfiles() =>
      _people.watchPeople(type: PersonType.household);

  Future<List<Person>> profiles() => _people.people(type: PersonType.household);

  Future<int> createProfile(String name, String relation, int color) =>
      _people.createPerson(name: name, relation: relation, color: color);

  Future<void> deleteProfile(int id) => _people.deletePerson(id);

  // --- Medicines -----------------------------------------------------------

  Stream<List<Medicine>> watchMedicines({int? profileId}) {
    final q = _db.select(_db.medicines);
    if (profileId != null) q.where((t) => t.profileId.equals(profileId));
    q.orderBy([(t) => OrderingTerm(expression: t.name)]);
    return q.watch();
  }

  Future<Medicine?> getMedicine(int id) => (_db.select(
    _db.medicines,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Medicine>> medicines({int? profileId}) {
    final q = _db.select(_db.medicines);
    if (profileId != null) q.where((t) => t.profileId.equals(profileId));
    return q.get();
  }

  /// Creates a medicine and materialises its full course of doses.
  Future<int> createMedicineWithSchedule({
    required MedicinesCompanion medicine,
    required ScheduleSpec spec,
  }) async {
    return _db.transaction(() async {
      final id = await _db.into(_db.medicines).insert(medicine);
      await _insertDoses(id, ScheduleGenerator.generate(spec));
      return id;
    });
  }

  /// Rewrites the schedule after an edit, preserving any dose the user has
  /// already acted on so their adherence history is never lost.
  Future<void> regenerateSchedule(int medicineId, ScheduleSpec spec) async {
    await _db.transaction(() async {
      await (_db.delete(_db.medicineDoses)..where(
            (t) =>
                t.medicineId.equals(medicineId) &
                t.status.equals(DoseStatus.pending),
          ))
          .go();
      await _insertDoses(medicineId, ScheduleGenerator.generate(spec));
    });
  }

  Future<void> _insertDoses(int medicineId, List<DateTime> times) async {
    await _db.batch((b) {
      b.insertAll(
        _db.medicineDoses,
        times.map(
          (t) => MedicineDosesCompanion.insert(
            medicineId: medicineId,
            scheduledTime: t,
          ),
        ),
        // The (medicineId, scheduledTime) unique key makes re-running the
        // generator idempotent rather than duplicating a course.
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> updateMedicine(int id, MedicinesCompanion companion) =>
      (_db.update(
        _db.medicines,
      )..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteMedicine(int id) =>
      (_db.delete(_db.medicines)..where((t) => t.id.equals(id))).go();

  // --- Doses ---------------------------------------------------------------

  Stream<List<MedicineDose>> watchDosesBetween(DateTime from, DateTime to) =>
      (_db.select(_db.medicineDoses)
            ..where(
              (t) =>
                  t.scheduledTime.isBiggerOrEqualValue(from) &
                  t.scheduledTime.isSmallerThanValue(to),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.scheduledTime)]))
          .watch();

  Stream<List<MedicineDose>> watchTodayDoses() {
    final start = Fmt.dateOnly(DateTime.now());
    return watchDosesBetween(start, start.add(const Duration(days: 1)));
  }

  Future<List<MedicineDose>> dosesBetween(DateTime from, DateTime to) =>
      (_db.select(_db.medicineDoses)
            ..where(
              (t) =>
                  t.scheduledTime.isBiggerOrEqualValue(from) &
                  t.scheduledTime.isSmallerThanValue(to),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.scheduledTime)]))
          .get();

  Future<List<MedicineDose>> dosesFor(int medicineId) =>
      (_db.select(_db.medicineDoses)
            ..where((t) => t.medicineId.equals(medicineId))
            ..orderBy([(t) => OrderingTerm(expression: t.scheduledTime)]))
          .get();

  Future<List<MedicineDose>> upcomingDoses({int limit = 50}) =>
      (_db.select(_db.medicineDoses)
            ..where(
              (t) =>
                  t.scheduledTime.isBiggerThanValue(DateTime.now()) &
                  t.status.equals(DoseStatus.pending),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.scheduledTime)])
            ..limit(limit))
          .get();

  /// Marks a dose taken or skipped, decrementing inventory when taken.
  Future<void> setDoseStatus(int doseId, int status) async {
    await _db.transaction(() async {
      final dose = await (_db.select(
        _db.medicineDoses,
      )..where((t) => t.id.equals(doseId))).getSingleOrNull();
      if (dose == null) return;

      await (_db.update(
        _db.medicineDoses,
      )..where((t) => t.id.equals(doseId))).write(
        MedicineDosesCompanion(
          status: Value(status),
          actionedAt: Value(
            status == DoseStatus.pending ? null : DateTime.now(),
          ),
        ),
      );

      final med = await getMedicine(dose.medicineId);
      if (med == null) return;

      // Inventory only moves when the transition actually crosses "taken".
      final wasTaken = dose.status == DoseStatus.taken;
      final isTaken = status == DoseStatus.taken;
      if (wasTaken == isTaken) return;

      final delta = isTaken ? -med.dosage.ceil() : med.dosage.ceil();
      await (_db.update(
        _db.medicines,
      )..where((t) => t.id.equals(med.id))).write(
        MedicinesCompanion(
          inventory: Value((med.inventory + delta).clamp(0, 1 << 30)),
        ),
      );
    });
  }

  Future<void> adjustInventory(int medicineId, int delta) async {
    final med = await getMedicine(medicineId);
    if (med == null) return;
    await (_db.update(
      _db.medicines,
    )..where((t) => t.id.equals(medicineId))).write(
      MedicinesCompanion(
        inventory: Value((med.inventory + delta).clamp(0, 1 << 30)),
      ),
    );
  }

  // --- Adherence -----------------------------------------------------------

  /// Fraction of due doses that were taken between [from] and [to].
  ///
  /// Doses still in the future are excluded, otherwise adherence would
  /// artificially sink as soon as a long course is created.
  Future<double> adherence(DateTime from, DateTime to) async {
    final doses = await dosesBetween(from, to);
    final now = DateTime.now();
    final due = doses.where((d) => d.scheduledTime.isBefore(now)).toList();
    if (due.isEmpty) return 1.0;
    final taken = due.where((d) => d.status == DoseStatus.taken).length;
    return taken / due.length;
  }

  /// Per-weekday miss counts, which is what powers the "mostly Tuesdays"
  /// observation in the weekly digest.
  Future<Map<int, int>> missesByWeekday(DateTime from, DateTime to) async {
    final doses = await dosesBetween(from, to);
    final now = DateTime.now();
    final result = <int, int>{};
    for (final d in doses) {
      if (!d.scheduledTime.isBefore(now)) continue;
      if (d.status == DoseStatus.taken) continue;
      final wd = d.scheduledTime.weekday;
      result[wd] = (result[wd] ?? 0) + 1;
    }
    return result;
  }

  // --- Symptoms ------------------------------------------------------------

  Stream<List<SymptomLog>> watchSymptoms() =>
      (_db.select(_db.symptomLogs)..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
          .watch();

  Future<int> logSymptom({
    required String symptom,
    int severity = 1,
    int? medicineId,
    int? profileId,
    String? note,
  }) => _db
      .into(_db.symptomLogs)
      .insert(
        SymptomLogsCompanion.insert(
          symptom: symptom,
          severity: Value(severity),
          medicineId: Value(medicineId),
          profileId: Value(profileId),
          note: Value(note),
        ),
      );

  Future<void> deleteSymptom(int id) =>
      (_db.delete(_db.symptomLogs)..where((t) => t.id.equals(id))).go();

  /// Rebuilds the [ScheduleSpec] stored across a medicine's columns.
  static ScheduleSpec specOf(Medicine m) => ScheduleSpec(
    start: m.startDate,
    end: m.endDate,
    frequency: MedFrequency
        .values[m.frequencyType.clamp(0, MedFrequency.values.length - 1)],
    doseMinutes: ScheduleSpec.parseTimes(m.doseTimes),
    intervalHours: m.intervalHours,
    weekdayMask: m.weekdayMask,
    skipDates: ScheduleSpec.parseSkipDates(m.skipDates),
  );
}
