import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../repository/note_repository.dart';

/// The filter currently applied to the notes list.
@immutable
class NoteFilter {
  final NoteScope scope;
  final int? folderId;
  final int? tagId;
  final String? label;

  const NoteFilter({
    this.scope = NoteScope.active,
    this.folderId,
    this.tagId,
    this.label,
  });

  String get title =>
      label ??
      switch (scope) {
        NoteScope.active => 'All Notes',
        NoteScope.favorites => 'Favorites',
        NoteScope.archived => 'Archive',
        NoteScope.trash => 'Trash',
      };

  @override
  bool operator ==(Object other) =>
      other is NoteFilter &&
      other.scope == scope &&
      other.folderId == folderId &&
      other.tagId == tagId &&
      other.label == label;

  @override
  int get hashCode => Object.hash(scope, folderId, tagId, label);
}

final noteFilterProvider = StateProvider<NoteFilter>(
  (ref) => const NoteFilter(),
);

final notesListProvider = StreamProvider<List<Note>>((ref) {
  final filter = ref.watch(noteFilterProvider);
  return ref
      .watch(noteRepositoryProvider)
      .watchNotes(
        scope: filter.scope,
        folderId: filter.folderId,
        tagId: filter.tagId,
      );
});

final foldersProvider = StreamProvider<List<Folder>>((ref) {
  return ref.watch(noteRepositoryProvider).watchFolders();
});

final noteTagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(noteRepositoryProvider).watchTags();
});

final tagsForNoteProvider = FutureProvider.family<List<Tag>, int>((
  ref,
  noteId,
) {
  return ref.watch(noteRepositoryProvider).tagsForNote(noteId);
});

/// Recently edited notes for the dashboard widget.
final recentNotesProvider = StreamProvider<List<Note>>((ref) {
  return ref
      .watch(noteRepositoryProvider)
      .watchNotes()
      .map((n) => n.take(3).toList());
});

/// Count of notes sitting in the trash, shown as a badge in the drawer.
final trashCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(noteRepositoryProvider)
      .watchNotes(scope: NoteScope.trash)
      .map((n) => n.length);
});
