import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

/// The six modules of mySuite. Each is identified by a stable [id] (used as a
/// persistence key) and carries presentation metadata (icon, accent, label).
enum ModuleId { notes, medicine, habits, tasks, expenses, focus }

class ModuleInfo {
  const ModuleInfo({
    required this.id,
    required this.label,
    required this.tagline,
    required this.icon,
    required this.accent,
  });

  final ModuleId id;
  final String label;
  final String tagline;
  final IconData icon;
  final Color accent;
}

/// Single source of truth for module presentation. Icons are Lucide glyphs from
/// `lucide_icons_flutter`; keeping them here means a renamed glyph is a one-line
/// fix rather than a hunt across screens.
const List<ModuleInfo> kModules = [
  ModuleInfo(
    id: ModuleId.notes,
    label: 'Notes',
    tagline: 'Capture ideas & journals',
    icon: LucideIcons.notebookPen,
    accent: AppColors.notes,
  ),
  ModuleInfo(
    id: ModuleId.medicine,
    label: 'Medicine',
    tagline: 'Schedules & adherence',
    icon: LucideIcons.pill,
    accent: AppColors.medicine,
  ),
  ModuleInfo(
    id: ModuleId.habits,
    label: 'Habits',
    tagline: 'Build & reduce, streaks',
    icon: LucideIcons.coffee,
    accent: AppColors.habits,
  ),
  ModuleInfo(
    id: ModuleId.tasks,
    label: 'Tasks',
    tagline: 'To-dos & projects',
    icon: LucideIcons.listChecks,
    accent: AppColors.tasks,
  ),
  ModuleInfo(
    id: ModuleId.expenses,
    label: 'Expenses',
    tagline: 'Spending & budgets',
    icon: LucideIcons.wallet,
    accent: AppColors.expenses,
  ),
  ModuleInfo(
    id: ModuleId.focus,
    label: 'Focus',
    tagline: 'Pomodoro & deep work',
    icon: LucideIcons.timer,
    accent: AppColors.focus,
  ),
];

ModuleInfo moduleInfo(ModuleId id) => kModules.firstWhere((m) => m.id == id);
