import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/speech_service.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import 'providers/tasks_provider.dart';
import 'repository/task_repository.dart';
import 'utils/nlp_parser.dart';
import 'widgets/task_editor_sheet.dart';
import 'widgets/task_tile.dart';

/// Filters the list views to a single project when set from the drawer.
final taskProjectFilterProvider = StateProvider<int?>((ref) => null);

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _quickAdd = TextEditingController();
  bool _listening = false;

  @override
  void dispose() {
    _quickAdd.dispose();
    if (_listening) ref.read(speechServiceProvider).stop();
    super.dispose();
  }

  Future<void> _submitQuickAdd() async {
    final raw = _quickAdd.text.trim();
    if (raw.isEmpty) return;

    final parsed = NlpParser.parse(raw);
    final repo = ref.read(taskRepositoryProvider);
    final id = await repo.createTask(
      title: parsed.title,
      dueDate: parsed.dueDate,
      hasDueTime: parsed.hasTime,
      priority: parsed.priority,
      projectId: ref.read(taskProjectFilterProvider),
      recurrenceRule: parsed.recurrenceRule,
      estimateMinutes: parsed.estimateMinutes,
    );
    if (parsed.tags.isNotEmpty) await repo.setTaskTags(id, parsed.tags);

    _quickAdd.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  Future<void> _dictate() async {
    final speech = ref.read(speechServiceProvider);
    if (_listening) {
      await speech.stop();
      setState(() => _listening = false);
      return;
    }
    final started = await speech.listen(
      onResult: (words, isFinal) {
        _quickAdd.text = words;
        if (isFinal && mounted) setState(() => _listening = false);
      },
    );
    if (!started) {
      if (mounted) {
        brandToast(context, 'Speech recognition unavailable on this device.');
      }
      return;
    }
    setState(() => _listening = true);
  }

  @override
  Widget build(BuildContext context) {
    final projectId = ref.watch(taskProjectFilterProvider);
    final projects = ref.watch(projectsProvider).valueOrNull ?? const [];
    final projectName = projectId == null
        ? 'Tasks'
        : projects.where((p) => p.id == projectId).firstOrNull?.name ?? 'Tasks';

    return BrandScaffold(
      header: BrandTopBar(
        title: projectName,
        // The project list used to be a Scaffold drawer, opened by the AppBar's
        // implicit hamburger. FScaffold has no drawer slot and no app bar to
        // host one, so it is now an explicit button onto a left-hand sheet.
        leadingIcon: AppIcons.folder,
        onLeading: () => brandSideSheet(
          context: context,
          builder: (_) => const _ProjectDrawer(),
        ),
        actions: [
          CircleIconButton(
            icon: AppIcons.search,
            tooltip: 'Search',
            size: 40,
            onPressed: () => context.push('/search'),
          ),
          if (projectId != null)
            CircleIconButton(
              icon: AppIcons.filterOff,
              tooltip: 'Clear project filter',
              size: 40,
              onPressed: () =>
                  ref.read(taskProjectFilterProvider.notifier).state = null,
            ),
        ],
      ),
      floatingAction: BrandFab(
        icon: AppIcons.add,
        tooltip: 'New task',
        onPressed: () => TaskEditorSheet.show(
          context,
          projectId: ref.read(taskProjectFilterProvider),
        ),
      ),
      child: Column(
        children: [
          _buildQuickAdd(),
          // BrandTabs owns both the tab strip and the views, so the strip moves
          // out of the header and into the body.
          Expanded(
            child: BrandTabs(
              tabs: {
                'Today': _TaskListView(
                  provider: todayTasksProvider,
                  emptyTitle: 'Nothing due today',
                  emptyMessage: 'Enjoy the clear runway.',
                ),
                'Upcoming': _TaskListView(
                  provider: upcomingTasksProvider,
                  emptyTitle: 'Nothing in the next 7 days',
                  groupByDay: true,
                ),
                'Inbox': _TaskListView(
                  provider: inboxTasksProvider,
                  emptyTitle: 'Inbox zero',
                  emptyMessage: 'Quick captures without a date land here.',
                ),
                'Calendar': const _CalendarView(),
                'Kanban': const _KanbanView(),
                'Matrix': const _MatrixView(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdd() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: BrandField(
        controller: _quickAdd,
        onSubmit: (_) => _submitQuickAdd(),
        textInputAction: TextInputAction.done,
        hint: 'Buy milk tomorrow 5pm #shopping !high',
        prefix: const AppIcon(AppIcons.add, size: 20),
        suffix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleIconButton(
              icon: AppIcons.mic,
              tooltip: 'Dictate',
              color: _listening ? context.brand.danger : null,
              size: 40,
              onPressed: _dictate,
            ),
            CircleIconButton(
              icon: AppIcons.arrowUp,
              tooltip: 'Add',
              color: context.brand.task,
              size: 40,
              onPressed: _submitQuickAdd,
            ),
          ],
        ),
      ),
    );
  }
}

/// Applies the active project filter to any task list.
List<Task> _applyFilter(List<Task> tasks, int? projectId) => projectId == null
    ? tasks
    : tasks.where((t) => t.projectId == projectId).toList();

class _TaskListView extends ConsumerWidget {
  final StreamProvider<List<Task>> provider;
  final String emptyTitle;
  final String? emptyMessage;
  final bool groupByDay;

  const _TaskListView({
    required this.provider,
    required this.emptyTitle,
    this.emptyMessage,
    this.groupByDay = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);
    final projectId = ref.watch(taskProjectFilterProvider);

    return async.when(
      data: (all) {
        final tasks = _applyFilter(all, projectId);
        if (tasks.isEmpty) {
          return EmptyState(
            icon: AppIcons.checkCircle,
            title: emptyTitle,
            message: emptyMessage,
          );
        }
        if (!groupByDay) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: tasks.length,
            itemBuilder: (_, i) => TaskTile(task: tasks[i]),
          );
        }

        final groups = <DateTime, List<Task>>{};
        for (final t in tasks) {
          if (t.dueDate == null) continue;
          groups.putIfAbsent(Fmt.dateOnly(t.dueDate!), () => []).add(t);
        }
        final days = groups.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          itemCount: days.length,
          itemBuilder: (_, i) {
            final day = days[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    Fmt.relativeDay(day),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                ...groups[day]!.map((t) => TaskTile(task: t, showDue: false)),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: BrandSpinner()),
      error: (e, _) =>
          EmptyState(icon: AppIcons.error, title: 'Error', message: '$e'),
    );
  }
}

// --- Calendar ---------------------------------------------------------------

final _calendarMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month),
);

final _calendarSelectedProvider = StateProvider<DateTime>(
  (ref) => Fmt.dateOnly(DateTime.now()),
);

class _CalendarView extends ConsumerWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(_calendarMonthProvider);
    final selected = ref.watch(_calendarSelectedProvider);
    final grouped =
        ref.watch(monthTasksProvider(month)).valueOrNull ?? const {};
    final muted = Theme.of(context).colorScheme.outline;

    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday - 1;
    final selectedTasks = grouped[selected] ?? const <Task>[];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              CircleIconButton(
                icon: AppIcons.chevronLeft,
                size: 40,
                onPressed: () =>
                    ref.read(_calendarMonthProvider.notifier).state = DateTime(
                      month.year,
                      month.month - 1,
                    ),
              ),
              Expanded(
                child: Text(
                  Fmt.monthYear(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              CircleIconButton(
                icon: AppIcons.chevronRight,
                size: 40,
                onPressed: () =>
                    ref.read(_calendarMonthProvider.notifier).state = DateTime(
                      month.year,
                      month.month + 1,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (_, i) {
              if (i < leadingBlanks) return const SizedBox.shrink();
              final day = DateTime(
                month.year,
                month.month,
                i - leadingBlanks + 1,
              );
              final count = (grouped[day] ?? const []).length;
              final isSelected = Fmt.isSameDay(day, selected);
              final isToday = Fmt.isSameDay(day, DateTime.now());

              return GestureDetector(
                onTap: () =>
                    ref.read(_calendarSelectedProvider.notifier).state = day,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.brand.task
                        : isToday
                        ? context.brand.task.withValues(alpha: 0.12)
                        : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? context.brand.onAccent(context.brand.task)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (count > 0)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : context.brand.task,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        BrandDivider(),
        Expanded(
          child: selectedTasks.isEmpty
              ? EmptyState(
                  icon: AppIcons.calendarDone,
                  title: 'Nothing on ${Fmt.relativeDay(selected)}',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  children: selectedTasks
                      .map((t) => TaskTile(task: t, showDue: false))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

// --- Kanban -----------------------------------------------------------------

class _KanbanView extends ConsumerWidget {
  const _KanbanView();

  /// The three board columns. The colours move with the palette, so this is
  /// resolved per build rather than held as a const.
  static List<(int, String, Color)> _columnsOf(BuildContext context) => [
    (0, 'To Do', context.muted),
    (1, 'Doing', context.brand.warning),
    (2, 'Done', context.brand.success),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allTasksProvider);
    final projectId = ref.watch(taskProjectFilterProvider);

    return async.when(
      data: (all) {
        final tasks = _applyFilter(all, projectId);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _columnsOf(context).map((col) {
              final (status, label, color) = col;
              // "Done" is driven by completion, not just the board column, so
              // completing a task anywhere moves it here.
              final items = tasks
                  .where(
                    (t) => status == 2
                        ? t.isCompleted
                        : !t.isCompleted && t.boardStatus == status,
                  )
                  .toList();

              return Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: DragTarget<Task>(
                  onAcceptWithDetails: (details) async {
                    final repo = ref.read(taskRepositoryProvider);
                    final task = details.data;
                    if (status == 2) {
                      await repo.setCompleted(task.id, true);
                    } else {
                      if (task.isCompleted) {
                        await repo.setCompleted(task.id, false);
                      }
                      await repo.updateTask(task.id, boardStatus: status);
                    }
                  },
                  builder: (context, candidate, _) {
                    return Container(
                      decoration: BoxDecoration(
                        color: candidate.isNotEmpty
                            ? color.withValues(alpha: 0.12)
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${items.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'Drop tasks here',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ),
                              ),
                            ),
                          ...items.map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: LongPressDraggable<Task>(
                                data: t,
                                // Stays Material: drag feedback is mounted in
                                // the Overlay rather than in this subtree, and
                                // this is the idiomatic ancestor for it.
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: 260,
                                    child: _KanbanCard(task: t, dragging: true),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _KanbanCard(task: t),
                                ),
                                child: _KanbanCard(task: t),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(child: BrandSpinner()),
      error: (e, _) =>
          EmptyState(icon: AppIcons.error, title: 'Error', message: '$e'),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Task task;
  final bool dragging;

  const _KanbanCard({required this.task, this.dragging = false});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outline;
    return TintCard(
      padding: EdgeInsets.zero,
      onTap: () => TaskEditorSheet.show(context, task: task),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                color: priorityColor(
                  context.brand,
                  context.muted,
                  task.priority,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.dueDate != null)
                    Text(
                      Fmt.relativeDay(task.dueDate!),
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Eisenhower matrix ------------------------------------------------------

class _MatrixView extends ConsumerWidget {
  const _MatrixView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(openTasksProvider);
    final projectId = ref.watch(taskProjectFilterProvider);

    return async.when(
      data: (all) {
        final tasks = _applyFilter(all, projectId);
        final soon = DateTime.now().add(const Duration(days: 2));

        // Urgency comes from the due date, importance from the priority level.
        bool urgent(Task t) => t.dueDate != null && t.dueDate!.isBefore(soon);
        bool important(Task t) => t.priority <= 2;

        final quadrants = [
          (
            'Do first',
            'Urgent & important',
            context.brand.danger,
            tasks.where((t) => urgent(t) && important(t)).toList(),
          ),
          (
            'Schedule',
            'Important, not urgent',
            context.brand.task,
            tasks.where((t) => !urgent(t) && important(t)).toList(),
          ),
          (
            'Delegate',
            'Urgent, not important',
            context.brand.warning,
            tasks.where((t) => urgent(t) && !important(t)).toList(),
          ),
          (
            'Eliminate',
            'Neither',
            context.muted,
            tasks.where((t) => !urgent(t) && !important(t)).toList(),
          ),
        ];

        return GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
          childAspectRatio: 0.78,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: quadrants.map((q) {
            final (title, subtitle, color, items) = q;
            return TintCard(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Text(
                                'Empty',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            )
                          : ListView(
                              padding: EdgeInsets.zero,
                              children: items
                                  .map(
                                    (t) => BrandTappable(
                                      onPressed: () => TaskEditorSheet.show(
                                        context,
                                        task: t,
                                      ),
                                      semanticsLabel: t.title,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '• ',
                                              style: TextStyle(color: color),
                                            ),
                                            Expanded(
                                              child: Text(
                                                t.title,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: BrandSpinner()),
      error: (e, _) =>
          EmptyState(icon: AppIcons.error, title: 'Error', message: '$e'),
    );
  }
}

// --- Project drawer ---------------------------------------------------------

class _ProjectDrawer extends ConsumerWidget {
  const _ProjectDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final selected = ref.watch(taskProjectFilterProvider);
    final counts = ref.watch(openTasksProvider).valueOrNull ?? const [];

    // Stays a Material `Drawer` body rather than an `FSidebar` — see the note on
    // `_NotesDrawer`. The accent `DrawerHeader` is brand chrome forui has no
    // equivalent for.
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: context.brand.task),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Projects',
                style: TextStyle(
                  color: context.brand.onAccent(context.brand.task),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Padding(
            // The header above is full-bleed; everything below it is a card,
            // so it needs the panel's gutter.
            padding: const EdgeInsets.symmetric(horizontal: drawerGutter),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandTile(
                  leading: const AppIcon(AppIcons.inbox, size: 20),
                  title: const Text('All tasks'),
                  selected: selected == null,
                  onTap: () {
                    ref.read(taskProjectFilterProvider.notifier).state = null;
                    Navigator.pop(context);
                  },
                ),
                BrandDivider(),
                projects.maybeWhen(
                  data: (list) => TileColumn(
                    mainAxisSize: MainAxisSize.min,
                    children: list.map((p) {
                      final open = counts
                          .where((t) => t.projectId == p.id)
                          .length;
                      return BrandTile(
                        leading: AppIcon(
                          AppIcons.project(p.icon),
                          size: 20,
                          color: Color(p.color),
                        ),
                        title: Text(p.name),
                        trailing: open == 0
                            ? null
                            : Text(
                                '$open',
                                style: const TextStyle(fontSize: 12),
                              ),
                        selected: selected == p.id,
                        onTap: () {
                          ref.read(taskProjectFilterProvider.notifier).state =
                              p.id;
                          Navigator.pop(context);
                        },
                        onLongPress: () async {
                          Navigator.pop(context);
                          await ref
                              .read(taskRepositoryProvider)
                              .deleteProject(p.id);
                        },
                      );
                    }).toList(),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                BrandDivider(),
                BrandTile(
                  leading: const AppIcon(AppIcons.add, size: 20),
                  title: const Text('New project'),
                  onTap: () => _createProject(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    var color = ColorPickerRow.palette.first;
    var icon = 'folder';

    final created = await brandDialog<bool>(
      context,
      title: 'New project',
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrandField(
              controller: controller,
              autofocus: true,
              hint: 'Project name',
            ),
            const SizedBox(height: 16),
            ColorPickerRow(
              selected: color,
              onChanged: (c) => setState(() => color = c),
            ),
            const SizedBox(height: 12),
            IconPickerRow(
              options: AppIcons.projectIcons,
              selected: icon,
              color: Color(color),
              onChanged: (i) => setState(() => icon = i),
            ),
            const SizedBox(height: 20),
            BrandButton(
              label: 'Create',
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

    if (created == true && controller.text.trim().isNotEmpty) {
      await ref
          .read(taskRepositoryProvider)
          .createProject(controller.text.trim(), color, icon);
    }
    if (context.mounted) Navigator.of(context).maybePop();
  }
}
