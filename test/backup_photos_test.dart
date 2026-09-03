import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/people/people_repository.dart';
import 'package:mysuite/core/services/export_service.dart';
import 'package:path/path.dart' as p;

/// The bytes a backup must carry across a restore. Not a real JPEG — the
/// exporter only moves bytes, it never decodes them.
const _bytes = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46];

void main() {
  late Directory root;
  late Directory incoming;
  late AppDatabase db;
  late PeopleRepository people;
  late ExportService export;

  setUp(() {
    root = Directory.systemTemp.createTempSync('mysuite-backup-avatars');
    incoming = Directory.systemTemp.createTempSync('mysuite-backup-incoming');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    people = PeopleRepository(db, AvatarStorage(root));
    export = ExportService(db);
  });

  tearDown(() async {
    await db.close();
    for (final dir in [root, incoming]) {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
  });

  File picked(String name) =>
      File(p.join(incoming.path, name))..writeAsBytesSync(_bytes);

  /// The `people` array of a full backup, decoded.
  Future<List<Map<String, dynamic>>> peopleInBackup() async {
    // Round-tripped through JSON, since that is what a restore will read —
    // an object that only encodes in memory would prove nothing.
    final encoded = jsonEncode(await export.fullBackupData());
    final data = jsonDecode(encoded) as Map<String, dynamic>;
    return (data['people'] as List).cast<Map<String, dynamic>>();
  }

  test('a photo travels as base64, not as a device path', () async {
    final id = await people.createPerson(name: 'Wife');
    final stored = await people.setPhoto(id, picked('wife.jpg'));

    final row = (await peopleInBackup()).firstWhere((r) => r['id'] == id);

    expect(base64Decode(row['photoData'] as String), _bytes);
    // The path names a directory on this device only, so carrying it would
    // hand a restore a pointer to nothing.
    expect(row['photoPath'], isNull);
    expect(jsonEncode(row), isNot(contains(stored)));
  });

  test('a person without a photo carries no photo data', () async {
    await people.createPerson(name: 'Friend');
    final row = (await peopleInBackup()).firstWhere(
      (r) => r['name'] == 'Friend',
    );
    expect(row['photoData'], isNull);
    expect(row['photoPath'], isNull);
  });

  test('a photo missing from disk costs a photo, not the backup', () async {
    final id = await people.createPerson(name: 'Wife');
    final stored = await people.setPhoto(id, picked('wife.jpg'));
    File(stored).deleteSync();

    final rows = await peopleInBackup();

    expect(rows.firstWhere((r) => r['id'] == id)['photoData'], isNull);
    // Everyone else still made it out.
    expect(rows.any((r) => r['isSelf'] == true), isTrue);
  });

  test('the rest of a person survives the rewrite', () async {
    final id = await people.createPerson(
      name: 'Wife',
      relation: 'Spouse',
      color: 0xFF3BB273,
    );
    await people.setPhoto(id, picked('wife.jpg'));

    final row = (await peopleInBackup()).firstWhere((r) => r['id'] == id);

    expect(row['name'], 'Wife');
    expect(row['relation'], 'Spouse');
    expect(row['color'], 0xFF3BB273);
    expect(row['type'], 'household');
  });
}
