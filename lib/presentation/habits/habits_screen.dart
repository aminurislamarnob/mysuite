import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../core/database/app_database.dart';
import '../../core/services/notification_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import 'providers/habits_provider.dart';
import 'repository/habit_repository.dart';
import 'utils/habit_stats.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsListProvider);
    final caffeine = ref.watch(caffeineTodayProvider).valueOrNull ?? 0;
    final cost = ref.watch(habitCostTodayProvider).valueOrNull ?? 0;
    final currency = ref.watch(settingsProvider).currencySymbol;

    return BrandScaffold(
      header: BrandTopBar(
        title: 'Habits',
        leadingIcon: AppIcons.back,
        actions: [
          CircleIconButton(
            icon: AppIcons.add,
            tooltip: 'Add habit',
            size: 40,
            onPressed: () => HabitEditorSheet.show(context),
          ),
        ],
      ),
      child: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return EmptyState(
              icon: AppIcons.habits,
              title: 'No habits yet',
              message: 'Track water, coffee, exercise — anything you repeat.',
              actionLabel: 'Add a habit',
              onAction: () => HabitEditorSheet.show(context),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (caffeine > 0 || cost > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      if (caffeine > 0)
                        Expanded(
                          child: StatTile(
                            icon: AppIcons.quick,
                            color: AppColors.warningLight,
                            label: 'Caffeine today',
                            value: '${caffeine.toStringAsFixed(0)} mg',
                            sublabel: caffeine > 400
                                ? 'Above 400mg guide'
                                : null,
                          ),
                        ),
                      if (caffeine > 0 && cost > 0) const SizedBox(width: 12),
                      if (cost > 0)
                        Expanded(
                          child: StatTile(
                            icon: AppIcons.savings,
                            color: AppColors.expenseAccent,
                            label: 'Habit spend today',
                            value: Fmt.money(cost, currency),
                          ),
                        ),
                    ],
                  ),
                ),
              ...habits.map(
                (h) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HabitCard(habit: h),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: FCircularProgress()),
        error: (e, _) =>
            EmptyState(icon: AppIcons.error, title: 'Error', message: '$e'),
      ),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(habitStatsProvider(habit.id));
    final stats = statsAsync.valueOrNull ?? HabitStats.empty;
    final color = Color(habit.color);
    final muted = Theme.of(context).colorScheme.outline;
    final repo = ref.read(habitRepositoryProvider);
    final isReduce = habit.goalType == 1;
    final over = stats.overLimit(habit);

    final progress = habit.targetAmount <= 0
        ? (stats.todayAmount > 0 ? 1.0 : 0.0)
        : stats.todayAmount / habit.targetAmount;

    return TintCard(
      padding: EdgeInsets.zero,
      onTap: () => _openDetail(context),
      onLongPress: () => HabitEditorSheet.show(context, habit: habit),
      child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(
                      AppIcons.habit(habit.icon),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            AppIcon(
                              AppIcons.streak,
                              size: 13,
                              color: stats.currentStreak > 0
                                  ? AppColors.warningLight
                                  : muted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${stats.currentStreak} day streak',
                              style: TextStyle(fontSize: 11, color: muted),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${Fmt.percent(stats.completionRate)} complete',
                              style: TextStyle(fontSize: 11, color: muted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 2-tap logging: this button is the second tap.
                  CircleIconButton(
                    icon: AppIcons.addCircle,
                    tooltip: isReduce ? 'Log one' : 'Add one',
                    color: over ? AppColors.dangerLight : color,
                    size: 40,
                    onPressed: () async {
                      await repo.addToDay(habit.id, 1);
                      if (!context.mounted) return;
                      final next = stats.todayAmount + 1;
                      if (isReduce && next > habit.targetAmount) {
                        brandToast(
                          context,
                          'That is ${next.toStringAsFixed(0)} today — '
                          'your limit is ${habit.targetAmount.toStringAsFixed(0)}.',
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LabeledProgress(
                label: isReduce ? 'Daily limit' : 'Today',
                trailing:
                    '${_trim(stats.todayAmount)} / ${_trim(habit.targetAmount)}'
                    '${habit.unit == null ? '' : ' ${habit.unit}'}',
                value: progress,
                color: over ? AppColors.dangerLight : color,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 7 * 17.0,
                child: ContributionHeatmap(
                  days: 84,
                  color: color,
                  cell: 14,
                  intensityFor: (day) => stats.intensityOn(day, habit),
                  onTapDay: (day) => _editDay(context, ref, day, stats),
                ),
              ),
            ],
          ),
      ),
    );
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  void _openDetail(BuildContext context) {
    brandSheet(
      context: context,
      builder: (_) => _HabitDetailSheet(habit: habit),
    );
  }

  /// Bulk back-fill: tapping a heatmap cell edits that day's amount.
  Future<void> _editDay(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    HabitStats stats,
  ) async {
    final controller = TextEditingController(
      text: _trim(stats.byDay[Fmt.dateOnly(day)] ?? 0),
    );
    final result = await brandDialog<String>(
      context,
      title: Fmt.dayMonthYear(day),
      builder: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandField(
            controller: controller,
            label: 'Amount',
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: habit.unit == null ? null : Text(habit.unit!),
          ),
          const SizedBox(height: 20),
          BrandButton(
            label: 'Save',
            onPressed: () => Navigator.pop(dialogContext, controller.text),
          ),
          const SizedBox(height: 8),
          BrandButton(
            label: 'Cancel',
            kind: BrandButtonKind.ghost,
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
    if (result == null) return;
    final amount = double.tryParse(result.trim());
    if (amount == null) return;
    await ref.read(habitRepositoryProvider).setDayAmount(habit.id, day, amount);
  }
}

class _HabitDetailSheet extends ConsumerWidget {
  final Habit habit;
  const _HabitDetailSheet({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats =
        ref.watch(habitStatsProvider(habit.id)).valueOrNull ?? HabitStats.empty;
    final currency = ref.watch(settingsProvider).currencySymbol;
    final color = Color(habit.color);

    return SheetScaffold(
      title: habit.name,
      actions: [
        CircleIconButton(
          icon: AppIcons.edit,
          size: 40,
          onPressed: () {
            Navigator.pop(context);
            HabitEditorSheet.show(context, habit: habit);
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: AppIcons.streak,
                  color: AppColors.warningLight,
                  label: 'Current streak',
                  value: '${stats.currentStreak}',
                  sublabel: 'Best ${stats.bestStreak}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: AppIcons.percent,
                  color: color,
                  label: 'Completion',
                  value: Fmt.percent(stats.completionRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: AppIcons.calendarWeek,
                  color: color,
                  label: 'This week',
                  value: _HabitCard._trim(stats.weekTotal),
                  sublabel: habit.unit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: AppIcons.calendarMonth,
                  color: color,
                  label: 'This month',
                  value: _HabitCard._trim(stats.monthTotal),
                  sublabel: habit.unit,
                ),
              ),
            ],
          ),
          if (habit.costPerUnit != null) ...[
            const SizedBox(height: 12),
            StatTile(
              icon: AppIcons.savings,
              color: AppColors.expenseAccent,
              label: 'Cost this month',
              value: Fmt.money(stats.costThisMonth(habit), currency),
              sublabel:
                  '${Fmt.money(habit.costPerUnit!, currency)} per ${habit.unit ?? 'unit'}',
            ),
          ],
          const SizedBox(height: 20),
          const SectionHeader('Last 17 weeks'),
          SizedBox(
            height: 7 * 17.0,
            child: ContributionHeatmap(
              color: color,
              intensityFor: (day) => stats.intensityOn(day, habit),
            ),
          ),
          const SizedBox(height: 20),
          BrandButton(
            label: 'Delete habit',
            kind: BrandButtonKind.outline,
            icon: AppIcons.delete,
            expand: false,
            onPressed: () async {
              await ref.read(habitRepositoryProvider).deleteHabit(habit.id);
              await ref
                  .read(notificationServiceProvider)
                  .cancelHabitNudge(habit.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// Create/edit form covering goal type, frequency, unit, cost and reminders.
class HabitEditorSheet extends ConsumerStatefulWidget {
  final Habit? habit;
  const HabitEditorSheet({super.key, this.habit});

  static Future<void> show(BuildContext context, {Habit? habit}) {
    return brandSheet(
      context: context,
      builder: (_) => HabitEditorSheet(habit: habit),
    );
  }

  @override
  ConsumerState<HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends ConsumerState<HabitEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _unit;
  late final TextEditingController _target;
  late final TextEditingController _cost;
  late final TextEditingController _caffeine;

  String _icon = 'coffee';
  int _color = 0xFF3BB273;
  int _goalType = 0;
  int _frequencyType = 0;
  int _weekdayMask = 127;
  int _timesPerWeek = 7;
  int? _reminderMinutes;

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _name = TextEditingController(text: h?.name ?? '');
    _unit = TextEditingController(text: h?.unit ?? '');
    _target = TextEditingController(
      text: h == null ? '1' : _HabitCard._trim(h.targetAmount),
    );
    _cost = TextEditingController(
      text: h?.costPerUnit == null ? '' : '${h!.costPerUnit}',
    );
    _caffeine = TextEditingController(
      text: h?.caffeineMgPerUnit == null ? '' : '${h!.caffeineMgPerUnit}',
    );
    if (h != null) {
      _icon = h.icon;
      _color = h.color;
      _goalType = h.goalType;
      _frequencyType = h.frequencyType;
      _weekdayMask = h.weekdayMask;
      _timesPerWeek = h.timesPerWeek;
      _reminderMinutes = h.reminderMinutes;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _target.dispose();
    _cost.dispose();
    _caffeine.dispose();
    super.dispose();
  }

  void _applyPreset(
    ({
      String name,
      String icon,
      int color,
      String unit,
      int goalType,
      double target,
      double? caffeine,
    })
    p,
  ) {
    setState(() {
      _name.text = p.name;
      _icon = p.icon;
      _color = p.color;
      _unit.text = p.unit;
      _goalType = p.goalType;
      _target.text = _HabitCard._trim(p.target);
      _caffeine.text = p.caffeine == null ? '' : '${p.caffeine}';
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;

    final companion = HabitsCompanion(
      name: drift.Value(name),
      icon: drift.Value(_icon),
      color: drift.Value(_color),
      unit: drift.Value(_unit.text.trim().isEmpty ? null : _unit.text.trim()),
      goalType: drift.Value(_goalType),
      targetAmount: drift.Value(double.tryParse(_target.text.trim()) ?? 1.0),
      frequencyType: drift.Value(_frequencyType),
      weekdayMask: drift.Value(_weekdayMask),
      timesPerWeek: drift.Value(_timesPerWeek),
      costPerUnit: drift.Value(double.tryParse(_cost.text.trim())),
      caffeineMgPerUnit: drift.Value(double.tryParse(_caffeine.text.trim())),
      reminderMinutes: drift.Value(_reminderMinutes),
    );

    final repo = ref.read(habitRepositoryProvider);
    final notifier = ref.read(notificationServiceProvider);

    final id = _isEditing
        ? widget.habit!.id
        : await repo.createHabit(companion);
    if (_isEditing) await repo.updateHabit(id, companion);

    if (_reminderMinutes != null) {
      await notifier.scheduleHabitNudge(
        habitId: id,
        habitName: name,
        minutesFromMidnight: _reminderMinutes!,
      );
    } else {
      await notifier.cancelHabitNudge(id);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outline;
    final currency = ref.watch(settingsProvider).currencySymbol;

    return SheetScaffold(
      title: _isEditing ? 'Edit habit' : 'New habit',
      actions: [
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
          if (!_isEditing) ...[
            Text(
              'Start from a preset',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: HabitRepository.presets
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Pill(
                          label: p.name,
                          icon: AppIcons.habit(p.icon),
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () => _applyPreset(p),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
          BrandField(
            controller: _name,
            label: 'Habit name',
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          Text('Goal', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 8),
          BrandSegmented<int>(
            options: const {0: 'Build', 1: 'Reduce'},
            icons: const {0: AppIcons.trendUp, 1: AppIcons.trendDown},
            selected: _goalType,
            onSelected: (v) => setState(() => _goalType = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BrandField(
                  controller: _target,
                  label: _goalType == 0 ? 'Daily goal' : 'Daily limit',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrandField(
                  controller: _unit,
                  label: 'Unit',
                  hint: 'cups',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Frequency', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 8),
          BrandSegmented<int>(
            options: const {0: 'Daily', 1: 'Weekdays', 2: 'X / week'},
            selected: _frequencyType,
            onSelected: (v) => setState(() => _frequencyType = v),
          ),
          if (_frequencyType == 1) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: List.generate(7, (i) {
                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final on = (_weekdayMask & (1 << i)) != 0;
                return Pill(
                  label: labels[i],
                  selected: on,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    final v = !(on);
                    setState(() {
                      _weekdayMask = v
                          ? _weekdayMask | (1 << i)
                          : _weekdayMask & ~(1 << i);
                    });
                  },
                );
              }),
            ),
          ],
          if (_frequencyType == 2) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '$_timesPerWeek times per week',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: BrandSlider(
                    value: _timesPerWeek.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    onChanged: (v) => setState(() => _timesPerWeek = v.round()),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text('Appearance', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 10),
          ColorPickerRow(
            selected: _color,
            onChanged: (c) => setState(() => _color = c),
          ),
          const SizedBox(height: 12),
          IconPickerRow(
            options: AppIcons.habitIcons,
            selected: _icon,
            color: Color(_color),
            onChanged: (i) => setState(() => _icon = i),
          ),
          const SizedBox(height: 20),
          Text(
            'Optional tracking',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: BrandField(
                  controller: _cost,
                  label: 'Cost per unit',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefix: Text(currency),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrandField(
                  controller: _caffeine,
                  label: 'Caffeine',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffix: const Text('mg'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BrandTile(
            leading: const AppIcon(AppIcons.notifications),
            title: const Text('Daily reminder'),
            subtitle: Text(
              _reminderMinutes == null
                  ? 'Off'
                  : Fmt.minutesOfDay(_reminderMinutes!),
            ),
            trailing: _reminderMinutes == null
                ? const AppIcon(AppIcons.chevronRight)
                : CircleIconButton(
                    icon: AppIcons.close,
                    size: 40,
                    onPressed: () => setState(() => _reminderMinutes = null),
                  ),
            onTap: () async {
              final minutes = await brandTimePicker(
                context,
                initialMinutes: _reminderMinutes ?? 9 * 60,
                title: 'Daily reminder',
              );
              if (minutes != null) {
                setState(() => _reminderMinutes = minutes);
              }
            },
          ),
        ],
      ),
    );
  }
}
