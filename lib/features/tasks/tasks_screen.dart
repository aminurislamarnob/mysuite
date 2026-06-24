import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/task.dart';
import '../../state/tasks_controller.dart';
import '../../widgets/common.dart';
import 'task_detail_sheet.dart';

enum _View { today, upcoming, inbox, all }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _View _view = _View.today;
  final _quick = TextEditingController();

  @override
  void dispose() {
    _quick.dispose();
    super.dispose();
  }

  List<Task> _tasksFor(TasksController c) => switch (_view) {
        _View.today => c.dueToday(),
        _View.upcoming => c.upcoming(),
        _View.inbox => c.inbox(),
        _View.all => c.sorted(),
      };

  void _submitQuick() {
    final text = _quick.text.trim();
    if (text.isEmpty) return;
    context.read<TasksController>().quickAdd(text);
    _quick.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TasksController>();
    final tasks = _tasksFor(controller);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              children: [
                _viewChip(_View.today, 'Today', controller.dueTodayCount),
                _viewChip(_View.upcoming, 'Upcoming', controller.upcoming().length),
                _viewChip(_View.inbox, 'Inbox', controller.inbox().length),
                _viewChip(_View.all, 'All', controller.openCount),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? EmptyState(
                    icon: LucideIcons.listChecks,
                    title: _emptyTitle(),
                    message: 'Add a task below — try "Pay rent tomorrow !p1".',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _TaskTile(task: tasks[i]),
                  ),
          ),
          _QuickAddBar(controller: _quick, onSubmit: _submitQuick),
        ],
      ),
    );
  }

  String _emptyTitle() => switch (_view) {
        _View.today => 'Nothing due today',
        _View.upcoming => 'Clear week ahead',
        _View.inbox => 'Inbox zero',
        _View.all => 'No tasks yet',
      };

  Widget _viewChip(_View v, String label, int count) {
    final selected = _view == v;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label${count > 0 ? '  $count' : ''}'),
        selected: selected,
        onSelected: (_) => setState(() => _view = v),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TasksController>();
    final priorityColor = Color(task.priority.color);
    final doneCount = task.subtasks.where((s) => s.done).length;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444)),
      ),
      onDismissed: (_) => controller.delete(task.id),
      child: AppCard(
        onTap: () => TaskDetailSheet.show(context, task),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            InkWell(
              onTap: () => controller.toggleDone(task),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  task.done ? LucideIcons.circleCheck : LucideIcons.circle,
                  color: task.done ? context.muted : priorityColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyLarge?.copyWith(
                      decoration: task.done ? TextDecoration.lineThrough : null,
                      color: task.done ? context.muted : null,
                    ),
                  ),
                  if (task.due != null ||
                      task.project != 'Inbox' ||
                      task.subtasks.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (task.due != null)
                          _meta(
                            context,
                            LucideIcons.calendar,
                            Fmt.relativeDay(task.due!),
                            task.isOverdue ? const Color(0xFFEF4444) : null,
                          ),
                        if (task.project != 'Inbox')
                          _meta(context, LucideIcons.hash, task.project, null),
                        if (task.subtasks.isNotEmpty)
                          _meta(context, LucideIcons.listChecks,
                              '$doneCount/${task.subtasks.length}', null),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(task.priority.label,
                  style: context.text.labelSmall?.copyWith(
                      color: priorityColor, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(BuildContext context, IconData icon, String text, Color? color) {
    final c = color ?? context.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 3),
        Text(text, style: context.text.labelSmall?.copyWith(color: c)),
      ],
    );
  }
}

class _QuickAddBar extends StatelessWidget {
  const _QuickAddBar({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
            top: BorderSide(color: context.muted.withValues(alpha: 0.12))),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onSubmit(),
        decoration: InputDecoration(
          hintText: 'Add a task…',
          prefixIcon: const Icon(LucideIcons.plus),
          suffixIcon: IconButton(
            icon: const Icon(LucideIcons.cornerDownLeft),
            onPressed: onSubmit,
          ),
        ),
      ),
    );
  }
}
