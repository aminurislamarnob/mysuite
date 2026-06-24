import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/habit_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../models/habit.dart';
import '../../state/habits_controller.dart';

/// Create or edit a habit. Presets pre-fill common habits for fast setup.
class AddHabitSheet {
  static Future<void> show(BuildContext context, {Habit? existing}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddHabitBody(existing: existing),
    );
  }
}

class _Preset {
  const _Preset(this.name, this.unit, this.target, this.goal, this.icon, this.color);
  final String name;
  final String unit;
  final int target;
  final HabitGoal goal;
  final int icon;
  final int color;
}

const _presets = [
  _Preset('Water', 'glasses', 8, HabitGoal.build, 1, 0xFF06B6D4),
  _Preset('Coffee', 'cups', 2, HabitGoal.reduce, 0, 0xFFF59E0B),
  _Preset('Exercise', 'min', 30, HabitGoal.build, 2, 0xFF10B981),
  _Preset('Reading', 'pages', 20, HabitGoal.build, 3, 0xFF8B5CF6),
  _Preset('Meditation', 'min', 10, HabitGoal.build, 4, 0xFF5B6CFF),
  _Preset('Smoking', 'cigarettes', 0, HabitGoal.reduce, 5, 0xFFEF4444),
];

class _AddHabitBody extends StatefulWidget {
  const _AddHabitBody({this.existing});
  final Habit? existing;

  @override
  State<_AddHabitBody> createState() => _AddHabitBodyState();
}

class _AddHabitBodyState extends State<_AddHabitBody> {
  late final TextEditingController _name;
  late final TextEditingController _unit;
  late int _target;
  late HabitGoal _goal;
  late int _icon;
  late int _color;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _unit = TextEditingController(text: e?.unit ?? 'times');
    _target = e?.target ?? 1;
    _goal = e?.goal ?? HabitGoal.build;
    _icon = e?.iconCode ?? 0;
    _color = e?.color ?? kHabitColors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    super.dispose();
  }

  void _applyPreset(_Preset p) {
    setState(() {
      _name.text = p.name;
      _unit.text = p.unit;
      _target = p.target;
      _goal = p.goal;
      _icon = p.icon;
      _color = p.color;
    });
  }

  void _save() {
    final controller = context.read<HabitsController>();
    if (_name.text.trim().isEmpty) return;
    final habit = widget.existing;
    if (habit != null) {
      habit
        ..name = _name.text.trim()
        ..unit = _unit.text.trim()
        ..target = _target
        ..goal = _goal
        ..iconCode = _icon
        ..color = _color;
      controller.upsert(habit);
    } else {
      controller.upsert(Habit(
        id: controller.newId(),
        name: _name.text.trim(),
        unit: _unit.text.trim(),
        target: _target,
        goal: _goal,
        color: _color,
        iconCode: _icon,
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(isEdit ? 'Edit habit' : 'New habit',
                    style: context.text.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (isEdit)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2),
                    onPressed: () {
                      context
                          .read<HabitsController>()
                          .delete(widget.existing!.id);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isEdit) ...[
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final p in _presets) ...[
                      ActionChip(
                        avatar: Icon(habitIcon(p.icon),
                            size: 16, color: Color(p.color)),
                        label: Text(p.name),
                        onPressed: () => _applyPreset(p),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _unit,
                    decoration:
                        const InputDecoration(labelText: 'Unit (cups, ml…)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Stepper(
                    value: _target,
                    onChanged: (v) => setState(() => _target = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<HabitGoal>(
              segments: const [
                ButtonSegment(
                    value: HabitGoal.build,
                    label: Text('Build'),
                    icon: Icon(LucideIcons.trendingUp)),
                ButtonSegment(
                    value: HabitGoal.reduce,
                    label: Text('Reduce'),
                    icon: Icon(LucideIcons.trendingDown)),
              ],
              selected: {_goal},
              onSelectionChanged: (s) => setState(() => _goal = s.first),
            ),
            const SizedBox(height: 16),
            Text('Icon',
                style: context.text.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < kHabitIcons.length; i++)
                  _PickDot(
                    selected: _icon == i,
                    color: Color(_color),
                    onTap: () => setState(() => _icon = i),
                    child: Icon(kHabitIcons[i],
                        size: 20,
                        color: _icon == i ? Colors.white : context.muted),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Color',
                style: context.text.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                for (final c in kHabitColors)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == c
                              ? context.colors.onSurface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(isEdit ? 'Save changes' : 'Create habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.muted.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(LucideIcons.minus, size: 18),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Text('$value',
              style: context.text.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(LucideIcons.plus, size: 18),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _PickDot extends StatelessWidget {
  const _PickDot({
    required this.selected,
    required this.color,
    required this.onTap,
    required this.child,
  });
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected ? color : context.muted.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
