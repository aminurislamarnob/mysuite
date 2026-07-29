import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../providers/tasks_provider.dart';
import '../repository/task_repository.dart';
import '../utils/recurrence.dart';
import 'task_editor_sheet.dart';

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
    final subtasks = ref.watch(subtasksProvider(task.id)).valueOrNull ?? const [];
    final overdue = task.dueDate != null &&
        !task.isCompleted &&
        task.dueDate!.isBefore(DateTime.now());

    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) => context.push('/focus', extra: task.id),
            backgroundColor: AppColors.focusAccent,
            foregroundColor: Colors.white,
            icon: Icons.play_arrow,
            label: 'Focus',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => TaskEditorSheet.show(context, task: task),
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) async {
              await repo.deleteTask(task.id);
              await ref
                  .read(notificationServiceProvider)
                  .cancelTaskReminder(task.id);
            },
            backgroundColor: AppColors.dangerLight,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          dense: dense,
          onTap: () => TaskEditorSheet.show(context, task: task),
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: AppColors.taskAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (v) async {
              final spawned = await repo.setCompleted(task.id, v ?? false);
              if (spawned != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Next occurrence scheduled')),
                );
              }
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
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
    );
  }

  Widget? _buildSubtitle(
      BuildContext context, Color muted, bool overdue, List<Task> subtasks) {
    final bits = <Widget>[];

    if (showDue && task.dueDate != null) {
      bits.add(_chip(
        icon: Icons.event_outlined,
        label: Fmt.due(task.dueDate!, withTime: task.hasDueTime),
        color: overdue ? AppColors.dangerLight : muted,
      ));
    }
    if (task.recurrenceRule != null) {
      bits.add(_chip(
          icon: Icons.repeat,
          label: Recurrence.label(task.recurrenceRule),
          color: muted));
    }
    if (subtasks.isNotEmpty) {
      final done = subtasks.where((s) => s.isCompleted).length;
      bits.add(_chip(
          icon: Icons.checklist,
          label: '$done/${subtasks.length}',
          color: muted));
    }
    if (task.loggedMinutes > 0) {
      bits.add(_chip(
        icon: Icons.timer_outlined,
        label: Fmt.durationFromMinutes(task.loggedMinutes),
        color: AppColors.focusAccent,
      ));
    }

    if (bits.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 10, runSpacing: 2, children: bits),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}
