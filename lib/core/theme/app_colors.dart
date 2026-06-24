import 'package:flutter/material.dart';

/// Design tokens from the mySuite feature spec (section 7).
///
/// A single source of truth for brand, semantic, and module accent colors so
/// the whole app stays visually consistent across light and dark themes.
class AppColors {
  AppColors._();

  // ---- Brand / semantic (light) ----
  static const primaryLight = Color(0xFF5B6CFF); // indigo
  static const successLight = Color(0xFF22C55E);
  static const warningLight = Color(0xFFF59E0B);
  static const dangerLight = Color(0xFFEF4444);
  static const bgLight = Color(0xFFFAFAFA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textLight = Color(0xFF0F172A);
  static const mutedLight = Color(0xFF64748B);

  // ---- Brand / semantic (dark) ----
  static const primaryDark = Color(0xFF7C8BFF);
  static const successDark = Color(0xFF34D399);
  static const warningDark = Color(0xFFFBBF24);
  static const dangerDark = Color(0xFFF87171);
  static const bgDark = Color(0xFF0F1115);
  static const surfaceDark = Color(0xFF1A1D24);
  static const textDark = Color(0xFFE2E8F0);
  static const mutedDark = Color(0xFF94A3B8);

  // ---- Module accents (shared across themes) ----
  static const notes = Color(0xFFF59E0B); // amber
  static const medicine = Color(0xFFEF4444); // red
  static const habits = Color(0xFF10B981); // emerald
  static const tasks = Color(0xFF5B6CFF); // indigo
  static const expenses = Color(0xFF8B5CF6); // violet
  static const focus = Color(0xFF06B6D4); // cyan
}
