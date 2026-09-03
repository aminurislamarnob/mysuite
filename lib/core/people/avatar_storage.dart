import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../settings/app_settings.dart' show sharedPrefsProvider;

/// The avatar files, kept under the app's documents directory.
///
/// The picker hands back a path into the OS cache, which both platforms are
/// free to evict, so a chosen photo is copied here to survive restarts and
/// updates. [root] is injected rather than resolved internally so the whole
/// lifecycle can be tested against a temp directory.
class AvatarStorage {
  /// The app's documents directory. Avatars live in `avatars/` beneath it.
  final Directory root;

  AvatarStorage(this.root);

  Directory get _dir => Directory(p.join(root.path, 'avatars'));

  /// Copies [source] in under a fresh name and returns the stored path.
  ///
  /// The name is random rather than derived from the person's id: a person is
  /// only inserted once their editor is saved, so there is no id to key on at
  /// the moment the photo is picked. It also means replacing a photo writes to
  /// a path nothing has cached, so no stale image survives the swap.
  ///
  /// Pass the person's current path as [replacing] to have it removed once the
  /// new file is in place.
  Future<String> save(File source, {String? replacing}) async {
    await _dir.create(recursive: true);
    final name = '${_token()}${p.extension(source.path)}';
    final dest = await source.copy(p.join(_dir.path, name));
    if (replacing != null) await delete(replacing);
    return dest.path;
  }

  /// Removes a stored avatar. Silent when it is already gone — a file the user
  /// cleared by other means should not block deleting the person.
  Future<void> delete(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  /// Deletes every avatar no longer named by a person, for the paths lost when
  /// a write fails partway.
  Future<int> pruneOrphans(Iterable<String?> keep) async {
    if (!await _dir.exists()) return 0;
    final live = keep.whereType<String>().map(p.basename).toSet();
    var removed = 0;
    await for (final entity in _dir.list()) {
      if (entity is! File || live.contains(p.basename(entity.path))) continue;
      await entity.delete();
      removed++;
    }
    return removed;
  }

  static final _random = Random();

  static String _token() {
    const alphabet = '0123456789abcdef';
    return String.fromCharCodes([
      for (var i = 0; i < 16; i++)
        alphabet.codeUnitAt(_random.nextInt(alphabet.length)),
    ]);
  }
}

/// Overridden in `main` with the resolved documents directory, the way
/// [sharedPrefsProvider] is, so the repository can depend on it synchronously
/// instead of every caller awaiting a platform channel.
final avatarStorageProvider = Provider<AvatarStorage>(
  (ref) => throw UnimplementedError('avatarStorageProvider must be overridden'),
);

/// The directory the app stores avatars under. Resolved once, before the first
/// frame.
Future<AvatarStorage> openAvatarStorage() async =>
    AvatarStorage(await getApplicationDocumentsDirectory());
