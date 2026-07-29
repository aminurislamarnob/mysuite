import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/expenses/expenses_screen.dart';
import '../../presentation/focus/focus_screen.dart';
import '../../presentation/habits/habits_screen.dart';
import '../../presentation/insights/insights_screen.dart';
import '../../presentation/medicine/medicine_screen.dart';
import '../../presentation/modules/modules_screen.dart';
import '../../presentation/notes/note_editor_screen.dart';
import '../../presentation/notes/notes_screen.dart';
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/reminders/reminders_screen.dart';
import '../../presentation/search/search_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/shell/app_shell.dart';
import '../../presentation/tasks/tasks_screen.dart';
import '../settings/app_settings.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _dashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _modulesKey = GlobalKey<NavigatorState>(debugLabel: 'modules');
final _insightsKey = GlobalKey<NavigatorState>(debugLabel: 'insights');
final _settingsKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/dashboard',
    // Send first-run users through onboarding before anything else.
    redirect: (context, state) {
      final done = ref.read(settingsProvider).onboardingComplete;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!done && !atOnboarding) return '/onboarding';
      if (done && atOnboarding) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardKey,
            routes: [
              GoRoute(
                  path: '/dashboard',
                  builder: (_, _) => const DashboardScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _modulesKey,
            routes: [
              GoRoute(
                  path: '/modules', builder: (_, _) => const ModulesScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _insightsKey,
            routes: [
              GoRoute(
                  path: '/insights',
                  builder: (_, _) => const InsightsScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsKey,
            routes: [
              GoRoute(
                  path: '/settings',
                  builder: (_, _) => const SettingsScreen()),
            ],
          ),
        ],
      ),
      GoRoute(path: '/notes', builder: (_, _) => const NotesScreen()),
      GoRoute(
        path: '/note_editor',
        builder: (_, state) => NoteEditorScreen(noteId: state.extra as int?),
      ),
      GoRoute(path: '/tasks', builder: (_, _) => const TasksScreen()),
      GoRoute(path: '/habits', builder: (_, _) => const HabitsScreen()),
      GoRoute(path: '/expenses', builder: (_, _) => const ExpensesScreen()),
      GoRoute(path: '/medicine', builder: (_, _) => const MedicineScreen()),
      GoRoute(
        // A task id may be passed in to link the session to that task.
        path: '/focus',
        builder: (_, state) => FocusScreen(taskId: state.extra as int?),
      ),
      GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
      GoRoute(
          path: '/reminders', builder: (_, _) => const RemindersScreen()),
    ],
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
