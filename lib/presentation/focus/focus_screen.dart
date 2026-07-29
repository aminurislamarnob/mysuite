import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../tasks/providers/tasks_provider.dart';
import 'providers/focus_provider.dart';

class FocusScreen extends ConsumerStatefulWidget {
  /// Optional task to attach the session to, passed by the task tile's
  /// "Focus" swipe action.
  final int? taskId;
  const FocusScreen({super.key, this.taskId});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      // Link after the first frame so the provider is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(focusTimerProvider.notifier).linkTask(widget.taskId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);
    final stats = ref.watch(focusStatsProvider).valueOrNull ?? FocusStats.empty;
    final goal = ref.watch(focusGoalProvider);
    final tasks = ref.watch(openTasksProvider).valueOrNull ?? const [];
    final linkedTask =
        tasks.where((t) => t.id == state.taskId).firstOrNull;

    // Watch for the moment a session finishes so we can ask for a rating.
    ref.listen(focusTimerProvider, (prev, next) {
      if (prev?.phase != TimerPhase.finished &&
          next.phase == TimerPhase.finished &&
          next.elapsedSeconds > 30) {
        _askForReflection();
      }
    });

    final accent =
        state.isBreak ? AppColors.successLight : AppColors.focusAccent;

    return Scaffold(
      appBar: BrandTopBar(
        title: state.isBreak
            ? 'Break'
            : state.mode.countsUp
                ? 'Flow'
                : 'Focus',
        leadingIcon: Icons.arrow_back_rounded,
        trailingIcon: Icons.bar_chart_rounded,
        trailingTooltip: 'Stats',
        onTrailing: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _FocusStatsSheet(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
        children: [
          if (state.phase == TimerPhase.idle)
            _buildModeSelector(state, notifier),
          const SizedBox(height: 20),

          // The hero ring: elapsed progress around a big tabular clock, the
          // same shape the reference uses for distance.
          Center(
            child: ProgressRing(
              // A count-up mode has no target to fill, so the ring stays as a
              // track and the clock alone carries the state.
              value: state.mode.countsUp ? 0 : state.progress,
              size: 250,
              thickness: 20,
              color: accent,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    child: Text(
                      state.display,
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.isBreak ? 'Break' : state.mode.label,
                    style: TextStyle(fontSize: 14, color: context.muted),
                  ),
                  if (state.completedIntervals > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          math.min(state.completedIntervals, 8),
                          (_) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.5),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                  color: accent, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 34),

          // The metric trio under the ring.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricColumn(
                icon: Icons.today_rounded,
                value: Fmt.duration(stats.today),
                caption: 'Today',
                color: accent,
              ),
              MetricColumn(
                icon: Icons.check_circle_rounded,
                value: '${stats.sessionsToday}',
                caption: 'Sessions',
                color: accent,
              ),
              MetricColumn(
                icon: Icons.local_fire_department_rounded,
                value: '${stats.streakDays}',
                caption: 'Day streak',
                color: AppColors.warningLight,
              ),
            ],
          ),
          const SizedBox(height: 30),

          _buildControls(state, notifier, accent),
          const SizedBox(height: 30),

          TintCard(
            accent: accent,
            onTap: _pickTask,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.link_rounded, color: accent),
              title: Text(linkedTask?.title ?? 'Not linked to a task'),
              subtitle: Text(
                linkedTask == null
                    ? 'Link a task to log this time against it'
                    : linkedTask.estimateMinutes == null
                        ? 'Time will be logged to this task'
                        : 'Estimate ${Fmt.durationFromMinutes(linkedTask.estimateMinutes!)} · '
                            'logged ${Fmt.durationFromMinutes(linkedTask.loggedMinutes)}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: linkedTask == null
                  ? Icon(Icons.chevron_right_rounded, color: context.muted)
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => notifier.linkTask(null),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          LabeledProgress(
            label: 'Daily focus goal',
            trailing:
                '${Fmt.duration(stats.today)} / ${Fmt.durationFromMinutes(goal)}',
            value: goal == 0 ? 0 : stats.today.inMinutes / goal,
            color: AppColors.focusAccent,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _editGoal,
              child: const Text('Change goal'),
            ),
          ),

          const SizedBox(height: 16),
          const SectionHeader('Ambient sound'),
          _AmbientRow(),
        ],
      ),
    );
  }

  Widget _buildModeSelector(FocusState state, FocusTimerNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: FocusMode.values
                .map((m) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(m.label),
                        selected: state.mode == m,
                        onSelected: (_) => notifier.setMode(m),
                      ),
                    ))
                .toList(),
          ),
        ),
        if (state.mode == FocusMode.custom)
          Row(
            children: [
              Text('${state.customMinutes} min',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Expanded(
                child: Slider(
                  value: state.customMinutes.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  label: '${state.customMinutes} min',
                  onChanged: (v) => notifier.setCustomMinutes(v.round()),
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// The transport row from the reference: a big filled circle in the middle,
  /// flanked by two soft-tinted secondary circles.
  Widget _buildControls(
      FocusState state, FocusTimerNotifier notifier, Color accent) {
    final idle =
        state.phase == TimerPhase.idle || state.phase == TimerPhase.finished;

    if (idle) {
      return Center(
        child: _RoundAction(
          label: state.phase == TimerPhase.finished ? 'Again' : 'Start',
          color: accent,
          size: 84,
          onPressed: () {
            if (state.phase == TimerPhase.finished) notifier.reset();
            notifier.start();
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundAction(
          icon: Icons.replay_rounded,
          tooltip: 'Reset',
          color: accent,
          size: 52,
          soft: true,
          onPressed: notifier.reset,
        ),
        const SizedBox(width: 28),
        _RoundAction(
          label: state.running ? 'Pause' : 'Resume',
          color: state.running ? AppColors.warningLight : accent,
          size: 84,
          onPressed: state.running ? notifier.pause : notifier.start,
        ),
        const SizedBox(width: 28),
        _RoundAction(
          icon: Icons.stop_rounded,
          tooltip: 'Finish',
          color: accent,
          size: 52,
          soft: true,
          onPressed: notifier.stop,
        ),
      ],
    );
  }

  Future<void> _pickTask() async {
    final tasks = ref.read(openTasksProvider).valueOrNull ?? const [];
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No open tasks to link.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SheetScaffold(
        title: 'Link a task',
        child: Column(
          children: tasks
              .map((t) => ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(t.title),
                    subtitle: t.estimateMinutes == null
                        ? null
                        : Text(
                            'Estimate ${Fmt.durationFromMinutes(t.estimateMinutes!)}'),
                    onTap: () => Navigator.pop(context, t.id),
                  ))
              .toList(),
        ),
      ),
    );
    if (picked != null) {
      ref.read(focusTimerProvider.notifier).linkTask(picked);
    }
  }

  Future<void> _editGoal() async {
    final controller =
        TextEditingController(text: '${ref.read(focusGoalProvider)}');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Daily focus goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'minutes'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    final minutes = int.tryParse(result?.trim() ?? '');
    if (minutes != null && minutes > 0) {
      ref.read(focusGoalProvider.notifier).state = minutes;
    }
  }

  /// After a session, capture what was worked on and how focused it felt.
  Future<void> _askForReflection() async {
    final sessions = ref.read(recentSessionsProvider).valueOrNull ?? const [];
    final last = sessions.firstOrNull;
    if (last == null || !mounted) return;

    final controller = TextEditingController();
    var rating = 3;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => SheetScaffold(
          title: 'Session complete',
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save')),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You focused for ${Fmt.duration(Duration(seconds: last.actualSeconds))}.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'What did you work on?'),
              ),
              const SizedBox(height: 20),
              const Text('Focus quality'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final value = i + 1;
                  return IconButton(
                    icon: Icon(
                      value <= rating ? Icons.star : Icons.star_outline,
                      color: AppColors.warningLight,
                    ),
                    onPressed: () => setState(() => rating = value),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true) {
      await ref.read(focusTimerProvider.notifier).annotateLast(
            last.id,
            note: controller.text.trim().isEmpty ? null : controller.text.trim(),
            rating: rating,
          );
    }
  }
}

/// A circular transport button. [soft] renders it as a tinted secondary
/// control rather than a solid primary one.
class _RoundAction extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final String? tooltip;
  final Color color;
  final double size;
  final bool soft;
  final VoidCallback onPressed;

  const _RoundAction({
    this.label,
    this.icon,
    this.tooltip,
    required this.color,
    required this.size,
    required this.onPressed,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: soft
          ? AppColors.wash(color, brightness: Theme.of(context).brightness)
          : color,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: icon != null
                ? Icon(icon, color: soft ? color : Colors.white, size: size * 0.42)
                : Text(
                    label!,
                    style: TextStyle(
                      color: soft ? color : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
    return Tooltip(message: tooltip ?? label ?? '', child: button);
  }
}

class _AmbientRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(ambientPlayerProvider);
    final notifier = ref.read(ambientPlayerProvider.notifier);

    const labels = <String, (String, IconData)>{
      'rain': ('Rain', Icons.water_drop_outlined),
      'cafe': ('Café', Icons.local_cafe_outlined),
      'forest': ('Forest', Icons.forest_outlined),
      'white': ('White', Icons.graphic_eq),
      'brown': ('Brown', Icons.waves),
      'ocean': ('Ocean', Icons.beach_access_outlined),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.entries.map((e) {
        final (label, icon) = e.value;
        final selected = active == e.key;
        return FilterChip(
          avatar: Icon(icon, size: 16),
          label: Text(label),
          selected: selected,
          onSelected: (_) async {
            final ok = await notifier.toggle(e.key);
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label sound is not bundled yet.')),
              );
            }
          },
        );
      }).toList(),
    );
  }
}

class _FocusStatsSheet extends ConsumerWidget {
  const _FocusStatsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(focusStatsProvider).valueOrNull ?? FocusStats.empty;
    final sessions = ref.watch(recentSessionsProvider).valueOrNull ?? const [];
    final muted = Theme.of(context).colorScheme.outline;

    return SheetScaffold(
      title: 'Focus stats',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  tintIndex: 0,
                  icon: Icons.today_outlined,
                  color: AppColors.focusAccent,
                  label: 'Today',
                  value: Fmt.duration(stats.today),
                  sublabel: '${stats.sessionsToday} sessions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  tintIndex: 1,
                  icon: Icons.calendar_view_week,
                  color: AppColors.focusAccent,
                  label: 'This week',
                  value: Fmt.duration(stats.week),
                  sublabel: '${stats.sessionsWeek} sessions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  tintIndex: 2,
                  icon: Icons.local_fire_department,
                  color: AppColors.warningLight,
                  label: 'Streak',
                  value: '${stats.streakDays}',
                  sublabel: 'days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  tintIndex: 3,
                  icon: Icons.timelapse,
                  color: AppColors.focusAccent,
                  label: 'All time',
                  value: Fmt.duration(stats.total),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  tintIndex: 4,
                  icon: Icons.wb_sunny_outlined,
                  color: AppColors.warningLight,
                  label: 'Best hour',
                  value: stats.bestHour == null
                      ? '—'
                      : Fmt.minutesOfDay(stats.bestHour! * 60),
                  sublabel: 'when you focus most',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader('Focus days'),
          SizedBox(
            height: 7 * 17.0,
            child: ContributionHeatmap(
              color: AppColors.focusAccent,
              intensityFor: (day) {
                final d = stats.byDay[Fmt.dateOnly(day)];
                if (d == null || d == Duration.zero) return 0;
                // Scale against a 2-hour day so a solid day reads as full.
                return (d.inMinutes / 120).clamp(0.15, 1.0);
              },
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Recent sessions'),
          if (sessions.isEmpty)
            Text('No sessions yet.', style: TextStyle(color: muted))
          else
            ...sessions.take(12).map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    s.isCompleted ? Icons.check_circle : Icons.timelapse,
                    color: s.isCompleted
                        ? AppColors.successLight
                        : muted,
                    size: 20,
                  ),
                  title: Text(
                    s.note?.isNotEmpty == true ? s.note! : 'Focus session',
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    '${Fmt.relativeDay(s.startTime)} · ${Fmt.time(s.startTime)}',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (s.rating != null) ...[
                        const Icon(Icons.star,
                            size: 12, color: AppColors.warningLight),
                        Text('${s.rating}',
                            style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        Fmt.duration(Duration(seconds: s.actualSeconds)),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
