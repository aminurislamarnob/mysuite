import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../people/avatar_storage.dart';
import '../providers/database_provider.dart';

final restoreServiceProvider = Provider<RestoreService>((ref) {
  return RestoreService(
    ref.watch(databaseProvider),
    ref.watch(avatarStorageProvider),
  );
});

/// A backup that cannot be restored, with a line fit to show the user.
///
/// Every refusal happens before the database is touched, so a message from
/// here always means nothing on the device changed.
class RestoreException implements Exception {
  final String message;
  const RestoreException(this.message);

  @override
  String toString() => message;
}

/// What a restore put back, for the confirmation the user sees.
@immutable
class RestoreSummary {
  /// Rows written, keyed by the backup's own section names.
  final Map<String, int> counts;

  /// Avatars decoded out of the file and written to disk.
  final int photos;

  /// When the backup was taken, if it said.
  final DateTime? exportedAt;

  const RestoreSummary({
    required this.counts,
    required this.photos,
    required this.exportedAt,
  });

  int get total => counts.values.fold(0, (a, b) => a + b);
}

/// Reads a full JSON backup back into the database.
///
/// The inverse of [ExportService.fullBackupData], and deliberately built out
/// of the same generated code: every row goes back through the drift data
/// class's own `fromJson`, which is the exact counterpart of the `toJson` the
/// export called. Neither side hand-writes a field list, so a new column
/// cannot be exported and then silently dropped on the way back in.
class RestoreService {
  RestoreService(this._db, this._avatars);

  final AppDatabase _db;
  final AvatarStorage _avatars;

  /// The backup's sections, in an order that puts a row's dependencies in
  /// first. Foreign keys are deferred for the transaction anyway — folders
  /// nest inside each other, so no single order can satisfy them all — but
  /// keeping this honest means only that one case leans on the pragma.
  ///
  /// A table missing from here would be wiped and never refilled, so
  /// `restore_service_test.dart` checks this covers every table the database
  /// declares.
  static const sections = <String>[
    'folders',
    'tags',
    'projects',
    'people',
    'accounts',
    'categories',
    'habits',
    'notes',
    'noteTags',
    'tasks',
    'taskTags',
    'habitLogs',
    'loans',
    'expenses',
    'budgets',
    'recurringExpenses',
    'medicines',
    'medicineDoses',
    'symptomLogs',
    'focusSessions',
  ];

  Future<RestoreSummary> restoreFromFile(File file) async {
    final String text;
    try {
      text = await file.readAsString();
    } on IOException {
      throw const RestoreException('That file could not be read.');
    }
    return restoreFromJson(text);
  }

  /// Replaces every row in the database with the contents of [source].
  ///
  /// Parsing happens up front, so a file that turns out to be malformed
  /// halfway through is rejected with the old data still in place. Only once
  /// every row has been read does the transaction clear the tables.
  Future<RestoreSummary> restoreFromJson(String source) async {
    final backup = _decode(source);
    _checkVersion(backup);

    // Photos are written before the transaction: they are file IO, which a
    // database transaction should not be waiting on, and an avatar left
    // behind by a failed restore is what `pruneOrphans` is for.
    final photos = await _writePhotos(_section(backup, 'people'));

    final counts = <String, int>{};
    final inserts = <void Function(Batch)>[];

    void plan<T extends Table, D extends DataClass>(
      String key,
      TableInfo<T, D> table,
      Insertable<D> Function(Map<String, dynamic> row) parse,
    ) {
      final rows = _section(backup, key);
      // Eager, so a bad row throws here rather than mid-transaction.
      final parsed = <Insertable<D>>[
        for (final row in rows) _parse(key, row, parse),
      ];
      counts[key] = parsed.length;
      inserts.add((b) => b.insertAll(table, parsed));
    }

    plan('folders', _db.folders, Folder.fromJson);
    plan('tags', _db.tags, Tag.fromJson);
    plan('projects', _db.projects, Project.fromJson);
    plan('people', _db.people, (r) => Person.fromJson(_person(r, photos)));
    plan('accounts', _db.accounts, Account.fromJson);
    plan('categories', _db.expenseCategories, ExpenseCategory.fromJson);
    plan('habits', _db.habits, Habit.fromJson);
    plan('notes', _db.notes, Note.fromJson);
    plan('noteTags', _db.noteTags, NoteTag.fromJson);
    plan('tasks', _db.tasks, Task.fromJson);
    plan('taskTags', _db.taskTags, TaskTag.fromJson);
    plan('habitLogs', _db.habitLogs, HabitLog.fromJson);
    plan('loans', _db.loans, Loan.fromJson);
    plan('expenses', _db.expenses, Expense.fromJson);
    plan('budgets', _db.budgets, Budget.fromJson);
    plan('recurringExpenses', _db.recurringExpenses, RecurringExpense.fromJson);
    plan('medicines', _db.medicines, Medicine.fromJson);
    plan('medicineDoses', _db.medicineDoses, MedicineDose.fromJson);
    plan('symptomLogs', _db.symptomLogs, SymptomLog.fromJson);
    plan('focusSessions', _db.focusSessions, FocusSession.fromJson);

    await _db.transaction(() async {
      // Folders reference their own parent, so no insert order satisfies
      // every key row by row. Deferring moves the check to the commit, where
      // the whole graph is present and can be judged as a whole.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final table in _db.allTables) {
        await _db.delete(table).go();
      }
      await _db.batch((b) {
        for (final insert in inserts) {
          insert(b);
        }
      });
    });

    // Whatever the previous database pointed at is unreachable now.
    await _avatars.pruneOrphans(photos.values);

    return RestoreSummary(
      counts: counts,
      photos: photos.length,
      exportedAt: DateTime.tryParse('${backup['exportedAt']}'),
    );
  }

  Map<String, dynamic> _decode(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const RestoreException('That file is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const RestoreException('That file is not a mySuite backup.');
    }
    // A CSV export renamed to .json, or somebody else's backup, would decode
    // fine and then wipe the device. The section names are the giveaway.
    if (!sections.any(decoded.containsKey)) {
      throw const RestoreException(
        'That file is not a mySuite backup. Pick a full backup (JSON).',
      );
    }
    return decoded;
  }

  void _checkVersion(Map<String, dynamic> backup) {
    final version = backup['version'];
    if (version is! int) return;
    if (version > _db.schemaVersion) {
      throw RestoreException(
        'This backup came from a newer version of mySuite (format $version). '
        'Update the app, then restore it.',
      );
    }
  }

  List<Map<String, dynamic>> _section(Map<String, dynamic> backup, String key) {
    final raw = backup[key];
    // An absent section is an older backup that predates the table, which is
    // a restore of nothing rather than a failure. A present but wrong-typed
    // one is a broken file.
    if (raw == null) return const [];
    if (raw is! List) {
      throw RestoreException('The "$key" section of that backup is damaged.');
    }
    return [
      for (final row in raw)
        if (row is Map<String, dynamic>)
          row
        else
          throw RestoreException(
            'The "$key" section of that backup is damaged.',
          ),
    ];
  }

  Insertable<D> _parse<D extends DataClass>(
    String key,
    Map<String, dynamic> row,
    Insertable<D> Function(Map<String, dynamic>) parse,
  ) {
    try {
      return parse(row);
    } on Object {
      // Covers the type errors drift's serializer throws on a missing or
      // wrong-typed column, which are not all Exceptions.
      throw RestoreException(
        'A row in the "$key" section of that backup is damaged.',
      );
    }
  }

  /// Decodes the avatars the export embedded, keyed by person id.
  ///
  /// A photo that will not decode costs that person their picture and nothing
  /// more — the same trade the export makes when a file has gone missing.
  Future<Map<int, String>> _writePhotos(
    List<Map<String, dynamic>> people,
  ) async {
    var selves = 0;
    final photos = <int, String>{};
    for (final person in people) {
      if (person['isSelf'] == true) selves++;
      final id = person['id'];
      final data = person['photoData'];
      if (id is! int || data is! String || data.isEmpty) continue;
      try {
        photos[id] = await _avatars.saveBytes(base64Decode(data));
      } on FormatException {
        continue;
      } on IOException {
        continue;
      }
    }
    // Half the app asks the database for "me" and expects exactly one answer,
    // so a backup that cannot say who that is would restore into a broken
    // app. Better to refuse while the current data is still intact.
    if (people.isNotEmpty && selves != 1) {
      throw RestoreException(
        selves == 0
            ? 'That backup has no profile marked as you, so it cannot be '
                  'restored.'
            : 'That backup marks $selves profiles as you, so it cannot be '
                  'restored.',
      );
    }
    return photos;
  }

  /// The person's row with the embedded photo swapped for the path it was
  /// just written to. The stored path in a backup names a directory on the
  /// device that wrote it, so it is never meaningful here.
  Map<String, dynamic> _person(
    Map<String, dynamic> row,
    Map<int, String> photos,
  ) {
    final id = row['id'];
    return {...row, 'photoPath': id is int ? photos[id] : null};
  }
}
