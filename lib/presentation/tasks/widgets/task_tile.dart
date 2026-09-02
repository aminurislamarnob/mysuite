import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
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
Widget _slideAction({
  required SlidableActionCallback onPressed,
  required Color background,
  required HugeIconData icon,
  required String label,
}) {
  return CustomSlidableAction(
    onPressed: onPressed,
    backgroundColor: background,
    foregroundColor: Colors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}

Color priorityColor(int priority) => switch (priority) {
  1 => AppColors.dangerLight,
  2 => AppColors.warningLight,
  3 => AppColors.taskAccent,
  _ => AppColors.mutedLight,
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
    final overdue =
        task.dueDate != null &&
        !task.isCompleted &&
        task.dueDate!.isBefore(DateTime.now());

    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.28,
        children: [
          _slideAction(
            onPressed: (_) => context.push('/focus', extra: task.id),
            background: AppColors.focusAccent,
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
            onPressed: (_) => TaskEditorSheet.show(context, task: task),
            background: AppColors.primaryLight,
            icon: AppIcons.edit,
            label: 'Edit',
          ),
          _slideAction(
            onPressed: (_) async {
              await repo.deleteTask(task.id);
              await ref
                  .read(notificationServiceProvider)
                  .cancelTaskReminder(task.id);
            },
            background: AppColors.dangerLight,
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
                color: priorityColor(task.priority),
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
          color: overdue ? AppColors.dangerLight : muted,
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
          color: AppColors.focusAccent,
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
