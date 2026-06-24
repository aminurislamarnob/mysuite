import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Default spend categories (spec 4.5) with const icons + accent colors. Custom
/// categories would extend this set in a later phase.
class CategoryMeta {
  const CategoryMeta(this.name, this.icon, this.color);
  final String name;
  final IconData icon;
  final int color;
}

const List<CategoryMeta> kExpenseCategories = [
  CategoryMeta('Food', LucideIcons.utensils, 0xFFF59E0B),
  CategoryMeta('Transport', LucideIcons.bus, 0xFF06B6D4),
  CategoryMeta('Groceries', LucideIcons.shoppingCart, 0xFF10B981),
  CategoryMeta('Bills', LucideIcons.receipt, 0xFFEF4444),
  CategoryMeta('Entertainment', LucideIcons.clapperboard, 0xFF8B5CF6),
  CategoryMeta('Health', LucideIcons.heartPulse, 0xFFEC4899),
  CategoryMeta('Education', LucideIcons.graduationCap, 0xFF5B6CFF),
  CategoryMeta('Shopping', LucideIcons.shoppingBag, 0xFF14B8A6),
  CategoryMeta('Family', LucideIcons.users, 0xFFF97316),
  CategoryMeta('Other', LucideIcons.circleEllipsis, 0xFF64748B),
];

const List<CategoryMeta> kIncomeCategories = [
  CategoryMeta('Salary', LucideIcons.banknote, 0xFF10B981),
  CategoryMeta('Freelance', LucideIcons.laptop, 0xFF06B6D4),
  CategoryMeta('Gift', LucideIcons.gift, 0xFF8B5CF6),
  CategoryMeta('Other', LucideIcons.circlePlus, 0xFF64748B),
];

CategoryMeta categoryMeta(String name, {bool income = false}) {
  final list = income ? kIncomeCategories : kExpenseCategories;
  return list.firstWhere(
    (c) => c.name == name,
    orElse: () => const CategoryMeta('Other', LucideIcons.circleEllipsis, 0xFF64748B),
  );
}
