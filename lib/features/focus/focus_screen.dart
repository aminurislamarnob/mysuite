import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/task.dart';
import '../../state/focus_controller.dart';
import '../../state/tasks_controller.dart';
import '../../widgets/common.dart';

class FocusMode {
  const FocusMode(this.label, this.workMin, this.breakMin);
  final String label;
  final int workMin;
  final int breakMin;
}

const _modes = [
  FocusMode('Classic', 25, 5),
  FocusMode('52 / 17', 52, 17),
  FocusMode('Deep 90', 90, 20),
  FocusMode('Flow', 50, 10),
];

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, this.task});
  final Task? task;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? _timer;
  FocusMode _mode = _modes.first;
  bool _onBreak = false;
  bool _running = false;
  late int _remaining; // seconds
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _remaining = _mode.workMin * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _total => (_onBreak ? _mode.breakMin : _mode.workMin) * 60;

  void _selectMode(FocusMode m) {
    if (_running) return;
    setState(() {
      _mode = m;
      _onBreak = false;
      _remaining = m.workMin * 60;
    });
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      _startedAt ??= DateTime.now();
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining <= 1) {
          _onComplete();
        } else {
          setState(() => _remaining--);
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _onBreak = false;
      _remaining = _mode.workMin * 60;
      _startedAt = null;
    });
  }

  void _onComplete() {
    _timer?.cancel();
    final wasWork = !_onBreak;
    if (wasWork) {
      final seconds = _mode.workMin * 60;
      context.read<FocusController>().record(
            startedAt: _startedAt ?? DateTime.now(),
            seconds: seconds,
            taskId: widget.task?.id,
            taskTitle: widget.task?.title,
          );
      if (widget.task != null) {
        context.read<TasksController>().addFocusTime(widget.task!.id, seconds);
      }
    }
    setState(() {
      _onBreak = !_onBreak;
      _remaining = (_onBreak ? _mode.breakMin : _mode.workMin) * 60;
      _running = false;
      _startedAt = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(wasWork
            ? 'Focus session logged! Time for a break.'
            : 'Break over — ready for another round?'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final focus = context.watch<FocusController>();
    final progress = _total == 0 ? 0.0 : 1 - (_remaining / _total);
    final accent = _onBreak ? AppColors.successLight : AppColors.focus;

    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final m in _modes)
                  ChoiceChip(
                    label: Text(m.label),
                    selected: _mode == m,
                    onSelected: _running ? null : (_) => _selectMode(m),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: progress.clamp(0, 1).toDouble(),
                      strokeWidth: 12,
                      backgroundColor: accent.withValues(alpha: 0.14),
                      valueColor: AlwaysStoppedAnimation(accent),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_onBreak ? 'BREAK' : 'FOCUS',
                          style: context.text.labelMedium?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text(
                        Fmt.clock(Duration(seconds: _remaining)),
                        style: context.text.displayMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.colors.onSurface),
                      ),
                      if (widget.task != null) ...[
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 180,
                          child: Text(widget.task!.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.muted)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(
                  onPressed: _reset,
                  iconSize: 28,
                  icon: const Icon(LucideIcons.rotateCcw),
                ),
                const SizedBox(width: 20),
                FilledButton.icon(
                  onPressed: _toggle,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                  ),
                  icon: Icon(_running ? LucideIcons.pause : LucideIcons.play),
                  label: Text(_running ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 20),
                IconButton.outlined(
                  onPressed: _running ? null : _onCompleteEarly,
                  iconSize: 28,
                  icon: const Icon(LucideIcons.skipForward),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Sessions today',
                    value: '${focus.sessionsToday()}',
                    icon: LucideIcons.target,
                    color: AppColors.focus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Focused today',
                    value: Fmt.duration(Duration(seconds: focus.secondsToday())),
                    icon: LucideIcons.timer,
                    color: AppColors.focus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'This week',
                    value: Fmt.duration(Duration(seconds: focus.secondsThisWeek())),
                    icon: LucideIcons.calendar,
                    color: AppColors.focus,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Daily goal',
                          style: context.text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(
                          '${(focus.todayGoalProgress() * 100).round()}% of ${focus.dailyGoalMinutes ~/ 60}h',
                          style: context.text.bodySmall
                              ?.copyWith(color: context.muted)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ProgressBar(
                      value: focus.todayGoalProgress(), color: AppColors.focus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCompleteEarly() => _onComplete();
}
