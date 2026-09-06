import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/people/people_repository.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../../settings/people_screen.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';
import '../utils/expense_reminders.dart';

/// Opens a loan: who, which way, how much, out of which account.
class LoanSheet extends ConsumerStatefulWidget {
  const LoanSheet({super.key});

  static Future<void> show(BuildContext context) =>
      brandSheet(context: context, builder: (_) => const LoanSheet());

  @override
  ConsumerState<LoanSheet> createState() => _LoanSheetState();
}

class _LoanSheetState extends ConsumerState<LoanSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();

  int _direction = LoanDirection.lent;
  int? _personId;
  int? _accountId;
  DateTime? _dueDate;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _newPerson() async {
    final id = await PersonEditor.show(context, ref, type: PersonType.contact);
    if (id != null && mounted) setState(() => _personId = id);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      brandToast(context, 'Enter an amount first.');
      return;
    }
    if (_personId == null) {
      brandToast(context, 'Choose who this is with.');
      return;
    }
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    final accountId = _accountId ?? accounts.firstOrNull?.id;
    if (accountId == null) {
      brandToast(context, 'Add an account first.');
      return;
    }

    final id = await ref
        .read(expenseRepositoryProvider)
        .createLoan(
          personId: _personId!,
          direction: _direction,
          principal: amount,
          accountId: accountId,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          dueDate: _dueDate,
        );
    await ref.read(expenseRemindersProvider).syncLoan(id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    // Anyone can be on the other side of a loan, household or not — except
    // me, since I cannot owe myself.
    final people = (ref.watch(peopleProvider).valueOrNull ?? const [])
        .where((p) => !p.isSelf)
        .toList();
    final muted = Theme.of(context).colorScheme.outline;

    _accountId ??= accounts.firstOrNull?.id;

    return SheetScaffold(
      title: _direction == LoanDirection.lent ? 'Money lent' : 'Money borrowed',
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
          BrandSegmented<int>(
            options: const {
              LoanDirection.lent: 'I lent',
              LoanDirection.borrowed: 'I borrowed',
            },
            selected: _direction,
            onSelected: (v) => setState(() => _direction = v),
          ),
          const SizedBox(height: 20),
          BrandField(
            controller: _amount,
            hint: '0',
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textStyle: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
            prefix: Text(
              currency,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: muted,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            _direction == LoanDirection.lent ? 'Lent to' : 'Borrowed from',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in people)
                Pill(
                  label: p.name,
                  icon: AppIcons.person,
                  selected: _personId == p.id,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => setState(() => _personId = p.id),
                ),
              Pill(
                label: 'New',
                icon: AppIcons.personAdd,
                color: muted,
                onTap: _newPerson,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            _direction == LoanDirection.lent ? 'Paid from' : 'Received into',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accounts
                .map(
                  (a) => Pill(
                    label: a.name,
                    icon: AppIcons.account(a.type),
                    selected: _accountId == a.id,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => setState(() => _accountId = a.id),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          BrandField(
            controller: _note,
            label: 'Note',
            textCapitalization: TextCapitalization.sentences,
            prefix: const AppIcon(AppIcons.note),
          ),
          const SizedBox(height: 8),
          BrandTile(
            leading: const AppIcon(AppIcons.calendar),
            title: const Text('Due date'),
            subtitle: Text(
              _dueDate == null ? 'None' : Fmt.dayMonthYear(_dueDate!),
            ),
            trailing: _dueDate == null
                ? const AppIcon(AppIcons.chevronRight)
                : CircleIconButton(
                    icon: AppIcons.clear,
                    tooltip: 'Clear',
                    size: 40,
                    onPressed: () => setState(() => _dueDate = null),
                  ),
            onTap: () async {
              final picked = await brandDatePicker(
                context,
                initial:
                    _dueDate ?? DateTime.now().add(const Duration(days: 30)),
                first: DateTime(2000),
                last: DateTime(2100),
                title: 'Due date',
              );
              if (picked != null) setState(() => _dueDate = picked);
            },
          ),
        ],
      ),
    );
  }
}

/// Books a repayment against an open loan.
class RepaySheet extends ConsumerStatefulWidget {
  final LoanRow row;

  const RepaySheet({super.key, required this.row});

  static Future<void> show(BuildContext context, LoanRow row) => brandSheet(
    context: context,
    builder: (_) => RepaySheet(row: row),
  );

  @override
  ConsumerState<RepaySheet> createState() => _RepaySheetState();
}

class _RepaySheetState extends ConsumerState<RepaySheet> {
  late final TextEditingController _amount;
  int? _accountId;

  @override
  void initState() {
    super.initState();
    // The whole remaining balance is the common case; a partial payment is
    // a matter of editing the figure down.
    _amount = TextEditingController(
      text: Fmt.amountInput(widget.row.outstanding),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      brandToast(context, 'Enter an amount first.');
      return;
    }
    if (amount > widget.row.outstanding) {
      brandToast(context, 'That is more than is still owed.');
      return;
    }
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    final accountId = _accountId ?? accounts.firstOrNull?.id;
    if (accountId == null) return;

    await ref
        .read(expenseRepositoryProvider)
        .repay(
          widget.row.loan.id,
          amount: amount,
          accountId: accountId,
          note: widget.row.loan.note,
        );
    await ref.read(expenseRemindersProvider).syncLoan(widget.row.loan.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final muted = Theme.of(context).colorScheme.outline;
    final row = widget.row;

    _accountId ??= accounts.firstOrNull?.id;

    return SheetScaffold(
      title: row.isLent ? 'Repayment received' : 'Repayment made',
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
          Text(
            '${Fmt.money(row.outstanding, currency)} outstanding'
            '${row.person == null ? '' : ' with ${row.person!.name}'}',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          BrandField(
            controller: _amount,
            hint: '0',
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textStyle: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
            prefix: Text(
              currency,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: muted,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            row.isLent ? 'Received into' : 'Paid from',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accounts
                .map(
                  (a) => Pill(
                    label: a.name,
                    icon: AppIcons.account(a.type),
                    selected: _accountId == a.id,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => setState(() => _accountId = a.id),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
