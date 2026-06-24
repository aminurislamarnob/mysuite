import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/storage/local_store.dart';
import 'state/expenses_controller.dart';
import 'state/focus_controller.dart';
import 'state/habits_controller.dart';
import 'state/medicine_controller.dart';
import 'state/notes_controller.dart';
import 'state/settings_controller.dart';
import 'state/tasks_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.open();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController(store)),
        ChangeNotifierProvider(create: (_) => NotesController(store)),
        ChangeNotifierProvider(create: (_) => MedicineController(store)),
        ChangeNotifierProvider(create: (_) => HabitsController(store)),
        ChangeNotifierProvider(create: (_) => TasksController(store)),
        ChangeNotifierProvider(create: (_) => ExpensesController(store)),
        ChangeNotifierProvider(create: (_) => FocusController(store)),
      ],
      child: const MySuiteApp(),
    ),
  );
}
