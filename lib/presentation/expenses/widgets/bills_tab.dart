import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';
import '../utils/expense_reminders.dart';
import 'expense_entry_sheet.dart';

class BillsTab extends ConsumerWidget {
  const BillsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final bills = ref.watch(recurringProvider);
    final subsTotal = ref.watch(subscriptionTotalProvider).valueOrNull ?? 0;
    final repo = ref.read(expenseRepositoryProvider);
    final reminders = ref.read(expenseRemindersProvider);

    // The screen's own FAB owns the bottom corner, so the way to add a bill
    // sits in the list where it can be seen.
    return bills.when(
      loading: () => const Center(child: BrandSpinner()),
      error: (e, _) => Text('$e'),
      data: (rows) => rows.isEmpty
          ? EmptyState(
              icon: AppIcons.calendarRepeat,
              title: 'No bills or subscriptions',
              message: 'Track rent, internet, Netflix — anything recurring.',
              actionLabel: 'Add a bill',
              onAction: () => ExpenseEntrySheet.show(
                context,
                kind: ExpenseEntrySheet.billMode,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                if (subsTotal > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StatTile(
                      icon: AppIcons.subscription,
                      color: context.brand.expense,
                      label: 'Subscriptions',
                      value: '${Fmt.money(subsTotal, currency)}/month',
                      sublabel:
                          '${Fmt.money(subsTotal * 12, currency)} per year',
                    ),
                  ),
                ...rows.map((b) {
                  final dueInDays = Fmt.dateOnly(
                    b.nextDueDate,
                  ).difference(Fmt.dateOnly(DateTime.now())).inDays;
                  final overdue = dueInDays < 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TintCard(
                      padding: EdgeInsets.zero,
                      child: BrandTile(
                        leading: AppIcon(
                          b.isSubscription
                              ? AppIcons.subscription
                              : AppIcons.bills,
                          color: overdue
                              ? context.brand.danger
                              : context.brand.expense,
                        ),
                        title: Text(
                          b.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${Fmt.money(b.amount, currency)} · ${b.period} · '
                          'due ${Fmt.relativeDay(b.nextDueDate)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: overdue ? context.brand.danger : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BrandButton(
                              label: 'Pay',
                              kind: BrandButtonKind.ghost,
                              expand: false,
                              onPressed: () async {
                                final next = await repo.payRecurring(b);
                                await reminders.syncBill(next);
                              },
                            ),
                            CircleIconButton(
                              icon: AppIcons.delete,
                              size: 40,
                              onPressed: () async {
                                await repo.deleteRecurring(b.id);
                                await reminders.cancelBill(b.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                // The same pill the empty state offers, so the way to add a
                // bill does not change shape once there is one.
                Center(
                  child: BrandButton(
                    label: 'Add a bill',
                    icon: AppIcons.add,
                    expand: false,
                    onPressed: () => ExpenseEntrySheet.show(
                      context,
                      kind: ExpenseEntrySheet.billMode,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
