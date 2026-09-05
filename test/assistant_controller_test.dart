import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/ai/ai_action.dart';
import 'package:mysuite/core/ai/ai_client.dart';
import 'package:mysuite/core/ai/ai_provider.dart';
import 'package:mysuite/core/ai/ai_providers.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/providers/database_provider.dart';
import 'package:mysuite/core/services/notification_service.dart';
import 'package:mysuite/core/settings/app_settings.dart';
import 'package:mysuite/presentation/ai/assistant_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_fixtures.dart';

/// A provider that answers with whatever the test hands it.
class _FakeClient implements AiClient {
  _FakeClient(this.reply);

  final Object reply; // String body, or an exception to throw
  int calls = 0;

  @override
  AiProvider get provider => AiProvider.anthropic;

  @override
  String get model => 'fake-model';

  @override
  Future<AiRawResponse> complete({
    required String system,
    required String user,
    required Map<String, Object?> schema,
  }) async {
    calls++;
    if (reply is Exception) throw reply as Exception;
    return AiRawResponse(text: reply as String, model: model);
  }
}

/// Never touches the platform plugin.
class _QuietNotifications extends NotificationService {
  _QuietNotifications(super.ref);

  @override
  Future<void> scheduleTaskReminder({
    required int taskId,
    required String title,
    required DateTime when,
  }) async {}

  @override
  Future<void> scheduleDose({
    required int doseId,
    required String medicineName,
    required String dosageLabel,
    required String mealHint,
    required DateTime when,
  }) async {}
}

void main() {
  late AppDatabase db;
  late Directory avatarRoot;

  Future<ProviderContainer> container({
    AiClient? client,
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sharedPrefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(sharedPrefs),
        databaseProvider.overrideWithValue(db),
        avatarStorageProvider.overrideWithValue(AvatarStorage(avatarRoot)),
        notificationServiceProvider.overrideWith(_QuietNotifications.new),
        aiClientProvider.overrideWith((ref) async => client),
      ],
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    avatarRoot = Directory.systemTemp.createTempSync('mysuite-assistant');
  });

  tearDown(() async {
    await db.close();
    if (avatarRoot.existsSync()) avatarRoot.deleteSync(recursive: true);
  });

  /// Keeps the autoDispose controller alive for the test's duration.
  AssistantController controllerOf(ProviderContainer c) {
    c.listen(assistantControllerProvider, (_, _) {});
    return c.read(assistantControllerProvider.notifier);
  }

  // Dated tomorrow so the reminder is never "already passed".
  final canonical = canonicalJsonFor(
    DateTime.now().add(const Duration(days: 1)),
  );

  test('a typed command previews one card per action', () async {
    final client = _FakeClient(canonical);
    final c = await container(client: client);
    final controller = controllerOf(c);

    controller.editTranscript('spent 200 taka on lunch with bKash …');
    await controller.submit();

    final state = c.read(assistantControllerProvider);
    expect(state, isA<AssistantPreview>());
    final preview = state as AssistantPreview;
    expect(preview.previews, hasLength(3));
    expect(preview.result.source, isA<RemoteSource>());
    expect(client.calls, 1);
    // The medicine card carries no length warning: the canned reply says 5 days.
    expect(preview.previews.every((p) => p.clean), isTrue);
  });

  test('auto-save writes straight through when every card is clean', () async {
    final c = await container(
      client: _FakeClient(canonical),
      prefs: {'ai_auto_save': true},
    );
    final controller = controllerOf(c);
    controller.editTranscript('the canonical sentence');
    await controller.submit();

    final state = c.read(assistantControllerProvider);
    expect(state, isA<AssistantSaved>());
    expect((state as AssistantSaved).items, hasLength(3));
    expect(await db.select(db.expenses).get(), hasLength(1));
    expect(await db.select(db.tasks).get(), hasLength(1));
    expect(await db.select(db.medicines).get(), hasLength(1));
  });

  test('auto-save still previews when a card has a warning', () async {
    const withUnknownAccount =
        '{"actions": [{"kind": "add_expense", "title": "Tea", "amount": 20, '
        '"account": "Paytm"}], "reply": "", "needs_clarification": false}';
    final c = await container(
      client: _FakeClient(withUnknownAccount),
      prefs: {'ai_auto_save': true},
    );
    final controller = controllerOf(c);
    controller.editTranscript('tea 20 taka paytm');
    await controller.submit();

    final state = c.read(assistantControllerProvider);
    expect(state, isA<AssistantPreview>());
    expect((state as AssistantPreview).previews.single.warnings, isNotEmpty);
    expect(await db.select(db.expenses).get(), isEmpty);
  });

  test('no client means the offline parser answers', () async {
    final c = await container(client: null);
    final controller = controllerOf(c);
    controller.editTranscript('spent 200 taka on lunch with bKash');
    await controller.submit();

    final state = c.read(assistantControllerProvider) as AssistantPreview;
    expect(state.result.source, isA<OfflineSource>());
    expect(state.previews.single.draft.title, 'Lunch');
  });

  test('an auth failure maps to the auth error kind', () async {
    final c = await container(
      client: _FakeClient(const AiAuthException('invalid x-api-key')),
    );
    final controller = controllerOf(c);
    controller.editTranscript('anything');
    await controller.submit();

    final state = c.read(assistantControllerProvider) as AssistantFailure;
    expect(state.kind, AssistantErrorKind.auth);
    expect(state.message, 'invalid x-api-key');
    expect(state.transcript, 'anything');
  });

  test('removing every card returns to the transcript', () async {
    final c = await container(client: _FakeClient(canonical));
    final controller = controllerOf(c);
    controller.editTranscript('x');
    await controller.submit();
    controller.removePreview(0);
    controller.removePreview(0);
    expect(c.read(assistantControllerProvider), isA<AssistantPreview>());
    controller.removePreview(0);
    expect(c.read(assistantControllerProvider), isA<AssistantTranscript>());
  });

  test('a locked module asks the gate and stops when refused', () async {
    final c = await container(
      client: _FakeClient(canonical),
      prefs: {
        'locked_modules': ['expenses'],
      },
    );
    final controller = controllerOf(c);
    final asked = <Set<AppModule>>[];
    controller.unlockGate = (modules) async {
      asked.add(modules);
      return false;
    };
    controller.editTranscript('x');
    await controller.submit();
    expect(await controller.saveAll(), isFalse);
    expect(asked.single, {AppModule.expenses});
    // The preview survives with the reason, so a second Save can retry
    // without another provider round trip.
    final state = c.read(assistantControllerProvider) as AssistantPreview;
    expect(state.error, contains('locked'));
    expect(state.previews, hasLength(3));
    expect(await db.select(db.tasks).get(), isEmpty);

    // Granting the unlock on the retry writes everything.
    controller.unlockGate = (_) async => true;
    expect(await controller.saveAll(), isTrue);
    expect(c.read(assistantControllerProvider), isA<AssistantSaved>());
    expect(await db.select(db.tasks).get(), hasLength(1));
    expect(await db.select(db.expenses).get(), hasLength(1));
  });
}
