import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/storage/local_store.dart';
import '../models/note.dart';

class NotesController extends ChangeNotifier {
  NotesController(this._store) {
    _load();
  }

  static const _key = 'notes';
  static const _uuid = Uuid();
  final LocalStore _store;
  final List<Note> _notes = [];

  /// Notes sorted by pinned-first, then most recently updated.
  List<Note> get notes {
    final list = [..._notes];
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  int get count => _notes.length;

  List<Note> recent([int limit = 3]) => notes.take(limit).toList();

  Set<String> get allTags =>
      {for (final n in _notes) ...n.tags}..removeWhere((t) => t.isEmpty);

  void _load() {
    _notes
      ..clear()
      ..addAll(_store.readList(_key).map(Note.fromJson));
  }

  Future<void> _persist() =>
      _store.writeList(_key, _notes.map((n) => n.toJson()).toList());

  Note create({String title = '', String body = ''}) {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title,
      body: body,
      createdAt: now,
      updatedAt: now,
    );
    _notes.add(note);
    _persist();
    notifyListeners();
    return note;
  }

  void save(Note note) {
    note.updatedAt = DateTime.now();
    final i = _notes.indexWhere((n) => n.id == note.id);
    if (i >= 0) {
      _notes[i] = note;
    } else {
      _notes.add(note);
    }
    _persist();
    notifyListeners();
  }

  void togglePin(Note note) {
    note.pinned = !note.pinned;
    _persist();
    notifyListeners();
  }

  void delete(String id) {
    _notes.removeWhere((n) => n.id == id);
    _persist();
    notifyListeners();
  }
}
