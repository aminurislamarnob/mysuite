import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../providers/database_provider.dart';
import 'person_avatar.dart';
import 'avatar_storage.dart';

final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  return PeopleRepository(
    ref.watch(databaseProvider),
    ref.watch(avatarStorageProvider),
  );
});

/// Everyone, Self first.
final peopleProvider = StreamProvider<List<Person>>((ref) {
  return ref.watch(peopleRepositoryProvider).watchPeople();
});

/// The app user's own row. Watched by the dashboard's avatar and the settings
/// profile card, which both want the photo and the name the moment either
/// changes.
final selfProvider = Provider<Person?>((ref) {
  final people = ref.watch(peopleProvider).valueOrNull;
  // watchPeople orders Self first, so this is the head of the list in practice.
  return people?.where((p) => p.isSelf).firstOrNull;
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
  final AvatarStorage _avatars;

  PeopleRepository(this._db, this._avatars);

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
    int color = personColorSeed,
    String type = PersonType.household,
    String? photoPath,
  }) => _db
      .into(_db.people)
      .insert(
        PeopleCompanion.insert(
          name: name,
          relation: Value(relation),
          color: Value(color),
          type: Value(type),
          photoPath: Value(photoPath),
        ),
      );

  /// Null leaves a field alone. [photoPath] carries a third state — clearing
  /// the photo — so it takes a [Value] rather than a bare string: `Value(null)`
  /// removes it, `Value.absent()` (the default) leaves it be.
  Future<void> updatePerson(
    int id, {
    String? name,
    String? relation,
    int? color,
    String? type,
    Value<String?> photoPath = const Value.absent(),
  }) async {
    // The row is the only record of the old file, so read it before the write.
    if (photoPath.present) {
      final current = await (_db.select(
        _db.people,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (current?.photoPath != null && current!.photoPath != photoPath.value) {
        await _avatars.delete(current.photoPath);
      }
    }
    await (_db.update(_db.people)..where((t) => t.id.equals(id))).write(
      PeopleCompanion(
        name: name == null ? const Value.absent() : Value(name),
        relation: relation == null ? const Value.absent() : Value(relation),
        color: color == null ? const Value.absent() : Value(color),
        type: type == null ? const Value.absent() : Value(type),
        photoPath: photoPath,
      ),
    );
  }

  /// Copies [source] into the avatar store and points [id] at it, removing the
  /// photo it replaces. Returns the stored path.
  Future<String> setPhoto(int id, File source) async {
    final current = await (_db.select(
      _db.people,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    final stored = await _avatars.save(source, replacing: current?.photoPath);
    await (_db.update(_db.people)..where((t) => t.id.equals(id))).write(
      PeopleCompanion(photoPath: Value(stored)),
    );
    return stored;
  }

  /// Drops every avatar file no person points at, for the paths lost when a
  /// write failed partway. Cheap enough to run at startup.
  Future<int> pruneOrphanedAvatars() async =>
      _avatars.pruneOrphans((await people()).map((p) => p.photoPath));

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
    final doomed = await (_db.select(
      _db.people,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
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
    // After the transaction: a failed delete should not roll back the row, and
    // an orphaned file is recoverable where a dangling row is not.
    await _avatars.delete(doomed?.photoPath);
  }
}
