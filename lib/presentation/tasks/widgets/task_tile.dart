import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../providers/tasks_provider.dart';
import '../repository/task_repository.dart';
import '../utils/recurrence.dart';
import 'task_editor_sheet.dart';

/// A swipe action laid out the way [SlidableAction] lays one out.
///
/// [SlidableAction] takes an [IconData], which a Hugeicons glyph is not, so the
/// icon-over-label column is rebuilt here on [CustomSlidableAction].
Widget _slideAction(
  BuildContext context, {
  required SlidableActionCallback onPressed,
  required Color background,
  required HugeIconData icon,
  required String label,
}) {
  // White read fine on the light-mode hues; the dark-mode ones lift, and
  // white on a lifted danger red is nearer 2:1.
  final foreground = context.brand.onAccent(background);
  return CustomSlidableAction(
    onPressed: onPressed,
    backgroundColor: background,
    foregroundColor: foreground,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, color: foreground),
        const SizedBox(height: 4),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: foreground),
        ),
      ],
    ),
  );
}

/// The chip colour for a task priority. Takes the resolved palette rather than
/// a context so it stays callable from anywhere a [BrandColors] is already in
/// hand.
Color priorityColor(BrandColors brand, Color muted, int priority) =>
    switch (priority) {
      1 => brand.danger,
      2 => brand.warning,
      3 => brand.task,
      _ => muted,
    };

class TaskTile extends ConsumerWidget {
  final Task task;
  final bool showDue;
  final bool dense;

  const TaskTile({
    super.key,
    required this.task,
    this.showDue = true,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(taskRepositoryProvider);
    final muted = Theme.of(context).colorScheme.outline;
    final subtasks =
        ref.watch(subtasksProvider(task.id)).valueOrNull ?? const [];
    // A task due at 5pm is late at 5:01. One due 'today' with no time is
    // late tomorrow — comparing its midnight against now made every all-day
    // task light up red from the first minute of its own due date.
    final now = DateTime.now();
    final due = task.dueDate;
    final overdue =
        due != null &&
        !task.isCompleted &&
        (task.hasDueTime
            ? due.isBefore(now)
            : Fmt.dateOnly(due).isBefore(Fmt.dateOnly(now)));

    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.28,
        children: [
          _slideAction(
            context,
            onPressed: (_) => context.push('/focus', extra: task.id),
            background: context.brand.focus,
            icon: AppIcons.play,
            label: 'Focus',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          _slideAction(
            context,
            onPressed: (_) => TaskEditorSheet.show(context, task: task),
            background: Theme.of(context).colorScheme.primary,
            icon: AppIcons.edit,
            label: 'Edit',
          ),
          _slideAction(
            context,
            onPressed: (_) async {
              await repo.deleteTask(task.id);
              await ref
                  .read(notificationServiceProvider)
                  .cancelTaskReminder(task.id);
            },
            background: context.brand.danger,
            icon: AppIcons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: dense ? 4 : 8),
        child: TintCard(
          padding: EdgeInsets.zero,
          child: BrandTile(
            onTap: () => TaskEditorSheet.show(context, task: task),
            leading: BrandCheckbox(
              value: task.isCompleted,
              semanticsLabel: task.title,
              onChanged: (v) async {
                final spawned = await repo.setCompleted(task.id, v);
                if (spawned != null && context.mounted) {
                  brandToast(context, 'Next occurrence scheduled');
                }
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: task.isCompleted ? muted : null,
              ),
            ),
            subtitle: _buildSubtitle(context, muted, overdue, subtasks),
            trailing: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: priorityColor(
                  context.brand,
                  context.muted,
                  task.priority,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildSubtitle(
    BuildContext context,
    Color muted,
    bool overdue,
    List<Task> subtasks,
  ) {
    final bits = <Widget>[];

    if (showDue && task.dueDate != null) {
      bits.add(
        _chip(
          icon: AppIcons.calendar,
          label: Fmt.due(task.dueDate!, withTime: task.hasDueTime),
          color: overdue ? context.brand.danger : muted,
        ),
      );
    }
    if (task.recurrenceRule != null) {
      bits.add(
        _chip(
          icon: AppIcons.repeat,
          label: Recurrence.label(task.recurrenceRule),
          color: muted,
        ),
      );
    }
    if (subtasks.isNotEmpty) {
      final done = subtasks.where((s) => s.isCompleted).length;
      bits.add(
        _chip(
          icon: AppIcons.checklist,
          label: '$done/${subtasks.length}',
          color: muted,
        ),
      );
    }
    if (task.loggedMinutes > 0) {
      bits.add(
        _chip(
          icon: AppIcons.focus,
          label: Fmt.durationFromMinutes(task.loggedMinutes),
          color: context.brand.focus,
        ),
      );
    }

    if (bits.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 10, runSpacing: 2, children: bits),
    );
  }

  Widget _chip({
    required HugeIconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}
