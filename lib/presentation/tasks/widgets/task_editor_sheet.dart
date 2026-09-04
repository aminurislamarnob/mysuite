import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Full create/edit form for a task, presented as a bottom sheet.
class TaskEditorSheet extends ConsumerStatefulWidget {
  final Task? task;
  final int? projectId;

  const TaskEditorSheet({super.key, this.task, this.projectId});

  static Future<void> show(BuildContext context, {Task? task, int? projectId}) {
    return brandSheet(
      context: context,
      builder: (_) => TaskEditorSheet(task: task, projectId: projectId),
    );
  }

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _tags;

  DateTime? _dueDate;
  bool _hasTime = false;
  DateTime? _reminder;
  int _priority = 4;
  int? _projectId;
  String? _recurrence;
  int? _estimate;
  final _newSubtask = TextEditingController();

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _tags = TextEditingController();
    _dueDate = t?.dueDate;
    _hasTime = t?.hasDueTime ?? false;
    _reminder = t?.reminderTime;
    _priority = t?.priority ?? 4;
    _projectId = t?.projectId ?? widget.projectId;
    _recurrence = t?.recurrenceRule;
    _estimate = t?.estimateMinutes;
    if (t != null) _loadTags(t.id);
  }

  Future<void> _loadTags(int taskId) async {
    final tags = await ref.read(taskRepositoryProvider).tagsForTask(taskId);
    if (mounted) _tags.text = tags.map((e) => e.name).join(', ');
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _tags.dispose();
    _newSubtask.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;

    final repo = ref.read(taskRepositoryProvider);
    final notifier = ref.read(notificationServiceProvider);
    final tagList = _tags.text
        .split(',')
        .map((e) => e.trim().replaceAll('#', ''))
        .where((e) => e.isNotEmpty)
        .toList();

    int id;
    if (_isEditing) {
      id = widget.task!.id;
      await repo.updateTask(
        id,
        title: title,
        description: _description.text.trim(),
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
        hasDueTime: _hasTime,
        reminderTime: _reminder,
        clearReminder: _reminder == null,
        priority: _priority,
        projectId: _projectId,
        clearProject: _projectId == null,
        recurrenceRule: _recurrence,
        clearRecurrence: _recurrence == null,
        estimateMinutes: _estimate,
      );
    } else {
      id = await repo.createTask(
        title: title,
        description: _description.text.trim(),
        dueDate: _dueDate,
        hasDueTime: _hasTime,
        reminderTime: _reminder,
        priority: _priority,
        projectId: _projectId,
        recurrenceRule: _recurrence,
        estimateMinutes: _estimate,
      );
    }

    await repo.setTaskTags(id, tagList);

    if (_reminder != null) {
      await notifier.scheduleTaskReminder(
        taskId: id,
        title: title,
        when: _reminder!,
      );
    } else {
      await notifier.cancelTaskReminder(id);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider).valueOrNull ?? const [];
    final muted = Theme.of(context).colorScheme.outline;

    return SheetScaffold(
      title: _isEditing ? 'Edit task' : 'New task',
      actions: [
        if (_isEditing)
          CircleIconButton(
            icon: AppIcons.delete,
            tooltip: 'Delete',
            size: 40,
            onPressed: () async {
              await ref
                  .read(taskRepositoryProvider)
                  .deleteTask(widget.task!.id);
              await ref
                  .read(notificationServiceProvider)
                  .cancelTaskReminder(widget.task!.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        BrandButton(
          label: 'Save',
          kind: BrandButtonKind.ghost,
          expand: false,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandField(
            controller: _title,
            label: 'Title',
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.sentences,
            onSubmit: (_) => _save(),
          ),
          const SizedBox(height: 12),
          BrandField(
            controller: _description,
            label: 'Description',
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),

          Text('Priority', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 8),
          BrandSegmented<int>(
            options: const {1: 'P1', 2: 'P2', 3: 'P3', 4: 'P4'},
            selected: _priority,
            onSelected: (v) => setState(() => _priority = v),
          ),
          const SizedBox(height: 20),

          _row(
            icon: AppIcons.calendar,
            label: 'Due date',
            value: _dueDate == null
                ? 'None'
                : Fmt.due(_dueDate!, withTime: _hasTime),
            onTap: _pickDueDate,
            onClear: _dueDate == null
                ? null
                : () => setState(() {
                    _dueDate = null;
                    _hasTime = false;
                  }),
          ),
          _row(
            icon: AppIcons.alarm,
            label: 'Reminder',
            value: _reminder == null
                ? 'None'
                : Fmt.due(_reminder!, withTime: true),
            onTap: _pickReminder,
            onClear: _reminder == null
                ? null
                : () => setState(() => _reminder = null),
          ),
          _row(
            icon: AppIcons.repeat,
            label: 'Repeat',
            value: Recurrence.label(_recurrence),
            onTap: _pickRecurrence,
            onClear: _recurrence == null
                ? null
                : () => setState(() => _recurrence = null),
          ),
          _row(
            icon: AppIcons.focus,
            label: 'Time estimate',
            value: _estimate == null
                ? 'None'
                : Fmt.durationFromMinutes(_estimate!),
            onTap: _pickEstimate,
            onClear: _estimate == null
                ? null
                : () => setState(() => _estimate = null),
          ),
          const SizedBox(height: 12),

          Text('Project', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(
                label: 'None',
                selected: _projectId == null,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => setState(() => _projectId = null),
              ),
              ...projects.map(
                (p) => Pill(
                  label: p.name,
                  icon: AppIcons.project(p.icon),
                  selected: _projectId == p.id,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => setState(() => _projectId = p.id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          BrandField(
            controller: _tags,
            label: 'Tags',
            hint: 'work, errands',
            prefix: const AppIcon(AppIcons.tag),
          ),

          if (_isEditing) ...[
            const SizedBox(height: 20),
            BrandDivider(),
            const SizedBox(height: 8),
            Text('Subtasks', style: TextStyle(color: muted, fontSize: 12)),
            _SubtaskList(parentId: widget.task!.id),
            Row(
              children: [
                Expanded(
                  child: BrandField(
                    controller: _newSubtask,
                    hint: 'Add a subtask',
                    onSubmit: (_) => _addSubtask(),
                  ),
                ),
                CircleIconButton(
                  icon: AppIcons.add,
                  size: 40,
                  onPressed: _addSubtask,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addSubtask() async {
    final text = _newSubtask.text.trim();
    if (text.isEmpty || widget.task == null) return;
    await ref
        .read(taskRepositoryProvider)
        .createTask(title: text, parentTaskId: widget.task!.id);
    _newSubtask.clear();
  }

  Widget _row({
    required HugeIconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return BrandTile(
      leading: AppIcon(icon, size: 20),
      title: Text(label),
      subtitle: Text(value),
      trailing: onClear == null
          ? const AppIcon(AppIcons.chevronRight)
          : CircleIconButton(
              icon: AppIcons.close,
              size: 40,
              onPressed: onClear,
            ),
      onTap: onTap,
    );
  }

  Future<void> _pickDueDate() async {
    final date = await brandDatePicker(
      context,
      initial: _dueDate,
      first: DateTime(2000),
      last: DateTime(2100),
      title: 'Due date',
    );
    if (date == null || !mounted) return;

    final wantsTime = await brandConfirm(
      context,
      title: 'Add a time?',
      cancelLabel: 'All day',
      confirmLabel: 'Pick time',
    );
    if (!mounted) return;

    if (wantsTime) {
      final minutes = await brandTimePicker(
        context,
        initialMinutes: _minutesOf(_dueDate ?? DateTime.now()),
        title: 'Due time',
      );
      if (minutes != null) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            minutes ~/ 60,
            minutes % 60,
          );
          _hasTime = true;
        });
        return;
      }
    }
    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day);
      _hasTime = false;
    });
  }

  static int _minutesOf(DateTime d) => d.hour * 60 + d.minute;

  Future<void> _pickReminder() async {
    final date = await brandDatePicker(
      context,
      initial: _reminder ?? _dueDate,
      first: DateTime.now().subtract(const Duration(days: 1)),
      last: DateTime(2100),
      title: 'Reminder date',
    );
    if (date == null || !mounted) return;
    final minutes = await brandTimePicker(
      context,
      initialMinutes: _minutesOf(
        _reminder ?? DateTime.now().add(const Duration(hours: 1)),
      ),
      title: 'Reminder time',
    );
    if (minutes == null) return;
    setState(() {
      _reminder = DateTime(
        date.year,
        date.month,
        date.day,
        minutes ~/ 60,
        minutes % 60,
      );
    });
  }

  Future<void> _pickRecurrence() async {
    final picked = await brandSheet<String?>(
      context: context,
      builder: (_) => SheetScaffold(
        title: 'Repeat',
        child: TileColumn(
          children: [
            BrandTile(
              title: const Text('Does not repeat'),
              onTap: () => Navigator.pop(context, ''),
            ),
            ...Recurrence.presets.entries.map(
              (e) => BrandTile(
                title: Text(e.value),
                selected: _recurrence == e.key,
                onTap: () => Navigator.pop(context, e.key),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _recurrence = picked.isEmpty ? null : picked);
  }

  Future<void> _pickEstimate() async {
    final picked = await brandSheet<int>(
      context: context,
      builder: (_) => SheetScaffold(
        title: 'Time estimate',
        child: TileColumn(
          children: [15, 25, 30, 45, 60, 90, 120]
              .map(
                (m) => BrandTile(
                  leading: const AppIcon(AppIcons.focus),
                  title: Text(Fmt.durationFromMinutes(m)),
                  selected: _estimate == m,
                  onTap: () => Navigator.pop(context, m),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked != null) setState(() => _estimate = picked);
  }
}

class _SubtaskList extends ConsumerWidget {
  final int parentId;
  const _SubtaskList({required this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasks = ref.watch(subtasksProvider(parentId));
    return subtasks.maybeWhen(
      data: (list) => TileColumn(
        children: list
            .map(
              (s) => BrandTile(
                leading: BrandCheckbox(
                  value: s.isCompleted,
                  color: context.brand.task,
                  semanticsLabel: s.title,
                  onChanged: (v) =>
                      ref.read(taskRepositoryProvider).setCompleted(s.id, v),
                ),
                title: Text(
                  s.title,
                  style: TextStyle(
                    fontSize: 14,
                    decoration: s.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                trailing: CircleIconButton(
                  icon: AppIcons.close,
                  size: 40,
                  onPressed: () =>
                      ref.read(taskRepositoryProvider).deleteTask(s.id),
                ),
              ),
            )
            .toList(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
