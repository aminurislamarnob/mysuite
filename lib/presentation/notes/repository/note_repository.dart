import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(databaseProvider));
});

/// Which slice of the library the notes list is showing.
enum NoteScope { active, favorites, archived, trash }

class NoteRepository {
  final AppDatabase _db;

  NoteRepository(this._db);

  /// Trash is purged after this long, per the spec's 30-day recovery window.
  static const trashRetention = Duration(days: 30);

  Stream<List<Note>> watchNotes({
    NoteScope scope = NoteScope.active,
    int? folderId,
    int? tagId,
  }) {
    final q = _db.select(_db.notes);

    switch (scope) {
      case NoteScope.active:
        q.where((t) => t.deletedAt.isNull() & t.isArchived.equals(false));
      case NoteScope.favorites:
        q.where((t) => t.deletedAt.isNull() & t.isFavorite.equals(true));
      case NoteScope.archived:
        q.where((t) => t.deletedAt.isNull() & t.isArchived.equals(true));
      case NoteScope.trash:
        q.where((t) => t.deletedAt.isNotNull());
    }

    if (folderId != null) q.where((t) => t.folderId.equals(folderId));

    // Pinned notes float to the top, then most recently edited.
    q.orderBy([
      (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
    ]);

    if (tagId == null) return q.watch();

    // Restrict to a tag by intersecting with the join table.
    return q.watch().asyncMap((notes) async {
      final links = await (_db.select(
        _db.noteTags,
      )..where((t) => t.tagId.equals(tagId))).get();
      final ids = links.map((l) => l.noteId).toSet();
      return notes.where((n) => ids.contains(n.id)).toList();
    });
  }

  Future<Note?> getNote(int id) =>
      (_db.select(_db.notes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> createNote({
    required String title,
    required String contentJson,
    int? folderId,
    DateTime? journalDate,
  }) {
    return _db
        .into(_db.notes)
        .insert(
          NotesCompanion.insert(
            title: Value(title),
            content: contentJson,
            plainText: Value(plainTextOf(contentJson)),
            folderId: Value(folderId),
            journalDate: Value(journalDate),
          ),
        );
  }

  Future<void> updateNote(
    int id, {
    String? title,
    String? contentJson,
    int? folderId,
    bool clearFolder = false,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isLocked,
    DateTime? reminderAt,
    bool clearReminder = false,
  }) async {
    await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        title: title == null ? const Value.absent() : Value(title),
        content: contentJson == null
            ? const Value.absent()
            : Value(contentJson),
        plainText: contentJson == null
            ? const Value.absent()
            : Value(plainTextOf(contentJson)),
        folderId: clearFolder
            ? const Value(null)
            : (folderId == null ? const Value.absent() : Value(folderId)),
        isPinned: isPinned == null ? const Value.absent() : Value(isPinned),
        isFavorite: isFavorite == null
            ? const Value.absent()
            : Value(isFavorite),
        isArchived: isArchived == null
            ? const Value.absent()
            : Value(isArchived),
        isLocked: isLocked == null ? const Value.absent() : Value(isLocked),
        reminderAt: clearReminder
            ? const Value(null)
            : (reminderAt == null ? const Value.absent() : Value(reminderAt)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Moves to trash rather than deleting, so it can be recovered.
  Future<void> moveToTrash(int id) =>
      (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
        NotesCompanion(deletedAt: Value(DateTime.now())),
      );

  Future<void> restoreFromTrash(int id) =>
      (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
        const NotesCompanion(deletedAt: Value(null)),
      );

  Future<void> deleteForever(int id) =>
      (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();

  Future<void> emptyTrash() =>
      (_db.delete(_db.notes)..where((t) => t.deletedAt.isNotNull())).go();

  /// Drops trashed notes past the retention window. Called once at startup.
  Future<int> purgeExpiredTrash() {
    final cutoff = DateTime.now().subtract(trashRetention);
    return (_db.delete(
      _db.notes,
    )..where((t) => t.deletedAt.isSmallerThanValue(cutoff))).go();
  }

  // --- Folders -------------------------------------------------------------

  Stream<List<Folder>> watchFolders() => (_db.select(
    _db.folders,
  )..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();

  Future<int> createFolder(String name, {int? parentId}) => _db
      .into(_db.folders)
      .insert(FoldersCompanion.insert(name: name, parentId: Value(parentId)));

  Future<void> renameFolder(int id, String name) => (_db.update(
    _db.folders,
  )..where((t) => t.id.equals(id))).write(FoldersCompanion(name: Value(name)));

  /// Deletes a folder and detaches (rather than deletes) the notes inside it.
  Future<void> deleteFolder(int id) async {
    await _db.transaction(() async {
      await (_db.update(_db.notes)..where((t) => t.folderId.equals(id))).write(
        const NotesCompanion(folderId: Value(null)),
      );
      await (_db.delete(_db.folders)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- Tags ----------------------------------------------------------------

  Stream<List<Tag>> watchTags() => (_db.select(
    _db.tags,
  )..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();

  Future<int> ensureTag(String name, {int color = 0xFF6C6C6C}) async {
    final existing = await (_db.select(
      _db.tags,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return _db
        .into(_db.tags)
        .insert(TagsCompanion.insert(name: name, color: Value(color)));
  }

  Future<List<Tag>> tagsForNote(int noteId) async {
    final query = _db.select(_db.tags).join([
      innerJoin(_db.noteTags, _db.noteTags.tagId.equalsExp(_db.tags.id)),
    ])..where(_db.noteTags.noteId.equals(noteId));
    final rows = await query.get();
    return rows.map((r) => r.readTable(_db.tags)).toList();
  }

  Future<void> setNoteTags(int noteId, List<String> tagNames) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.noteTags,
      )..where((t) => t.noteId.equals(noteId))).go();
      for (final name
          in tagNames.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet()) {
        final tagId = await ensureTag(name);
        await _db
            .into(_db.noteTags)
            .insert(
              NoteTagsCompanion.insert(noteId: noteId, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  // --- Journal -------------------------------------------------------------

  /// Returns the journal note for [day], creating it on first access.
  Future<Note> journalNoteFor(DateTime day) async {
    final date = Fmt.dateOnly(day);
    final existing =
        await (_db.select(_db.notes)
              ..where((t) => t.journalDate.equals(date))
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return existing;

    final id = await createNote(
      title: Fmt.fullDate(date),
      contentJson: emptyDelta,
      journalDate: date,
    );
    return (await getNote(id))!;
  }

  Future<List<Note>> notesWithReminders() =>
      (_db.select(_db.notes)..where((t) => t.reminderAt.isNotNull())).get();

  // --- Delta helpers -------------------------------------------------------

  static const emptyDelta = '[{"insert":"\\n"}]';

  /// A one-paragraph delta from plain text. Quill requires every document to
  /// end in a newline, so one is appended when the text lacks it.
  static String deltaFromPlainText(String text) {
    final body = text.endsWith('\n') ? text : '$text\n';
    return jsonEncode([
      {'insert': body},
    ]);
  }

  /// Flattens a Quill delta to searchable plain text.
  static String plainTextOf(String deltaJson) {
    try {
      final ops = jsonDecode(deltaJson);
      if (ops is! List) return '';
      final buffer = StringBuffer();
      for (final op in ops) {
        final insert = op is Map ? op['insert'] : null;
        if (insert is String) buffer.write(insert);
      }
      return buffer.toString().trim();
    } catch (_) {
      return '';
    }
  }

  /// A short single-line preview for note cards.
  static String previewOf(String deltaJson, {int max = 140}) {
    final text = plainTextOf(deltaJson).replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.length <= max ? text : '${text.substring(0, max)}…';
  }
}
