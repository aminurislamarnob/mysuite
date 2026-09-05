import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/ai_action.dart';
import '../../../core/ai/ai_client.dart';
import '../../../core/ai/ai_command_executor.dart';
import '../../../core/ai/ai_drafts.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../../expenses/widgets/expense_entry_sheet.dart';
import '../../habits/providers/habits_provider.dart';
import '../../habits/repository/habit_repository.dart';
import '../../medicine/widgets/medicine_editor_sheet.dart';
import '../../tasks/widgets/task_editor_sheet.dart';

/// One parsed entry, before it is saved.
///
/// Tapping opens the module's own editor prefilled, so anything the parser
/// got wrong is fixed in the same form the user would have typed into. The
/// card then shows as saved with an "Open" pill.
class ActionPreviewCard extends ConsumerWidget {
  final ActionPreview preview;
  final SavedItem? saved;
  final VoidCallback onRemove;
  final ValueChanged<SavedItem> onSaved;

  const ActionPreviewCard({
    super.key,
    required this.preview,
    required this.saved,
    required this.onRemove,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = preview.draft;
    final kind = draft.kind;
    final accent = kind.color(context.brand);
    final currency = ref.watch(settingsProvider).currencySymbol;
    final muted = context.muted;
    final isSaved = saved != null;
    final blocked = preview.blocked;

    final card = TintCard(
      accent: accent,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      onTap: isSaved
          ? () => context.push(saved!.route, extra: saved!.extra)
          : blocked
          ? null
          : () => _edit(context, ref),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: AppIcon(kind.icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        draft.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSaved)
                      AppIcon(
                        AppIcons.checkCircle,
                        color: context.brand.success,
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${kind.label} · ${draft.summary(currency)}',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                if (preview.warnings.isNotEmpty || blocked || isSaved) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (blocked)
                        Pill(label: 'Cannot save', color: context.brand.danger),
                      for (final w in preview.warnings)
                        Pill(label: w, color: context.brand.warning),
                      if (isSaved)
                        Pill(
                          label: 'Open',
                          color: accent,
                          selected: true,
                          onTap: () =>
                              context.push(saved!.route, extra: saved!.extra),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!isSaved)
            CircleIconButton(
              icon: AppIcons.close,
              tooltip: 'Remove',
              size: 36,
              onPressed: onRemove,
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: blocked ? Opacity(opacity: 0.6, child: card) : card,
    );
  }

  /// Opens the native editor for this draft. The sheets pop with the saved
  /// id; the note and focus paths save first, because their editors are a
  /// full screen and a running timer respectively.
  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final draft = preview.draft;
    final executor = ref.read(aiCommandExecutorProvider);
    try {
      switch (draft) {
        case TaskDraft d:
          final id = await TaskEditorSheet.show(context, draft: d);
          if (id != null) {
            onSaved(
              SavedItem(
                kind: d.kind,
                id: id,
                title: d.title,
                route: AppModule.tasks.route,
              ),
            );
          }
        case ExpenseDraft d:
          final id = await ExpenseEntrySheet.show(
            context,
            kind: d.txKind,
            note: d.note,
            amount: d.amount,
            categoryId: d.categoryId,
            accountId: d.accountId,
            personId: d.personId,
            date: d.date,
          );
          if (id != null) {
            onSaved(
              SavedItem(
                kind: d.kind,
                id: id,
                title: d.title,
                route: AppModule.expenses.route,
              ),
            );
          }
        case MedicineDraft d:
          final id = await MedicineEditorSheet.show(context, draft: d);
          if (id != null) {
            onSaved(
              SavedItem(
                kind: d.kind,
                id: id,
                title: d.name,
                route: AppModule.medicine.route,
              ),
            );
          }
        case NoteDraft d:
          final item = await executor.save(d);
          onSaved(item);
          if (context.mounted) context.push(item.route, extra: item.extra);
        case HabitLogDraft d:
          final item = await _pickHabit(context, ref, d);
          if (item != null) onSaved(item);
        case FocusDraft d:
          final item = await executor.save(d);
          onSaved(item);
          if (context.mounted) context.push(item.route);
      }
    } on AiException catch (e) {
      if (context.mounted) brandToast(context, e.message);
    }
  }

  /// Re-targets a habit log, mirroring the Quick Add picker.
  Future<SavedItem?> _pickHabit(
    BuildContext context,
    WidgetRef ref,
    HabitLogDraft d,
  ) async {
    final habits = ref.read(habitsListProvider).valueOrNull ?? const [];
    if (habits.isEmpty) {
      brandToast(context, 'No habits yet — add one first.');
      return null;
    }
    return brandSheet<SavedItem>(
      context: context,
      builder: (sheetContext) => SheetScaffold(
        title: 'Log which habit?',
        child: TileColumn(
          children: habits.map((h) {
            return BrandTile(
              leading: AppIcon(AppIcons.habit(h.icon), color: Color(h.color)),
              title: Text(h.name),
              subtitle: Text(
                '+${d.amount % 1 == 0 ? d.amount.toInt() : d.amount}'
                '${h.unit == null ? '' : ' ${h.unit}'}',
                style: const TextStyle(fontSize: 11),
              ),
              selected: h.id == d.habitId,
              onTap: () async {
                await ref
                    .read(habitRepositoryProvider)
                    .addToDay(h.id, d.amount);
                if (sheetContext.mounted) {
                  Navigator.pop(
                    sheetContext,
                    SavedItem(
                      kind: d.kind,
                      id: h.id,
                      title: h.name,
                      route: AppModule.habits.route,
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
