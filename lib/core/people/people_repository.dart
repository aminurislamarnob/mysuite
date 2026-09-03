import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../providers/database_provider.dart';

final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  return PeopleRepository(ref.watch(databaseProvider));
});

/// Everyone, Self first.
final peopleProvider = StreamProvider<List<Person>>((ref) {
  return ref.watch(peopleRepositoryProvider).watchPeople();
});

/// The household only: medicine profiles and who an expense was for.
final householdProvider = StreamProvider<List<Person>>((ref) {
  return ref
      .watch(peopleRepositoryProvider)
      .watchPeople(type: PersonType.household);
});

/// `People.type` values.
class PersonType {
  static const household = 'household';
  static const contact = 'contact';
}

/// The one list of people every module draws from. Self is seeded and can
/// never be removed; deleting anyone else re-points their history first so
/// no row is left dangling.
class PeopleRepository {
  final AppDatabase _db;

  PeopleRepository(this._db);

  Stream<List<Person>> watchPeople({String? type}) {
    final q = _db.select(_db.people)
      ..orderBy([
        (t) => OrderingTerm(expression: t.isSelf, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.name),
      ]);
    if (type != null) q.where((t) => t.type.equals(type));
    return q.watch();
  }

  Future<List<Person>> people({String? type}) {
    final q = _db.select(_db.people)
      ..orderBy([
        (t) => OrderingTerm(expression: t.isSelf, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.name),
      ]);
    if (type != null) q.where((t) => t.type.equals(type));
    return q.get();
  }

  Future<Person> self() =>
      (_db.select(_db.people)..where((t) => t.isSelf.equals(true))).getSingle();

  Future<int> selfId() async => (await self()).id;

  Future<int> createPerson({
    required String name,
    String relation = 'Family',
    int color = 0xFFFF6547,
    String type = PersonType.household,
  }) => _db
      .into(_db.people)
      .insert(
        PeopleCompanion.insert(
          name: name,
          relation: Value(relation),
          color: Value(color),
          type: Value(type),
        ),
      );

  Future<void> updatePerson(
    int id, {
    String? name,
    String? relation,
    int? color,
    String? type,
  }) => (_db.update(_db.people)..where((t) => t.id.equals(id))).write(
    PeopleCompanion(
      name: name == null ? const Value.absent() : Value(name),
      relation: relation == null ? const Value.absent() : Value(relation),
      color: color == null ? const Value.absent() : Value(color),
      type: type == null ? const Value.absent() : Value(type),
    ),
  );

  /// Rows across every module that name this person.
  Future<int> referenceCount(int id) async {
    Future<int> count(TableInfo table, Expression<bool> where) async {
      final q = _db.selectOnly(table)
        ..addColumns([countAll()])
        ..where(where);
      return (await q.getSingle()).read(countAll()) ?? 0;
    }

    return await count(_db.expenses, _db.expenses.personId.equals(id)) +
        await count(_db.loans, _db.loans.personId.equals(id)) +
        await count(_db.medicines, _db.medicines.profileId.equals(id)) +
        await count(_db.symptomLogs, _db.symptomLogs.profileId.equals(id));
  }

  /// Removes a person, moving everything that pointed at them to
  /// [reassignTo] (Self when omitted). Refuses to remove Self.
  Future<void> deletePerson(int id, {int? reassignTo}) async {
    final target = reassignTo ?? await selfId();
    if (target == id) {
      throw StateError('Self cannot be deleted.');
    }
    await _db.transaction(() async {
      await (_db.update(_db.expenses)..where((t) => t.personId.equals(id)))
          .write(ExpensesCompanion(personId: Value(target)));
      await (_db.update(_db.loans)..where((t) => t.personId.equals(id))).write(
        LoansCompanion(personId: Value(target)),
      );
      await (_db.update(_db.medicines)..where((t) => t.profileId.equals(id)))
          .write(MedicinesCompanion(profileId: Value(target)));
      await (_db.update(_db.symptomLogs)..where((t) => t.profileId.equals(id)))
          .write(SymptomLogsCompanion(profileId: Value(target)));
      await (_db.delete(_db.people)..where((t) => t.id.equals(id))).go();
    });
  }
}
