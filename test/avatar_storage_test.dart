import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/people/people_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late Directory incoming;
  late AvatarStorage avatars;
  late AppDatabase db;
  late PeopleRepository people;

  /// Stands in for what the picker hands back: a file outside the store.
  File picked(String name, [String bytes = 'jpeg-bytes']) =>
      File(p.join(incoming.path, name))..writeAsStringSync(bytes);

  Directory avatarDir() => Directory(p.join(root.path, 'avatars'));

  setUp(() {
    root = Directory.systemTemp.createTempSync('mysuite-avatars');
    incoming = Directory.systemTemp.createTempSync('mysuite-incoming');
    avatars = AvatarStorage(root);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    people = PeopleRepository(db, avatars);
  });

  tearDown(() async {
    await db.close();
    for (final dir in [root, incoming]) {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
  });

  group('AvatarStorage', () {
    test('copies the picked file in rather than referencing it', () async {
      final source = picked('camera.jpg');
      final stored = await avatars.save(source);

      expect(p.isWithin(root.path, stored), isTrue);
      expect(File(stored).readAsStringSync(), 'jpeg-bytes');

      // The picker's copy lives in a cache the OS may clear; the store must
      // not depend on it.
      source.deleteSync();
      expect(File(stored).existsSync(), isTrue);
    });

    test('keeps the extension so the file stays decodable', () async {
      expect(p.extension(await avatars.save(picked('a.png'))), '.png');
    });

    test('never reuses a name, so no viewer sees a stale image', () async {
      final first = await avatars.save(picked('a.jpg'));
      final second = await avatars.save(picked('a.jpg'));
      expect(first, isNot(second));
    });

    test('removes the photo it replaces', () async {
      final first = await avatars.save(picked('one.jpg', 'first'));
      final second = await avatars.save(
        picked('two.jpg', 'second'),
        replacing: first,
      );

      expect(File(first).existsSync(), isFalse);
      expect(File(second).readAsStringSync(), 'second');
    });

    test('deleting a file that is already gone is not an error', () async {
      final stored = await avatars.save(picked('a.jpg'));
      File(stored).deleteSync();
      await expectLater(avatars.delete(stored), completes);
      await expectLater(avatars.delete(null), completes);
    });

    test('prunes only the files nobody points at', () async {
      final kept = await avatars.save(picked('kept.jpg'));
      final orphan = await avatars.save(picked('orphan.jpg'));

      expect(await avatars.pruneOrphans([kept, null]), 1);
      expect(File(kept).existsSync(), isTrue);
      expect(File(orphan).existsSync(), isFalse);
    });

    test('pruning an empty store is a no-op', () async {
      expect(await avatars.pruneOrphans(const []), 0);
    });
  });

  group('PeopleRepository photos', () {
    test('setPhoto stores the file and points the row at it', () async {
      final id = await people.createPerson(name: 'Wife');
      final stored = await people.setPhoto(id, picked('wife.jpg'));

      final row = (await people.people()).firstWhere((p) => p.id == id);
      expect(row.photoPath, stored);
      expect(File(stored).existsSync(), isTrue);
    });

    test('a second photo replaces the first on disk', () async {
      final id = await people.createPerson(name: 'Wife');
      final first = await people.setPhoto(id, picked('one.jpg'));
      final second = await people.setPhoto(id, picked('two.jpg'));

      expect(File(first).existsSync(), isFalse);
      expect(File(second).existsSync(), isTrue);
    });

    test('clearing the photo removes the file', () async {
      final id = await people.createPerson(name: 'Wife');
      final stored = await people.setPhoto(id, picked('wife.jpg'));

      await people.updatePerson(id, photoPath: const Value(null));

      final row = (await people.people()).firstWhere((p) => p.id == id);
      expect(row.photoPath, isNull);
      expect(File(stored).existsSync(), isFalse);
    });

    test('editing other fields leaves the photo alone', () async {
      final id = await people.createPerson(name: 'Wife');
      final stored = await people.setPhoto(id, picked('wife.jpg'));

      await people.updatePerson(id, name: 'Partner');

      final row = (await people.people()).firstWhere((p) => p.id == id);
      expect(row.photoPath, stored);
      expect(File(stored).existsSync(), isTrue);
    });

    test('deleting a person takes their photo with them', () async {
      final id = await people.createPerson(name: 'Friend');
      final stored = await people.setPhoto(id, picked('friend.jpg'));

      await people.deletePerson(id);

      expect(File(stored).existsSync(), isFalse);
    });

    test('pruneOrphanedAvatars keeps every photo still in use', () async {
      final id = await people.createPerson(name: 'Wife');
      final kept = await people.setPhoto(id, picked('wife.jpg'));
      final orphan = await avatars.save(picked('stray.jpg'));

      expect(await people.pruneOrphanedAvatars(), 1);
      expect(File(kept).existsSync(), isTrue);
      expect(File(orphan).existsSync(), isFalse);
    });
  });

  group('schema v2', () {
    test('Self is seeded unnamed, so the profile card can prompt', () async {
      expect((await people.self()).name, isEmpty);
    });

    test('Self starts without a photo', () async {
      expect((await people.self()).photoPath, isNull);
    });

    test('a fresh store has no avatars directory until one is saved', () {
      expect(avatarDir().existsSync(), isFalse);
    });
  });
}
