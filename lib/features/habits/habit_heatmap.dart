import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/habit.dart';

/// GitHub-style contribution heatmap for a habit's recent history.
class HabitHeatmap extends StatelessWidget {
  const HabitHeatmap({super.key, required this.habit, this.weeks = 16});

  final Habit habit;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final base = Color(habit.color);
    final today = Day.today();
    // Align the grid so the last column ends on today; rows = weekdays.
    final start = today.subtract(Duration(days: weeks * 7 - 1));

    return LayoutBuilder(
      builder: (context, constraints) {
        const rows = 7;
        final cell = ((constraints.maxWidth - (weeks - 1) * 3) / weeks)
            .clamp(8.0, 16.0);
        return SizedBox(
          height: rows * (cell + 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var w = 0; w < weeks; w++)
                Padding(
                  padding: EdgeInsets.only(right: w == weeks - 1 ? 0 : 3),
                  child: Column(
                    children: [
                      for (var d = 0; d < rows; d++)
                        _cellFor(context, start, w, d, cell, base, today),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _cellFor(BuildContext context, DateTime start, int w, int d,
      double size, Color base, DateTime today) {
    final date = start.add(Duration(days: w * 7 + d));
    final future = date.isAfter(today);
    final amount = habit.amountOn(date);
    final intensity = habit.target <= 0
        ? (amount > 0 ? 1.0 : 0.0)
        : (amount / habit.target).clamp(0.0, 1.0);

    Color color;
    if (future) {
      color = Colors.transparent;
    } else if (amount == 0) {
      color = context.muted.withValues(alpha: 0.12);
    } else {
      color = base.withValues(alpha: 0.25 + intensity * 0.6);
    }

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
