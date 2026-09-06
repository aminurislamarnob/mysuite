import 'dart:convert';
import 'dart:io';

// `isNotNull` is a column expression in drift and a matcher in the test
// package; this file wants the matcher.
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/services/export_service.dart';
import 'package:mysuite/core/services/restore_service.dart';

/// A restore replaces every row on the device, so the thing worth proving is
/// that it is the exact inverse of the export: back up a populated database,
/// wreck it, restore, and the backup taken afterwards should be identical.
/// That one comparison covers every table and column without this file having
/// to name any of them.
void main() {
  late AppDatabase db;
  late Directory avatarRoot;
  late ExportService export;
  late RestoreService restore;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    avatarRoot = Directory.systemTemp.createTempSync('mysuite-restore');
    export = ExportService(db);
    restore = RestoreService(db, AvatarStorage(avatarRoot));
    // `beforeOpen` counts a fresh in-memory database as newly created, so the
    // seeded accounts, categories and the single Self person are already here.
  });

  tearDown(() async {
    await db.close();
    if (avatarRoot.existsSync()) avatarRoot.deleteSync(recursive: true);
  });

  /// A backup with `exportedAt` dropped, which moves on every call.
  Future<Map<String, dynamic>> snapshot() async {
    final data = await export.fullBackupData();
    return {...data}..remove('exportedAt');
  }

  Future<String> backupJson() async =>
      jsonEncode(await export.fullBackupData());

  /// One row in every table, wired together so the foreign keys are real.
  Future<void> populate() async {
    final person = await db
        .into(db.people)
        .insert(
          PeopleCompanion.insert(
            name: 'Rifat',
            relation: const Value('Brother'),
          ),
        );

    // Nested on purpose: Folders reference Folders, so this is the case no
    // insert order can satisfy and the deferred-key pragma has to carry.
    final parent = await db
        .into(db.folders)
        .insert(FoldersCompanion.insert(name: 'Work'));
    await db
        .into(db.folders)
        .insert(FoldersCompanion.insert(name: 'Q3', parentId: Value(parent)));

    final tag = await db
        .into(db.tags)
        .insert(TagsCompanion.insert(name: 'urgent'));
    final note = await db
        .into(db.notes)
        .insert(
          NotesCompanion.insert(
            content: '{"ops":[{"insert":"hello\\n"}]}',
            title: const Value('Standup'),
            folderId: Value(parent),
          ),
        );
    await db
        .into(db.noteTags)
        .insert(NoteTagsCompanion.insert(noteId: note, tagId: tag));

    final project = await db
        .into(db.projects)
        .insert(ProjectsCompanion.insert(name: 'House'));
    final task = await db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            title: 'Call the plumber',
            projectId: Value(project),
            dueDate: Value(DateTime(2026, 3, 4, 17)),
            reminderTime: Value(DateTime(2026, 3, 4, 16, 30)),
            description: const Value('Leaking tap'),
          ),
        );
    await db
        .into(db.taskTags)
        .insert(TaskTagsCompanion.insert(taskId: task, tagId: tag));

    final habit = await db
        .into(db.habits)
        .insert(HabitsCompanion.insert(name: 'Water'));
    await db
        .into(db.habitLogs)
        .insert(
          HabitLogsCompanion.insert(
            habitId: habit,
            date: DateTime(2026, 3, 4),
            amount: const Value(6),
          ),
        );

    final account = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'bKash',
            type: const Value('bkash'),
            balance: const Value(1200.5),
          ),
        );
    final category = await db
        .into(db.expenseCategories)
        .insert(ExpenseCategoriesCompanion.insert(name: 'Food'));
    final loan = await db
        .into(db.loans)
        .insert(
          LoansCompanion.insert(
            personId: person,
            principal: 500,
            note: const Value('lunch'),
          ),
        );
    await db
        .into(db.expenses)
        .insert(
          ExpensesCompanion.insert(
            amount: 200,
            accountId: account,
            personId: person,
            categoryId: Value(category),
            loanId: Value(loan),
            note: const Value('lunch with Rifat'),
          ),
        );
    await db
        .into(db.budgets)
        .insert(
          BudgetsCompanion.insert(
            amount: 9000,
            monthStart: DateTime(2026, 3),
            categoryId: Value(category),
          ),
        );
    await db
        .into(db.recurringExpenses)
        .insert(
          RecurringExpensesCompanion.insert(
            name: 'Internet',
            amount: 1500,
            nextDueDate: DateTime(2026, 3, 20),
            isSubscription: const Value(true),
          ),
        );

    final medicine = await db
        .into(db.medicines)
        .insert(
          MedicinesCompanion.insert(
            name: 'Napa',
            startDate: DateTime(2026, 3, 1),
            endDate: DateTime(2026, 3, 8),
            profileId: Value(person),
            doseTimes: const Value('480,1200'),
          ),
        );
    await db
        .into(db.medicineDoses)
        .insert(
          MedicineDosesCompanion.insert(
            medicineId: medicine,
            scheduledTime: DateTime(2026, 3, 1, 8),
            status: const Value(1),
          ),
        );
    await db
        .into(db.symptomLogs)
        .insert(
          SymptomLogsCompanion.insert(
            symptom: 'headache',
            severity: const Value(3),
          ),
        );
    await db
        .into(db.focusSessions)
        .insert(
          FocusSessionsCompanion.insert(
            startTime: DateTime(2026, 3, 4, 9),
            taskId: Value(task),
            actualSeconds: const Value(1500),
            rating: const Value(4),
          ),
        );
  }

  test('sections cover every table the database declares', () {
    // A table added without a matching section would be wiped by a restore
    // and never refilled, silently losing the user's data.
    expect(RestoreService.sections, hasLength(db.allTables.length));
  });

  test('a populated database survives a full round trip', () async {
    await populate();
    final before = await snapshot();
    final json = await backupJson();
    expect(before['tasks'], hasLength(1));

    // Wreck it the way a lost phone would: different rows, different ids.
    await db.delete(db.notes).go();
    await db.delete(db.expenses).go();
    await db
        .into(db.tasks)
        .insert(TasksCompanion.insert(title: 'Belongs to nobody'));
    await db.into(db.people).insert(PeopleCompanion.insert(name: 'Stranger'));

    final summary = await restore.restoreFromJson(json);

    expect(await snapshot(), before);
    expect(summary.total, greaterThan(15));
    expect(summary.counts['tasks'], 1);
    expect(summary.exportedAt, isNotNull);
  });

  test('nested folders come back with their parent intact', () async {
    await populate();
    final json = await backupJson();
    await restore.restoreFromJson(json);

    final folders = await db.select(db.folders).get();
    final child = folders.singleWhere((f) => f.name == 'Q3');
    final parent = folders.singleWhere((f) => f.name == 'Work');
    expect(child.parentId, parent.id);
  });

  test('an avatar is written back to this device and re-pointed', () async {
    // A stored path names a directory on the device that wrote the backup, so
    // the bytes travel instead and the restore re-points the row at them.
    const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3, 4];
    final source = File('${avatarRoot.path}/incoming.png')
      ..writeAsBytesSync(png);
    final stored = await AvatarStorage(avatarRoot).save(source);
    await (db.update(
      db.people,
    )..where((t) => t.isSelf)).write(PeopleCompanion(photoPath: Value(stored)));

    final json = await backupJson();
    expect(json, contains('photoData'));

    // Restore onto a device that has never seen that file.
    final elsewhere = Directory.systemTemp.createTempSync('mysuite-restore-2');
    addTearDown(() => elsewhere.deleteSync(recursive: true));
    final summary = await RestoreService(
      db,
      AvatarStorage(elsewhere),
    ).restoreFromJson(json);

    expect(summary.photos, 1);
    final self = await (db.select(
      db.people,
    )..where((t) => t.isSelf)).getSingle();
    expect(self.photoPath, isNot(stored));
    expect(File(self.photoPath!).readAsBytesSync(), png);
    expect(self.photoPath, endsWith('.png'));
  });

  group('a bad file is refused with the data still in place', () {
    // Two of the cases below build their backup before calling this, so
    // populating is the test's job rather than the helper's.
    setUp(populate);

    Future<void> refuses(String source, Matcher message) async {
      final before = await snapshot();
      await expectLater(
        restore.restoreFromJson(source),
        throwsA(
          isA<RestoreException>().having((e) => e.message, 'message', message),
        ),
      );
      expect(await snapshot(), before, reason: 'the database was touched');
    }

    test(
      'not JSON at all',
      () => refuses('Date,Amount\n1,2', contains('not valid JSON')),
    );

    test('JSON that is not a backup', () async {
      await refuses('{"hello":"world"}', contains('not a mySuite backup'));
    });

    test(
      'a JSON list',
      () => refuses('[1,2,3]', contains('not a mySuite backup')),
    );

    test('a newer schema version', () async {
      await refuses(
        jsonEncode({'version': 99, 'tasks': <dynamic>[]}),
        contains('newer version'),
      );
    });

    test('a damaged section', () async {
      await refuses(
        jsonEncode({'version': 2, 'tasks': 'not a list'}),
        contains('"tasks" section'),
      );
    });

    test('a damaged row', () async {
      await refuses(
        jsonEncode({
          'version': 2,
          'tasks': [
            {'id': 'not an int'},
          ],
        }),
        contains('"tasks" section'),
      );
    });

    test('no profile marked as you', () async {
      final data = await export.fullBackupData();
      final people = (data['people']! as List)
          .map((p) => {...p as Map<String, dynamic>, 'isSelf': false})
          .toList();
      await refuses(
        jsonEncode({...data, 'people': people}),
        contains('no profile marked as you'),
      );
    });

    test('two profiles marked as you', () async {
      await db
          .into(db.people)
          .insert(
            PeopleCompanion.insert(name: 'Impostor', isSelf: const Value(true)),
          );
      final data = await export.fullBackupData();
      await refuses(jsonEncode(data), contains('marks 2 profiles'));
    });
  });

  test('an older backup missing a section restores the rest', () async {
    await populate();
    final data = await export.fullBackupData();
    // A backup taken before the table existed simply has nothing to put back.
    final summary = await restore.restoreFromJson(
      jsonEncode({...data}..remove('focusSessions')),
    );

    expect(summary.counts['focusSessions'], 0);
    expect(await db.select(db.focusSessions).get(), isEmpty);
    expect(await db.select(db.tasks).get(), hasLength(1));
  });

  test('restoring an empty backup clears the device', () async {
    await populate();
    final summary = await restore.restoreFromJson(
      jsonEncode({'version': 2, 'people': <dynamic>[], 'tasks': <dynamic>[]}),
    );

    expect(summary.total, 0);
    expect(await db.select(db.tasks).get(), isEmpty);
    expect(await db.select(db.people).get(), isEmpty);
  });
}
