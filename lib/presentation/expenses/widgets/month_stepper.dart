import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../providers/expenses_provider.dart';

/// Steps [reportMonthProvider] a month at a time. The reports and budgets
/// tabs share the one selection, so moving back a month in either shows the
/// same month's caps against the same month's spending.
class MonthStepper extends ConsumerWidget {
  const MonthStepper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(reportMonthProvider);
    void go(int delta) => ref.read(reportMonthProvider.notifier).state =
        DateTime(month.year, month.month + delta);

    return Row(
      children: [
        CircleIconButton(
          icon: AppIcons.chevronLeft,
          tooltip: 'Previous month',
          size: 40,
          onPressed: () => go(-1),
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
          tooltip: 'Next month',
          size: 40,
          onPressed: () => go(1),
        ),
      ],
    );
  }
}
