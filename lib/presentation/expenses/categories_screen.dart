import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../core/theme/app_theme.dart';
import 'providers/expenses_provider.dart';
import 'repository/expense_repository.dart';

/// Rename, recolour, re-icon, reorder and remove categories. The seeded
/// defaults are no different from the ones you add.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _income = false;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final shown = all.where((c) => c.isIncome == _income).toList();

    return BrandScaffold(
      header: BrandTopBar(
        title: 'Categories',
        leadingIcon: AppIcons.back,
        actions: [
          CircleIconButton(
            icon: AppIcons.add,
            tooltip: 'New category',
            size: 40,
            onPressed: () =>
                CategoryEditor.show(context, ref, isIncome: _income),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: BrandSegmented<bool>(
              options: const {false: 'Expense', true: 'Income'},
              selected: _income,
              onSelected: (v) => setState(() => _income = v),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              buildDefaultDragHandles: false,
              itemCount: shown.length,
              onReorderItem: (from, to) => _reorder(all, shown, from, to),
              itemBuilder: (context, i) => _CategoryRow(
                key: ValueKey('cat-${shown[i].id}'),
                category: shown[i],
                index: i,
                onDelete: () => _delete(shown[i], shown),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reorders within the visible group; the other group keeps its order
  /// after it, since the two are never shown together.
  Future<void> _reorder(
    List<ExpenseCategory> all,
    List<ExpenseCategory> shown,
    int from,
    int to,
  ) async {
    final moved = [...shown];
    moved.insert(to, moved.removeAt(from));
    final rest = all.where((c) => c.isIncome != _income);
    await ref
        .read(expenseRepositoryProvider)
        .reorderCategories([...moved, ...rest].map((c) => c.id).toList());
  }

  Future<void> _delete(
    ExpenseCategory category,
    List<ExpenseCategory> siblings,
  ) async {
    final repo = ref.read(expenseRepositoryProvider);
    final count = await repo.categoryTransactionCount(category.id);
    if (!mounted) return;

    if (count == 0) {
      final ok = await brandConfirm(
        context,
        title: 'Delete ${category.name}?',
        confirmLabel: 'Delete',
        destructive: true,
      );
      if (ok) await repo.deleteCategory(category.id);
      return;
    }

    final options = siblings.where((c) => c.id != category.id).toList();
    if (options.isEmpty) {
      brandToast(context, 'Add another category to move these into first.');
      return;
    }
    var target =
        (options.where((c) => c.name == 'Other').firstOrNull ?? options.first)
            .id;

    final move = await brandDialog<bool>(
      context,
      title: 'Delete ${category.name}',
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Move ${count == 1 ? '1 transaction' : '$count transactions'} to',
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in options)
                  Pill(
                    label: c.name,
                    icon: AppIcons.category(c.icon),
                    selected: target == c.id,
                    color: Theme.of(dialogContext).colorScheme.primary,
                    onTap: () => setState(() => target = c.id),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            BrandButton(
              label: 'Move and delete',
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
            const SizedBox(height: 8),
            BrandButton(
              label: 'Cancel',
              kind: BrandButtonKind.ghost,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
          ],
        ),
      ),
    );
    if (move == true) {
      await repo.deleteCategory(category.id, reassignTo: target);
    }
  }
}

class _CategoryRow extends ConsumerWidget {
  final ExpenseCategory category;
  final int index;
  final VoidCallback onDelete;

  const _CategoryRow({
    super.key,
    required this.category,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(category.color);
    return Padding(
      padding: const EdgeInsets.only(bottom: cardGap),
      child: BrandTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: AppIcon(
            AppIcons.category(category.icon),
            color: color,
            size: 18,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleIconButton(
              icon: AppIcons.delete,
              tooltip: 'Delete',
              size: 40,
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: AppIcon(AppIcons.gripVertical),
              ),
            ),
          ],
        ),
        onTap: () => CategoryEditor.show(context, ref, category: category),
      ),
    );
  }
}

/// The create / edit dialog, shared with the entry sheet's quick-add.
class CategoryEditor {
  CategoryEditor._();

  /// Returns the id of the created or edited category, or null if dismissed.
  static Future<int?> show(
    BuildContext context,
    WidgetRef ref, {
    ExpenseCategory? category,
    bool isIncome = false,
  }) async {
    final name = TextEditingController(text: category?.name ?? '');
    var icon = category?.icon ?? 'other';
    var color = category?.color ?? 0xFF9A6DD7;

    final saved = await brandDialog<bool>(
      context,
      title: category == null ? 'New category' : 'Edit category',
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrandField(controller: name, label: 'Name', autofocus: true),
            const SizedBox(height: 16),
            ColorPickerRow(
              selected: color,
              onChanged: (c) => setState(() => color = c),
            ),
            const SizedBox(height: 16),
            _IconGrid(
              selected: icon,
              color: Color(color),
              onChanged: (t) => setState(() => icon = t),
            ),
            const SizedBox(height: 20),
            BrandButton(
              label: category == null ? 'Create' : 'Save',
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
            const SizedBox(height: 8),
            BrandButton(
              label: 'Cancel',
              kind: BrandButtonKind.ghost,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
          ],
        ),
      ),
    );

    if (saved != true || name.text.trim().isEmpty) return null;
    final repo = ref.read(expenseRepositoryProvider);
    if (category == null) {
      return repo.createCategory(
        name.text.trim(),
        icon,
        color,
        isIncome: isIncome,
      );
    }
    await repo.updateCategory(
      category.id,
      name: name.text.trim(),
      icon: icon,
      color: color,
    );
    return category.id;
  }
}

/// Every token in [AppIcons.categoryIcons], as a scrolling grid of circles.
class _IconGrid extends StatelessWidget {
  final String selected;
  final Color color;
  final ValueChanged<String> onChanged;

  const _IconGrid({
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outline;
    return SizedBox(
      height: 160,
      child: GridView.count(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          for (final entry in AppIcons.categoryIcons.entries)
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onChanged(entry.key),
              child: Container(
                decoration: BoxDecoration(
                  color: entry.key == selected
                      ? color
                      : color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                    entry.value,
                    size: 18,
                    color: entry.key == selected
                        ? context.brand.onAccent(color)
                        : muted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
