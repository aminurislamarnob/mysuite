import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';

class BillsTab extends ConsumerWidget {
  const BillsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final bills = ref.watch(recurringProvider);
    final subsTotal = ref.watch(subscriptionTotalProvider).valueOrNull ?? 0;
    final repo = ref.read(expenseRepositoryProvider);

    return Stack(
      children: [
        bills.when(
          loading: () => const Center(child: BrandSpinner()),
          error: (e, _) => Text('$e'),
          data: (rows) => rows.isEmpty
              ? EmptyState(
                  icon: AppIcons.calendarRepeat,
                  title: 'No bills or subscriptions',
                  message:
                      'Track rent, internet, Netflix — anything recurring.',
                  actionLabel: 'Add a bill',
                  onAction: () => _addBill(context, ref),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    if (subsTotal > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: StatTile(
                          icon: AppIcons.subscription,
                          color: AppColors.expenseAccent,
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
                                  ? AppColors.dangerLight
                                  : AppColors.expenseAccent,
                            ),
                            title: Text(
                              b.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${Fmt.money(b.amount, currency)} · ${b.period} · '
                              'due ${Fmt.relativeDay(b.nextDueDate)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: overdue ? AppColors.dangerLight : null,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BrandButton(
                                  label: 'Pay',
                                  kind: BrandButtonKind.ghost,
                                  expand: false,
                                  onPressed: () => repo.payRecurring(b),
                                ),
                                CircleIconButton(
                                  icon: AppIcons.delete,
                                  size: 40,
                                  onPressed: () => repo.deleteRecurring(b.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'bill-fab',
            onPressed: () => _addBill(context, ref),
            backgroundColor: AppColors.expenseAccent,
            foregroundColor: Colors.white,
            child: const AppIcon(AppIcons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _addBill(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final amount = TextEditingController();
    var period = 'monthly';
    var isSubscription = false;
    var due = DateTime.now().add(const Duration(days: 30));
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    int? accountId = accounts.firstOrNull?.id;
    int? categoryId;

    final saved = await brandSheet<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => SheetScaffold(
          title: 'New recurring bill',
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
              BrandField(
                controller: name,
                label: 'Name',
                hint: 'Internet',
                autofocus: true,
              ),
              const SizedBox(height: 12),
              BrandField(
                controller: amount,
                label: 'Amount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              BrandSegmented<String>(
                options: const {
                  'weekly': 'Weekly',
                  'monthly': 'Monthly',
                  'yearly': 'Yearly',
                },
                selected: period,
                onSelected: (v) => setState(() => period = v),
              ),
              const SizedBox(height: 8),
              BrandSwitchTile(
                title: 'This is a subscription',
                value: isSubscription,
                onChanged: (v) => setState(() => isSubscription = v),
              ),
              BrandTile(
                leading: const AppIcon(AppIcons.calendar),
                title: const Text('Next due'),
                subtitle: Text(Fmt.dayMonthYear(due)),
                onTap: () async {
                  final picked = await brandDatePicker(
                    context,
                    initial: due,
                    first: DateTime.now(),
                    last: DateTime(2100),
                    title: 'Next due',
                  );
                  if (picked != null) setState(() => due = picked);
                },
              ),
              const SizedBox(height: 8),
              const Text('Account'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: accounts
                    .map(
                      (a) => Pill(
                        label: a.name,
                        selected: accountId == a.id,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () => setState(() => accountId = a.id),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Text('Category'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories
                    .where((c) => !c.isIncome)
                    .map(
                      (c) => Pill(
                        label: c.name,
                        selected: categoryId == c.id,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () => setState(() => categoryId = c.id),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );

    final value = double.tryParse(amount.text.trim());
    if (saved == true && name.text.trim().isNotEmpty && value != null) {
      await ref
          .read(expenseRepositoryProvider)
          .createRecurring(
            RecurringExpensesCompanion.insert(
              name: name.text.trim(),
              amount: value,
              period: drift.Value(period),
              isSubscription: drift.Value(isSubscription),
              nextDueDate: due,
              accountId: drift.Value(accountId),
              categoryId: drift.Value(categoryId),
            ),
          );
    }
  }
}
