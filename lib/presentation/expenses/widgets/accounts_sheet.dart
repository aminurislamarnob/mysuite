import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';

/// Every account with its balance, plus the tools to add, edit and archive
/// them. Archived accounts keep their history and drop out of the total.
class AccountsSheet extends ConsumerWidget {
  const AccountsSheet({super.key});

  static Future<void> show(BuildContext context) =>
      brandSheet(context: context, builder: (_) => const AccountsSheet());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final accounts = ref.watch(allAccountsProvider).valueOrNull ?? const [];
    final active = accounts.where((a) => !a.isArchived).toList();
    final archived = accounts.where((a) => a.isArchived).toList();

    return SheetScaffold(
      title: 'Accounts',
      actions: [
        CircleIconButton(
          icon: AppIcons.add,
          tooltip: 'Add account',
          size: 40,
          onPressed: () => _edit(context, ref),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in active) _AccountRow(account: a, currency: currency),
          if (archived.isNotEmpty) ...[
            const SizedBox(height: 12),
            const SectionHeader(
              'Archived',
              padding: EdgeInsets.only(bottom: 8),
            ),
            for (final a in archived)
              _AccountRow(account: a, currency: currency),
          ],
        ],
      ),
    );
  }

  /// Creates an account, or edits [account] when given.
  static Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    Account? account,
  }) async {
    final name = TextEditingController(text: account?.name ?? '');
    final balance = TextEditingController();
    var type = account?.type ?? 'cash';
    var color = account?.color ?? 0xFF9A6DD7;

    final saved = await brandDialog<bool>(
      context,
      title: account == null ? 'New account' : 'Edit account',
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrandField(controller: name, label: 'Name', autofocus: true),
            if (account == null) ...[
              const SizedBox(height: 12),
              BrandField(
                controller: balance,
                label: 'Opening balance',
                hint: '0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in AppIcons.accountIcons.keys)
                  Pill(
                    label: _typeLabel(t),
                    icon: AppIcons.account(t),
                    selected: type == t,
                    color: Theme.of(dialogContext).colorScheme.primary,
                    onTap: () => setState(() => type = t),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ColorPickerRow(
              selected: color,
              onChanged: (c) => setState(() => color = c),
            ),
            const SizedBox(height: 20),
            BrandButton(
              label: account == null ? 'Create' : 'Save',
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
            const SizedBox(height: 8),
            BrandButton(
              label: 'Cancel',
              kind: BrandButtonKind.ghost,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
          ],
        ),
      ),
    );

    if (saved != true || name.text.trim().isEmpty) return;
    final repo = ref.read(expenseRepositoryProvider);
    if (account == null) {
      await repo.createAccount(
        name.text.trim(),
        type,
        double.tryParse(balance.text.trim()) ?? 0,
        color,
      );
    } else {
      await repo.updateAccount(
        account.id,
        name: name.text.trim(),
        type: type,
        color: color,
      );
    }
  }

  static String _typeLabel(String type) => switch (type) {
    'bkash' => 'bKash',
    'nagad' => 'Nagad',
    'rocket' => 'Rocket',
    _ => type[0].toUpperCase() + type.substring(1),
  };
}

class _AccountRow extends ConsumerWidget {
  final Account account;
  final String currency;

  const _AccountRow({required this.account, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(expenseRepositoryProvider);
    final muted = Theme.of(context).colorScheme.outline;

    return BrandTile(
      dense: true,
      leading: AppIcon(
        AppIcons.account(account.type),
        color: account.isArchived ? muted : Color(account.color),
      ),
      title: Text(
        account.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        Fmt.money(account.balance, currency),
        style: TextStyle(fontSize: 12, color: muted),
      ),
      trailing: CircleIconButton(
        icon: account.isArchived ? AppIcons.unarchive : AppIcons.archive,
        tooltip: account.isArchived ? 'Restore' : 'Archive',
        size: 40,
        onPressed: () =>
            repo.setAccountArchived(account.id, !account.isArchived),
      ),
      onTap: () => AccountsSheet._edit(context, ref, account: account),
    );
  }
}
