import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/task.dart';
import '../../state/tasks_controller.dart';
import '../focus/focus_screen.dart';

class TaskDetailSheet {
  static Future<void> show(BuildContext context, Task task) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TaskDetailBody(task: task),
    );
  }
}

class _TaskDetailBody extends StatefulWidget {
  const _TaskDetailBody({required this.task});
  final Task task;

  @override
  State<_TaskDetailBody> createState() => _TaskDetailBodyState();
}

class _TaskDetailBodyState extends State<_TaskDetailBody> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _subtask;
  late Task _t;

  @override
  void initState() {
    super.initState();
    _t = widget.task;
    _title = TextEditingController(text: _t.title);
    _notes = TextEditingController(text: _t.notes);
    _subtask = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _subtask.dispose();
    super.dispose();
  }

  void _commit() {
    _t.title = _title.text.trim().isEmpty ? _t.title : _title.text.trim();
    _t.notes = _notes.text.trim();
    context.read<TasksController>().update(_t);
  }

  Future<void> _pickDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _t.due ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _t.due = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final controller = context.read<TasksController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () {
                    controller.toggleDone(_t);
                    setState(() {});
                  },
                  icon: Icon(_t.done
                      ? LucideIcons.circleCheck
                      : LucideIcons.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _title,
                    style: context.text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: 'Task title',
                      border: InputBorder.none,
                      filled: false,
                    ),
                    onChanged: (_) => _commit(),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2),
                  onPressed: () {
                    controller.delete(_t.id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(LucideIcons.calendar, size: 16),
                  label: Text(_t.due == null ? 'Set due' : Fmt.relativeDay(_t.due!)),
                  onPressed: _pickDue,
                ),
                if (_t.due != null)
                  ActionChip(
                    avatar: const Icon(LucideIcons.x, size: 16),
                    label: const Text('Clear'),
                    onPressed: () => setState(() => _t.due = null),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Priority',
                style: context.text.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final p in Priority.values)
                  ChoiceChip(
                    label: Text(p.label),
                    selected: _t.priority == p,
                    selectedColor: Color(p.color).withValues(alpha: 0.2),
                    onSelected: (_) => setState(() {
                      _t.priority = p;
                      _commit();
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Subtasks',
                style: context.text.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            for (var i = 0; i < _t.subtasks.length; i++)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: _t.subtasks[i].done,
                title: Text(_t.subtasks[i].title,
                    style: TextStyle(
                        decoration: _t.subtasks[i].done
                            ? TextDecoration.lineThrough
                            : null)),
                onChanged: (v) => setState(() {
                  _t.subtasks[i].done = v ?? false;
                  _commit();
                }),
              ),
            TextField(
              controller: _subtask,
              decoration: InputDecoration(
                hintText: 'Add subtask',
                prefixIcon: const Icon(LucideIcons.plus),
                suffixIcon: IconButton(
                  icon: const Icon(LucideIcons.cornerDownLeft),
                  onPressed: _addSubtask,
                ),
              ),
              onSubmitted: (_) => _addSubtask(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _commit(),
            ),
            if (_t.focusedSeconds > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(LucideIcons.timer, size: 16, color: context.muted),
                  const SizedBox(width: 6),
                  Text('Focused ${Fmt.duration(Duration(seconds: _t.focusedSeconds))}',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.muted)),
                ],
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  _commit();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FocusScreen(task: _t)));
                },
                icon: const Icon(LucideIcons.play),
                label: const Text('Start Focus on this task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSubtask() {
    final text = _subtask.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _t.subtasks.add(Subtask(title: text));
      _subtask.clear();
      _commit();
    });
  }
}
