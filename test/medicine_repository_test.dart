import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/people/people_repository.dart';
import 'package:mysuite/presentation/medicine/repository/medicine_repository.dart';
import 'package:mysuite/presentation/medicine/utils/schedule_generator.dart';

void main() {
  late AppDatabase db;
  late Directory avatarRoot;
  late MedicineRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    avatarRoot = Directory.systemTemp.createTempSync('mysuite-medicine');
    repo = MedicineRepository(
      db,
      PeopleRepository(db, AvatarStorage(avatarRoot)),
    );
  });

  tearDown(() async {
    await db.close();
    if (avatarRoot.existsSync()) avatarRoot.deleteSync(recursive: true);
  });

  MedicinesCompanion medicine({
    String name = 'Amoxicillin',
    int inventory = 0,
    double dosage = 1,
    required DateTime start,
    required DateTime end,
    String doseTimes = '480,840,1200',
  }) {
    return MedicinesCompanion(
      name: Value(name),
      form: const Value('tablet'),
      dosage: Value(dosage),
      dosageUnit: const Value('tablet'),
      inventory: Value(inventory),
      doseTimes: Value(doseTimes),
      startDate: Value(start),
      endDate: Value(end),
    );
  }

  test(
    'seeds the default accounts, categories and profile on first open',
    () async {
      // Touching any table forces `beforeOpen` to run.
      expect((await db.select(db.accounts).get()).length, 4);
      expect((await db.select(db.expenseCategories).get()).length, 12);
      expect((await db.select(db.projects).get()).length, 3);
      expect((await db.select(db.people).get()).length, 1);
    },
  );

  test('creating a medicine materialises its whole course', () async {
    final start = DateTime(2026, 3, 1);
    final end = DateTime(2026, 3, 14);

    final id = await repo.createMedicineWithSchedule(
      medicine: medicine(start: start, end: end),
      spec: ScheduleSpec(
        start: start,
        end: end,
        doseMinutes: const [480, 840, 1200],
      ),
    );

    final doses = await repo.dosesFor(id);
    expect(doses.length, 42); // 14 days x 3 a day
    expect(doses.first.scheduledTime, DateTime(2026, 3, 1, 8));
    expect(doses.last.scheduledTime, DateTime(2026, 3, 14, 20));
    expect(doses.every((d) => d.status == DoseStatus.pending), isTrue);
  });

  test('marking a dose taken decrements inventory once', () async {
    final start = DateTime(2026, 3, 1);
    final id = await repo.createMedicineWithSchedule(
      medicine: medicine(start: start, end: start, inventory: 10),
      spec: ScheduleSpec(start: start, end: start, doseMinutes: const [480]),
    );

    final dose = (await repo.dosesFor(id)).single;

    await repo.setDoseStatus(dose.id, DoseStatus.taken);
    expect((await repo.getMedicine(id))!.inventory, 9);

    // Re-marking the same dose taken must not double-decrement.
    await repo.setDoseStatus(dose.id, DoseStatus.taken);
    expect((await repo.getMedicine(id))!.inventory, 9);

    // Undoing it gives the unit back.
    await repo.setDoseStatus(dose.id, DoseStatus.pending);
    expect((await repo.getMedicine(id))!.inventory, 10);
  });

  test('skipping a dose leaves inventory untouched', () async {
    final start = DateTime(2026, 3, 1);
    final id = await repo.createMedicineWithSchedule(
      medicine: medicine(start: start, end: start, inventory: 10),
      spec: ScheduleSpec(start: start, end: start, doseMinutes: const [480]),
    );
    final dose = (await repo.dosesFor(id)).single;

    await repo.setDoseStatus(dose.id, DoseStatus.skipped);
    expect((await repo.getMedicine(id))!.inventory, 10);
  });

  test('regenerating the schedule preserves doses already actioned', () async {
    final start = DateTime(2026, 3, 1);
    final end = DateTime(2026, 3, 3);

    final id = await repo.createMedicineWithSchedule(
      medicine: medicine(start: start, end: end, doseTimes: '480'),
      spec: ScheduleSpec(start: start, end: end, doseMinutes: const [480]),
    );

    final first = (await repo.dosesFor(id)).first;
    await repo.setDoseStatus(first.id, DoseStatus.taken);

    // Shorten the course to a single day.
    await repo.regenerateSchedule(
      id,
      ScheduleSpec(start: start, end: start, doseMinutes: const [480]),
    );

    final doses = await repo.dosesFor(id);
    // The taken dose survives; the untouched future ones were replaced.
    expect(doses.where((d) => d.status == DoseStatus.taken).length, 1);
    expect(doses.length, 1);
  });

  test('regenerating twice does not duplicate the course', () async {
    final start = DateTime(2026, 3, 1);
    final end = DateTime(2026, 3, 5);
    final spec = ScheduleSpec(
      start: start,
      end: end,
      doseMinutes: const [480, 1200],
    );

    final id = await repo.createMedicineWithSchedule(
      medicine: medicine(start: start, end: end),
      spec: spec,
    );
    expect((await repo.dosesFor(id)).length, 10);

    await repo.regenerateSchedule(id, spec);
    expect((await repo.dosesFor(id)).length, 10);
  });

  test('adherence counts only doses that are already due', () async {
    final start = DateTime.now().subtract(const Duration(days: 2));
    final end = DateTime.now().add(const Duration(days: 5));

    final id = await repo.createMedicineWithSchedule(
      medicine: medicine(start: start, end: end, doseTimes: '480'),
      spec: ScheduleSpec(start: start, end: end, doseMinutes: const [480]),
    );

    final doses = await repo.dosesFor(id);
    final due = doses.where((d) => d.scheduledTime.isBefore(DateTime.now()));
    expect(due, isNotEmpty);

    // Nothing taken yet: adherence over the whole window is 0, not skewed by
    // the doses still in the future.
    final from = DateTime(start.year, start.month, start.day);
    final to = end.add(const Duration(days: 1));
    expect(await repo.adherence(from, to), 0);

    await repo.setDoseStatus(due.first.id, DoseStatus.taken);
    final after = await repo.adherence(from, to);
    expect(after, closeTo(1 / due.length, 0.0001));
  });

  test('deleting a medicine cascades to its doses', () async {
    final start = DateTime(2026, 3, 1);
    final id = await repo.createMedicineWithSchedule(
      medicine: medicine(start: start, end: DateTime(2026, 3, 5)),
      spec: ScheduleSpec(
        start: start,
        end: DateTime(2026, 3, 5),
        doseMinutes: const [480],
      ),
    );
    expect((await repo.dosesFor(id)), isNotEmpty);

    await repo.deleteMedicine(id);
    expect(await repo.dosesFor(id), isEmpty);
  });

  test('specOf round-trips the scheduling columns', () async {
    final start = DateTime(2026, 3, 1);
    final end = DateTime(2026, 3, 10);

    final id = await repo.createMedicineWithSchedule(
      medicine: MedicinesCompanion(
        name: const Value('Vitamin D'),
        startDate: Value(start),
        endDate: Value(end),
        doseTimes: const Value('540,1080'),
        frequencyType: Value(MedFrequency.specificWeekdays.index),
        weekdayMask: const Value(0x05),
        skipDates: const Value('2026-03-04'),
      ),
      spec: ScheduleSpec(start: start, end: end),
    );

    final spec = MedicineRepository.specOf((await repo.getMedicine(id))!);
    expect(spec.doseMinutes, [540, 1080]);
    expect(spec.frequency, MedFrequency.specificWeekdays);
    expect(spec.weekdayMask, 0x05);
    expect(spec.skipDates, {DateTime(2026, 3, 4)});
  });
}
