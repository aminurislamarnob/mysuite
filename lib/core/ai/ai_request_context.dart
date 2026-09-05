import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/expenses/repository/expense_repository.dart';
import '../../presentation/habits/repository/habit_repository.dart';
import '../../presentation/medicine/repository/medicine_repository.dart';
import '../../presentation/tasks/repository/task_repository.dart';
import '../database/app_database.dart';
import '../people/people_repository.dart';
import '../settings/app_settings.dart';

/// Everything the model needs to know about this user besides the transcript.
///
/// The name lists are the whole reason the assistant can say "bKash" and
/// "Food" back exactly: the prompt hands the model the user's own vocabulary
/// and asks it to pick from it. They are capped so a long-lived database
/// cannot turn every request into a page of names.
@immutable
class AiRequestContext {
  static const cap = 40;

  final DateTime now;
  final String locale;
  final String currencySymbol;
  final Set<AppModule> enabledModules;
  final List<ExpenseCategory> categories;
  final List<Account> accounts;
  final List<Person> people;
  final List<Habit> habits;
  final List<Project> projects;
  final List<Person> profiles;

  const AiRequestContext({
    required this.now,
    this.locale = 'en',
    this.currencySymbol = '৳',
    this.enabledModules = const {
      AppModule.notes,
      AppModule.medicine,
      AppModule.habits,
      AppModule.tasks,
      AppModule.expenses,
      AppModule.focus,
    },
    this.categories = const [],
    this.accounts = const [],
    this.people = const [],
    this.habits = const [],
    this.projects = const [],
    this.profiles = const [],
  });

  bool isEnabled(AppModule m) => enabledModules.contains(m);
}

/// Reads the lists for the enabled modules only; a module the user switched
/// off contributes nothing, so the model is never tempted to use it.
Future<AiRequestContext> buildAiRequestContext(Ref ref, {DateTime? now}) async {
  final settings = ref.read(settingsProvider);
  final enabled = settings.enabledModules;

  var categories = const <ExpenseCategory>[];
  var accounts = const <Account>[];
  if (enabled.contains(AppModule.expenses)) {
    final repo = ref.read(expenseRepositoryProvider);
    categories = await repo.categories();
    accounts = await repo.accounts();
  }

  final people = await ref.read(peopleRepositoryProvider).people();

  // One-shot queries throughout, never `watch().first`: a stream query's
  // first fetch is scheduled in a way the widget-test binding never advances,
  // which left the assistant stuck on "thinking" under test.
  var habits = const <Habit>[];
  if (enabled.contains(AppModule.habits)) {
    habits = await ref.read(habitRepositoryProvider).habits();
  }

  var projects = const <Project>[];
  if (enabled.contains(AppModule.tasks)) {
    projects = await ref.read(taskRepositoryProvider).projects();
  }

  var profiles = const <Person>[];
  if (enabled.contains(AppModule.medicine)) {
    profiles = await ref.read(medicineRepositoryProvider).profiles();
  }

  return AiRequestContext(
    now: now ?? DateTime.now(),
    locale: settings.locale,
    currencySymbol: settings.currencySymbol,
    enabledModules: enabled,
    categories: categories.take(AiRequestContext.cap).toList(),
    accounts: accounts.take(AiRequestContext.cap).toList(),
    people: people.take(AiRequestContext.cap).toList(),
    habits: habits.take(AiRequestContext.cap).toList(),
    projects: projects.take(AiRequestContext.cap).toList(),
    profiles: profiles.take(AiRequestContext.cap).toList(),
  );
}
