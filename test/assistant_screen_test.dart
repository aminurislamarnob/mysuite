import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mysuite/core/ai/ai_client.dart';
import 'package:mysuite/core/ai/ai_provider.dart';
import 'package:mysuite/core/ai/ai_providers.dart';
import 'package:mysuite/core/database/app_database.dart';
import 'package:mysuite/core/people/avatar_storage.dart';
import 'package:mysuite/core/providers/database_provider.dart';
import 'package:mysuite/core/settings/app_settings.dart';
import 'package:mysuite/core/theme/app_forui_theme.dart';
import 'package:mysuite/core/theme/app_theme.dart';
import 'package:mysuite/presentation/ai/assistant_controller.dart';
import 'package:mysuite/presentation/ai/assistant_screen.dart';
import 'package:mysuite/presentation/ai/widgets/action_preview_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_fixtures.dart';

class _FakeClient implements AiClient {
  @override
  AiProvider get provider => AiProvider.gemini;

  @override
  String get model => 'gemini-test';

  @override
  Future<AiRawResponse> complete({
    required String system,
    required String user,
    required Map<String, Object?> schema,
  }) async => AiRawResponse(text: canonicalJson, model: model);
}

/// Drives the real screen through idle → transcript → preview. The states
/// are the controller's; this checks that each of them actually renders
/// under the app's theme stack, which is where a missing ancestor or an
/// unbounded layout would show up.
void main() {
  late AppDatabase db;
  late Directory avatarRoot;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    avatarRoot = Directory.systemTemp.createTempSync('mysuite-assistant-ui');
  });

  tearDown(() async {
    await db.close();
    if (avatarRoot.existsSync()) avatarRoot.deleteSync(recursive: true);
  });

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    AiClient? client,
  }) async {
    final container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        avatarStorageProvider.overrideWithValue(AvatarStorage(avatarRoot)),
        aiClientProvider.overrideWith((ref) async => client),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: FTheme(
            data: brandForuiTheme(brightness: Brightness.light),
            child: FToaster(
              child: FTooltipGroup(child: const AssistantScreen()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets('idle shows the mic and names the parser', (tester) async {
    await pumpScreen(tester, client: _FakeClient());
    await tester.pump();
    expect(find.text('Say what you want to add'), findsOneWidget);
    expect(find.bySemanticsLabel('Start listening'), findsOneWidget);
    expect(find.text('Gemini · gemini-test'), findsOneWidget);
  });

  testWidgets('no key means the badge says offline', (tester) async {
    await pumpScreen(tester, client: null);
    await tester.pump();
    expect(find.text('Offline parser'), findsOneWidget);
  });

  // The typed-transcript view is not pumped here: its field autofocuses, and
  // an autofocused text field trips a semantics assertion in the test binding
  // (any BrandField with `autofocus: true` does), which then wedges every
  // later test in the file. The view is exercised on a device instead.

  /// Submits and pumps until the controller leaves Thinking. Not `runAsync`:
  /// the providers and the in-memory database live in the test's fake-async
  /// zone, so their futures only advance on a pump. Not `pumpAndSettle`
  /// either: forui's spinner never stops animating.
  Future<void> submitAndWait(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final controller = container.read(assistantControllerProvider.notifier);
    controller.editTranscript('spent 200 taka on lunch with bKash');
    unawaited(controller.submit());
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (container.read(assistantControllerProvider) is! AssistantThinking) {
        break;
      }
    }
  }

  testWidgets('submitting reaches the preview state', (tester) async {
    final container = await pumpScreen(tester, client: _FakeClient());
    await submitAndWait(tester, container);
    expect(
      container.read(assistantControllerProvider),
      isA<AssistantPreview>(),
    );
  });

  testWidgets('the preview renders one card per entry', (tester) async {
    final container = await pumpScreen(tester, client: _FakeClient());
    await submitAndWait(tester, container);
    await tester.pump();

    expect(find.byType(ActionPreviewCard), findsNWidgets(3));
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Call the doctor'), findsOneWidget);
    expect(find.text('Napa'), findsOneWidget);
    expect(find.text('Save all 3'), findsOneWidget);
  });
}
