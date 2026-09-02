import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
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
    final linkedTask = tasks.where((t) => t.id == state.taskId).firstOrNull;

    // Watch for the moment a session finishes so we can ask for a rating.
    ref.listen(focusTimerProvider, (prev, next) {
      if (prev?.phase != TimerPhase.finished &&
          next.phase == TimerPhase.finished &&
          next.elapsedSeconds > 30) {
        _askForReflection();
      }
    });

    final accent = state.isBreak
        ? AppColors.successLight
        : AppColors.focusAccent;

    return BrandScaffold(
      header: BrandTopBar(
        title: state.isBreak
            ? 'Break'
            : state.mode.countsUp
            ? 'Flow'
            : 'Focus',
        leadingIcon: AppIcons.back,
        trailingIcon: AppIcons.barChart,
        trailingTooltip: 'Stats',
        onTrailing: () => brandSheet(
          context: context,
          builder: (_) => const _FocusStatsSheet(),
        ),
      ),
      child: ListView(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.5,
                            ),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
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
                icon: AppIcons.today,
                value: Fmt.duration(stats.today),
                caption: 'Today',
                color: accent,
              ),
              MetricColumn(
                icon: AppIcons.checkCircle,
                value: '${stats.sessionsToday}',
                caption: 'Sessions',
                color: accent,
              ),
              MetricColumn(
                icon: AppIcons.streak,
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
            child: BrandTile(
              leading: AppIcon(AppIcons.link, color: accent),
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
                  ? AppIcon(AppIcons.chevronRight, color: context.muted)
                  : CircleIconButton(
                      icon: AppIcons.close,
                      size: 40,
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
            child: BrandButton(
              label: 'Change goal',
              kind: BrandButtonKind.ghost,
              expand: false,
              onPressed: _editGoal,
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
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Pill(
                      label: m.label,
                      selected: state.mode == m,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => notifier.setMode(m),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (state.mode == FocusMode.custom)
          Row(
            children: [
              Text(
                '${state.customMinutes} min',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: BrandSlider(
                  value: state.customMinutes.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
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
    FocusState state,
    FocusTimerNotifier notifier,
    Color accent,
  ) {
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
          icon: AppIcons.replay,
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
          icon: AppIcons.stop,
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
      brandToast(context, 'No open tasks to link.');
      return;
    }
    final picked = await brandSheet<int>(
      context: context,
      builder: (_) => SheetScaffold(
        title: 'Link a task',
        child: Column(
          children: tasks
              .map(
                (t) => BrandTile(
                  leading: const AppIcon(AppIcons.checkCircle),
                  title: Text(t.title),
                  subtitle: t.estimateMinutes == null
                      ? null
                      : Text(
                          'Estimate ${Fmt.durationFromMinutes(t.estimateMinutes!)}',
                        ),
                  onTap: () => Navigator.pop(context, t.id),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked != null) {
      ref.read(focusTimerProvider.notifier).linkTask(picked);
    }
  }

  Future<void> _editGoal() async {
    final controller = TextEditingController(
      text: '${ref.read(focusGoalProvider)}',
    );
    final result = await brandDialog<String>(
      context,
      title: 'Daily focus goal',
      builder: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            suffix: const Text('minutes'),
          ),
          const SizedBox(height: 20),
          BrandButton(
            label: 'Save',
            onPressed: () => Navigator.pop(dialogContext, controller.text),
          ),
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

    final saved = await brandSheet<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => SheetScaffold(
          title: 'Session complete',
          actions: [
            BrandButton(
              label: 'Save',
              kind: BrandButtonKind.ghost,
              expand: false,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You focused for ${Fmt.duration(Duration(seconds: last.actualSeconds))}.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              BrandField(
                controller: controller,
                label: 'What did you work on?',
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              const Text('Focus quality'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final value = i + 1;
                  return CircleIconButton(
                    icon: value <= rating ? AppIcons.star : AppIcons.star,
                    size: 40,
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
      await ref
          .read(focusTimerProvider.notifier)
          .annotateLast(
            last.id,
            note: controller.text.trim().isEmpty
                ? null
                : controller.text.trim(),
            rating: rating,
          );
    }
  }
}

/// A circular transport button. [soft] renders it as a tinted secondary
/// control rather than a solid primary one.
class _RoundAction extends StatelessWidget {
  final String? label;
  final HugeIconData? icon;
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
    final button = BrandTappable(
      onPressed: onPressed,
      semanticsLabel: tooltip ?? label,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: soft
              ? AppColors.wash(color, brightness: Theme.of(context).brightness)
              : color,
          shape: const CircleBorder(),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: icon != null
                ? AppIcon(
                    icon!,
                    color: soft ? color : Colors.white,
                    size: size * 0.42,
                  )
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
    return BrandTooltip(message: tooltip ?? label ?? '', child: button);
  }
}

class _AmbientRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(ambientPlayerProvider);
    final notifier = ref.read(ambientPlayerProvider.notifier);

    const labels = <String, (String, HugeIconData)>{
      'rain': ('Rain', AppIcons.water),
      'cafe': ('Café', AppIcons.habits),
      'forest': ('Forest', AppIcons.forest),
      'white': ('White', AppIcons.whiteNoise),
      'brown': ('Brown', AppIcons.brownNoise),
      'ocean': ('Ocean', AppIcons.ocean),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.entries.map((e) {
        final (label, icon) = e.value;
        final selected = active == e.key;
        return Pill(
          label: label,
          icon: icon,
          selected: selected,
          color: Theme.of(context).colorScheme.primary,
          onTap: () => ((_) async {
            final ok = await notifier.toggle(e.key);
            if (!ok && context.mounted) {
              brandToast(context, '$label sound is not bundled yet.');
            }
          })(!(selected)),
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
                  icon: AppIcons.today,
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
                  icon: AppIcons.calendarWeek,
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
                  icon: AppIcons.streak,
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
                  icon: AppIcons.session,
                  color: AppColors.focusAccent,
                  label: 'All time',
                  value: Fmt.duration(stats.total),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  tintIndex: 4,
                  icon: AppIcons.lightMode,
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
            ...sessions
                .take(12)
                .map(
                  (s) => BrandTile(
                    leading: AppIcon(
                      s.isCompleted ? AppIcons.checkCircle : AppIcons.session,
                      color: s.isCompleted ? AppColors.successLight : muted,
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
                          const AppIcon(
                            AppIcons.star,
                            size: 12,
                            color: AppColors.warningLight,
                          ),
                          Text(
                            '${s.rating}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          Fmt.duration(Duration(seconds: s.actualSeconds)),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
