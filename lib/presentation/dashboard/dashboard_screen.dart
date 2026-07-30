import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../expenses/providers/expenses_provider.dart';
import '../focus/providers/focus_provider.dart';
import '../habits/providers/habits_provider.dart';
import '../habits/repository/habit_repository.dart';
import '../medicine/medicine_screen.dart' show DoseTile;
import '../medicine/providers/medicine_provider.dart';
import '../medicine/repository/medicine_repository.dart';
import '../notes/providers/notes_provider.dart';
import '../notes/repository/note_repository.dart';
import '../tasks/providers/tasks_provider.dart';
import '../tasks/widgets/task_tile.dart';

/// The home screen, laid out to the fitness reference: greeting header, a hero
/// card for the next thing due, a pastel "My Plans" row of module stats, an
/// activity chart, then the per-module detail sections.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // Widgets are keyed by module name so the order is user-configurable.
    final builders = <String, Widget Function()>{
      'medicine': () => const _MedicineWidget(),
      'tasks': () => const _TasksWidget(),
      'habits': () => const _HabitsWidget(),
      'expenses': () => const _ExpensesWidget(),
      'focus': () => const _FocusWidget(),
      'notes': () => const _NotesWidget(),
    };

    final ordered = settings.dashboardOrder
        .where((key) => builders.containsKey(key))
        .where((key) => settings.enabledModules.any((m) => m.name == key))
        .toList();

    return BrandScaffold(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
          children: [
            GreetingHeader(
              greeting: '${Fmt.greeting()},',
              subtitle: Fmt.fullDate(DateTime.now()),
              initials: 'mS',
              actions: [
                CircleIconButton(
                  icon: AppIcons.search,
                  tooltip: 'Search everything',
                  onPressed: () => context.push('/search'),
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: AppIcons.notifications,
                  tooltip: 'Reminders',
                  onPressed: () => context.push('/reminders'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const _NextUpBanner(),
            const SizedBox(height: 26),
            const SectionHeader('My plans'),
            const _TodaySummary(),
            const SizedBox(height: 26),
            const _ActivityChart(),
            if (ordered.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: EmptyState(
                  icon: AppIcons.modules,
                  title: 'No modules enabled',
                  message: 'Turn some on in Settings to fill your dashboard.',
                ),
              ),
            for (final key in ordered) ...[
              const SizedBox(height: 26),
              builders[key]!(),
            ],
          ],
        ),
      ),
    );
  }
}

/// The hero card. It surfaces whatever is most pressing right now — the next
/// dose, else the next task, else an invitation to focus — so the biggest
/// element on the screen is never decorative.
class _NextUpBanner extends ConsumerWidget {
  const _NextUpBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    if (settings.isEnabled(AppModule.medicine)) {
      final doses = ref.watch(todayDoseViewsProvider).valueOrNull ?? const [];
      final next = doses
          .where((d) => d.status == DoseStatus.pending)
          .firstOrNull;
      if (next != null) {
        return HeroBanner(
          label: 'Medicine',
          headline: 'Take ${next.medicine.name}',
          footnote:
              '${Fmt.time(next.dose.scheduledTime)} · ${next.dosageLabel}',
          icon: AppIcons.medicineForm(next.medicine.form),
          accent: AppColors.medicineAccent,
          onTap: () => context.push('/medicine'),
        );
      }
    }

    if (settings.isEnabled(AppModule.tasks)) {
      final tasks = ref.watch(todayTasksProvider).valueOrNull ?? const [];
      final next = tasks.where((t) => !t.isCompleted).firstOrNull;
      if (next != null) {
        final due = next.dueDate;
        return HeroBanner(
          label: 'Tasks',
          headline: next.title,
          footnote: due == null
              ? 'Due today'
              : 'Due ${Fmt.due(due, withTime: next.hasDueTime)}',
          icon: AppIcons.tasks,
          accent: AppColors.taskAccent,
          onTap: () => context.push('/tasks'),
        );
      }
    }

    if (settings.isEnabled(AppModule.focus)) {
      final stats = ref.watch(focusStatsProvider).valueOrNull;
      return HeroBanner(
        label: 'Focus',
        headline: 'Start a focus session',
        footnote: stats == null || stats.today == Duration.zero
            ? 'Nothing focused yet today'
            : '${Fmt.duration(stats.today)} focused so far',
        icon: AppIcons.focus,
        accent: AppColors.focusAccent,
        onTap: () => context.push('/focus'),
      );
    }

    return HeroBanner(
      label: 'All clear',
      headline: 'Nothing needs you right now',
      footnote: Fmt.fullDate(DateTime.now()),
      icon: AppIcons.checkCircle,
      accent: AppColors.habitAccent,
      onTap: () => context.push('/insights'),
    );
  }
}

/// The "My plans" row: one pastel stat card per enabled module.
class _TodaySummary extends ConsumerWidget {
  const _TodaySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currency = settings.currencySymbol;

    final cards = <Widget>[];

    void add(PlanCard Function(int tint) build) =>
        cards.add(build(cards.length));

    if (settings.isEnabled(AppModule.medicine)) {
      final doses = ref.watch(todayDoseViewsProvider).valueOrNull ?? const [];
      final remaining = doses
          .where((d) => d.status == DoseStatus.pending)
          .length;
      add(
        (tint) => PlanCard(
          icon: AppIcons.medicine,
          accent: AppColors.medicineAccent,
          label: 'Medicine',
          value: remaining == 0 ? 'All taken' : '$remaining left',
          tintIndex: tint,
          onTap: () => context.push('/medicine'),
        ),
      );
    }
    if (settings.isEnabled(AppModule.tasks)) {
      final tasks = ref.watch(todayTasksProvider).valueOrNull ?? const [];
      final open = tasks.where((t) => !t.isCompleted).length;
      add(
        (tint) => PlanCard(
          icon: AppIcons.tasks,
          accent: AppColors.taskAccent,
          label: 'Tasks',
          value: open == 0 ? 'All done' : '$open due',
          tintIndex: tint,
          onTap: () => context.push('/tasks'),
        ),
      );
    }
    if (settings.isEnabled(AppModule.focus)) {
      final stats = ref.watch(focusStatsProvider).valueOrNull;
      add(
        (tint) => PlanCard(
          icon: AppIcons.focus,
          accent: AppColors.focusAccent,
          label: 'Focus',
          value: Fmt.duration(stats?.today ?? Duration.zero),
          tintIndex: tint,
          onTap: () => context.push('/focus'),
        ),
      );
    }
    if (settings.isEnabled(AppModule.expenses)) {
      final today = ref.watch(recentExpensesProvider).valueOrNull ?? const [];
      final spentToday = today
          .where((e) => e.kind == 0 && Fmt.isSameDay(e.date, DateTime.now()))
          .fold<double>(0, (a, e) => a + e.amount);
      add(
        (tint) => PlanCard(
          icon: AppIcons.expenses,
          accent: AppColors.expenseAccent,
          label: 'Spent',
          value: Fmt.compactMoney(spentToday, currency),
          tintIndex: tint,
          onTap: () => context.push('/expenses'),
        ),
      );
    }
    if (settings.isEnabled(AppModule.habits)) {
      final habits = ref.watch(habitsListProvider).valueOrNull ?? const [];
      final logs = ref.watch(todayHabitLogsProvider).valueOrNull ?? const {};
      final done = habits.where((h) {
        final amount = logs[h.id] ?? 0;
        return h.goalType == 0
            ? amount >= h.targetAmount
            : amount <= h.targetAmount;
      }).length;
      add(
        (tint) => PlanCard(
          icon: AppIcons.habits,
          accent: AppColors.habitAccent,
          label: 'Habits',
          value: habits.isEmpty ? 'None yet' : '$done / ${habits.length}',
          tintIndex: tint,
          onTap: () => context.push('/habits'),
        ),
      );
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    // A horizontal rail keeps three cards visible at the reference proportions
    // no matter how many modules are switched on.
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(width: 112, child: cards[i]),
      ),
    );
  }
}

/// The "Activities" spline. It plots whatever real seven-day series the user's
/// enabled modules can supply, and names what it is plotting rather than
/// implying a generic score.
class _ActivityChart extends ConsumerWidget {
  const _ActivityChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final today = Fmt.dateOnly(DateTime.now());
    final days = [
      for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i)),
    ];

    List<double>? values;
    String title;
    String Function(double) tick = (v) => v.round().toString();

    if (settings.isEnabled(AppModule.focus)) {
      final stats = ref.watch(focusStatsProvider).valueOrNull;
      if (stats != null && stats.byDay.isNotEmpty) {
        values = [
          for (final d in days)
            (stats.byDay[d] ?? Duration.zero).inMinutes.toDouble(),
        ];
        title = 'Focus minutes';
      } else {
        title = 'Activity';
      }
    } else {
      title = 'Activity';
    }

    if (values == null && settings.isEnabled(AppModule.tasks)) {
      final stats = ref.watch(taskStatsProvider(7)).valueOrNull;
      if (stats != null && stats.perDay.isNotEmpty) {
        values = [for (final d in days) (stats.perDay[d] ?? 0).toDouble()];
        title = 'Tasks completed';
      }
    }

    if (values == null && settings.isEnabled(AppModule.expenses)) {
      final expenses = ref.watch(monthTransactionsProvider).valueOrNull;
      if (expenses != null && expenses.isNotEmpty) {
        values = [
          for (final d in days)
            expenses
                .where((e) => e.kind == 0 && Fmt.isSameDay(e.date, d))
                .fold<double>(0, (a, e) => a + e.amount),
        ];
        title = 'Daily spending';
        final symbol = settings.currencySymbol;
        tick = (v) => Fmt.compactMoney(v, symbol);
      }
    }

    if (values == null || values.every((v) => v == 0)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title),
        SplineChart(
          values: values,
          labels: [for (final d in days) Fmt.weekday(d)],
          color: Theme.of(context).colorScheme.primary,
          highlight: values.length - 1,
          formatTick: tick,
        ),
      ],
    );
  }
}

class _MedicineWidget extends ConsumerWidget {
  const _MedicineWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doses = ref.watch(todayDoseViewsProvider).valueOrNull ?? const [];
    final upcoming = doses
        .where((d) => d.status == DoseStatus.pending)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Medicine',
          actionLabel: 'Open',
          onAction: () => context.push('/medicine'),
        ),
        if (upcoming.isEmpty)
          _quiet(context, 'All doses handled for today.')
        else
          ...upcoming.map((v) => DoseTile(view: v)),
      ],
    );
  }
}

class _TasksWidget extends ConsumerWidget {
  const _TasksWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todayTasksProvider).valueOrNull ?? const [];
    final open = tasks.where((t) => !t.isCompleted).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Tasks due today',
          actionLabel: 'Open',
          onAction: () => context.push('/tasks'),
        ),
        if (open.isEmpty)
          _quiet(context, 'Nothing due — you are all caught up.')
        else
          ...open.map((t) => TaskTile(task: t, dense: true)),
      ],
    );
  }
}

class _HabitsWidget extends ConsumerWidget {
  const _HabitsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsListProvider).valueOrNull ?? const [];
    final today = ref.watch(todayHabitLogsProvider).valueOrNull ?? const {};
    final repo = ref.read(habitRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Habits',
          actionLabel: 'Open',
          onAction: () => context.push('/habits'),
        ),
        if (habits.isEmpty)
          _quiet(context, 'No habits yet.')
        else
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: habits.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final h = habits[i];
                final amount = today[h.id] ?? 0;
                final color = Color(h.color);
                final done = h.goalType == 0
                    ? amount >= h.targetAmount
                    : amount <= h.targetAmount;
                return SizedBox(
                  width: 120,
                  child: TintCard(
                    accent: color,
                    padding: const EdgeInsets.all(14),
                    onTap: () => context.push('/habits'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppIcon(
                              AppIcons.habit(h.icon),
                              color: color,
                              size: 22,
                            ),
                            const Spacer(),
                            if (done)
                              AppIcon(
                                AppIcons.checkCircle,
                                size: 16,
                                color: color,
                              ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          h.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_trim(amount)} / ${_trim(h.targetAmount)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.muted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // 2-tap logging straight from the dashboard.
                            FTappable(
                              onPress: () => repo.addToDay(h.id, 1),
                              semanticsLabel: 'Log ${h.name}',
                              child: AppIcon(
                                AppIcons.addCircle,
                                color: color,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ExpensesWidget extends ConsumerWidget {
  const _ExpensesWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final recent = ref.watch(recentExpensesProvider).valueOrNull ?? const [];
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final todays = recent
        .where((e) => Fmt.isSameDay(e.date, DateTime.now()))
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          "Today's spending",
          actionLabel: 'Open',
          onAction: () => context.push('/expenses'),
        ),
        if (todays.isEmpty)
          _quiet(context, 'Nothing recorded today.')
        else
          TintCard(
            tintIndex: 1,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              children: [
                for (final e in todays)
                  Builder(
                    builder: (context) {
                      final cat = categories
                          .where((c) => c.id == e.categoryId)
                          .firstOrNull;
                      return BrandTile(
                        leading: AppIcon(
                          AppIcons.category(cat?.icon ?? 'other'),
                          color: Color(cat?.color ?? 0xFF6C6C6C),
                          size: 22,
                        ),
                        title: Text(
                          e.note?.isNotEmpty == true
                              ? e.note!
                              : cat?.name ?? 'Expense',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          Fmt.money(e.amount, currency),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FocusWidget extends ConsumerWidget {
  const _FocusWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(focusStatsProvider).valueOrNull ?? FocusStats.empty;
    final goal = ref.watch(focusGoalProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Focus',
          actionLabel: 'Start',
          onAction: () => context.push('/focus'),
        ),
        TintCard(
          accent: AppColors.focusAccent,
          child: Row(
            children: [
              ProgressRing(
                value: goal == 0 ? 0 : stats.today.inMinutes / goal,
                size: 84,
                thickness: 10,
                dashedGuide: false,
                color: AppColors.focusAccent,
                center: FittedBox(
                  child: Text(
                    Fmt.percent(goal == 0 ? 0 : stats.today.inMinutes / goal),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Fmt.duration(stats.today),
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 24),
                    ),
                    Text(
                      'of ${Fmt.durationFromMinutes(goal)} · '
                      '${stats.sessionsToday} sessions',
                      style: TextStyle(color: context.muted, fontSize: 13),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesWidget extends ConsumerWidget {
  const _NotesWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(recentNotesProvider).valueOrNull ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Recent notes',
          actionLabel: 'Open',
          onAction: () => context.push('/notes'),
        ),
        if (notes.isEmpty)
          _quiet(context, 'No notes yet.')
        else
          TintCard(
            tintIndex: 2,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              children: [
                for (final n in notes)
                  BrandTile(
                    leading: const AppIcon(
                      AppIcons.notes,
                      color: AppColors.noteAccent,
                      size: 22,
                    ),
                    title: Text(
                      n.title,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      NoteRepository.previewOf(n.content, max: 60),
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => context.push('/note_editor', extra: n.id),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

String _trim(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

Widget _quiet(BuildContext context, String message) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Text(message, style: TextStyle(color: context.muted, fontSize: 14)),
);
