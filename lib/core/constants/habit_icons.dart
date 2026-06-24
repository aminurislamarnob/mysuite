import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Fixed palette of habit glyphs. Habits store an *index* into this list (not a
/// raw codepoint) so all icons stay const and icon tree-shaking keeps working
/// in release builds.
const List<IconData> kHabitIcons = [
  LucideIcons.coffee,
  LucideIcons.droplet,
  LucideIcons.dumbbell,
  LucideIcons.bookOpen,
  LucideIcons.brain,
  LucideIcons.cigarette,
  LucideIcons.footprints,
  LucideIcons.bed,
  LucideIcons.apple,
  LucideIcons.heart,
  LucideIcons.music,
  LucideIcons.pencil,
];

IconData habitIcon(int index) =>
    kHabitIcons[index.clamp(0, kHabitIcons.length - 1)];

/// Curated accent colors offered when creating a habit.
const List<int> kHabitColors = [
  0xFF10B981, // emerald
  0xFF06B6D4, // cyan
  0xFF5B6CFF, // indigo
  0xFF8B5CF6, // violet
  0xFFF59E0B, // amber
  0xFFEF4444, // red
  0xFFEC4899, // pink
  0xFF14B8A6, // teal
];
