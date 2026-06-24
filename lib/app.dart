import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/home_shell.dart';
import 'state/settings_controller.dart';

class MySuiteApp extends StatelessWidget {
  const MySuiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return MaterialApp(
      title: 'mySuite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(settings.accent),
      darkTheme: AppTheme.dark(settings.accent),
      themeMode: settings.themeMode,
      home: settings.onboarded ? const HomeShell() : const OnboardingScreen(),
    );
  }
}
