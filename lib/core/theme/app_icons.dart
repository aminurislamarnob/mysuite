import 'package:flutter/material.dart';

/// Maps the icon tokens persisted in the database to concrete glyphs.
///
/// Icon choices are stored as stable strings rather than code points so that
/// swapping the icon set later never invalidates existing rows.
class AppIcons {
  const AppIcons._();

  // --- Modules -------------------------------------------------------------
  static const notes = Icons.description_outlined;
  static const medicine = Icons.medication_outlined;
  static const habits = Icons.local_cafe_outlined;
  static const tasks = Icons.check_circle_outline;
  static const expenses = Icons.account_balance_wallet_outlined;
  static const focus = Icons.timer_outlined;

  static const dashboard = Icons.grid_view_outlined;
  static const modules = Icons.apps_outlined;
  static const insights = Icons.insights_outlined;
  static const settings = Icons.settings_outlined;

  static const habitIcons = <String, IconData>{
    'coffee': Icons.local_cafe_outlined,
    'tea': Icons.emoji_food_beverage_outlined,
    'water': Icons.water_drop_outlined,
    'smoking': Icons.smoking_rooms_outlined,
    'exercise': Icons.fitness_center_outlined,
    'reading': Icons.menu_book_outlined,
    'meditation': Icons.self_improvement_outlined,
    'sleep': Icons.bedtime_outlined,
    'walk': Icons.directions_walk_outlined,
    'study': Icons.school_outlined,
    'music': Icons.music_note_outlined,
    'star': Icons.star_outline,
  };

  static const categoryIcons = <String, IconData>{
    'food': Icons.restaurant_outlined,
    'transport': Icons.directions_bus_outlined,
    'bills': Icons.receipt_long_outlined,
    'groceries': Icons.local_grocery_store_outlined,
    'entertainment': Icons.movie_outlined,
    'health': Icons.favorite_outline,
    'education': Icons.school_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'family': Icons.family_restroom_outlined,
    'other': Icons.category_outlined,
    'salary': Icons.payments_outlined,
    'freelance': Icons.work_outline,
  };

  static const accountIcons = <String, IconData>{
    'cash': Icons.payments_outlined,
    'bank': Icons.account_balance_outlined,
    'card': Icons.credit_card_outlined,
    'bkash': Icons.phone_android_outlined,
    'nagad': Icons.phone_android_outlined,
    'rocket': Icons.rocket_launch_outlined,
    'other': Icons.account_balance_wallet_outlined,
  };

  static const medicineForms = <String, IconData>{
    'tablet': Icons.medication_outlined,
    'capsule': Icons.medication_liquid_outlined,
    'syrup': Icons.local_drink_outlined,
    'injection': Icons.vaccines_outlined,
    'drops': Icons.water_drop_outlined,
    'inhaler': Icons.air_outlined,
  };

  static const projectIcons = <String, IconData>{
    'inbox': Icons.inbox_outlined,
    'home': Icons.home_outlined,
    'work': Icons.work_outline,
    'folder': Icons.folder_outlined,
    'flag': Icons.flag_outlined,
    'heart': Icons.favorite_outline,
    'star': Icons.star_outline,
  };

  static IconData habit(String token) =>
      habitIcons[token] ?? Icons.star_outline;

  static IconData category(String token) =>
      categoryIcons[token] ?? Icons.category_outlined;

  static IconData account(String type) =>
      accountIcons[type] ?? Icons.account_balance_wallet_outlined;

  static IconData medicineForm(String form) =>
      medicineForms[form] ?? Icons.medication_outlined;

  static IconData project(String token) =>
      projectIcons[token] ?? Icons.folder_outlined;
}
