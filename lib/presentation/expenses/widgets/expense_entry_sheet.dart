import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/speech_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/people/people_repository.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';
import '../../settings/people_screen.dart';
import '../categories_screen.dart';
import '../utils/expense_voice_parser.dart';

/// Two-tap entry: amount is prefilled and focused, category and account are
/// one tap each, then Save.
///
/// The segmented control selects what is being recorded. Three of the four
/// options are [TxKind]s that write a transaction; [billMode] instead writes
/// a recurring bill, so everything the FAB can add starts here.
class ExpenseEntrySheet extends ConsumerStatefulWidget {
  /// Not a [TxKind]: the sheet writes a `RecurringExpenses` row instead of a
  /// transaction. Negative so it can never collide with a kind.
  static const billMode = -1;

  final int initialKind;
  final String? initialNote;
  final double? initialAmount;
  final String? receiptPath;

  /// Prefill for a new transaction, used by the assistant's preview card.
  /// Ignored when [existing] is set, which carries its own values.
  final int? initialCategoryId;
  final int? initialAccountId;
  final int? initialPersonId;
  final DateTime? initialDate;

  /// The row being rewritten; null when adding.
  final Expense? existing;

  const ExpenseEntrySheet({
    super.key,
    this.initialKind = TxKind.expense,
    this.initialNote,
    this.initialAmount,
    this.receiptPath,
    this.initialCategoryId,
    this.initialAccountId,
    this.initialPersonId,
    this.initialDate,
    this.existing,
  });

  /// Pops with the new row's id, or null when dismissed.
  static Future<int?> show(
    BuildContext context, {
    int kind = TxKind.expense,
    String? note,
    double? amount,
    String? receiptPath,
    int? categoryId,
    int? accountId,
    int? personId,
    DateTime? date,
  }) {
    return brandSheet<int>(
      context: context,
      builder: (_) => ExpenseEntrySheet(
        initialKind: kind,
        initialNote: note,
        initialAmount: amount,
        receiptPath: receiptPath,
        initialCategoryId: categoryId,
        initialAccountId: accountId,
        initialPersonId: personId,
        initialDate: date,
      ),
    );
  }

  /// Reopens the sheet on an existing transaction, prefilled.
  static Future<int?> edit(BuildContext context, Expense tx) {
    return brandSheet<int>(
      context: context,
      builder: (_) => ExpenseEntrySheet(
        initialKind: tx.kind,
        initialNote: tx.note,
        initialAmount: tx.amount,
        receiptPath: tx.receiptPath,
        existing: tx,
      ),
    );
  }

  @override
  ConsumerState<ExpenseEntrySheet> createState() => _ExpenseEntrySheetState();
}

class _ExpenseEntrySheetState extends ConsumerState<ExpenseEntrySheet> {
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late final TextEditingController _name;

  late int _kind;
  int? _categoryId;
  int? _accountId;
  int? _transferAccountId;
  int? _personId;

  /// The transaction's date, or the bill's next due date.
  DateTime _date = DateTime.now();
  String _period = 'monthly';
  bool _isSubscription = false;
  bool _listening = false;

  bool get _isBill => _kind == ExpenseEntrySheet.billMode;
  Expense? get _existing => widget.existing;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind;
    _amount = TextEditingController(
      text: widget.initialAmount == null
          ? ''
          : Fmt.amountInput(widget.initialAmount!),
    );
    _note = TextEditingController(text: widget.initialNote ?? '');
    _name = TextEditingController();
    if (_isBill) _date = DateTime.now().add(const Duration(days: 30));
    final existing = widget.existing;
    if (existing != null) {
      _categoryId = existing.categoryId;
      _accountId = existing.accountId;
      _transferAccountId = existing.transferAccountId;
      _personId = existing.personId;
      _date = existing.date;
    } else {
      _categoryId = widget.initialCategoryId;
      _accountId = widget.initialAccountId;
      _personId = widget.initialPersonId;
      if (widget.initialDate != null) _date = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _name.dispose();
    if (_listening) ref.read(speechServiceProvider).stop();
    super.dispose();
  }

  Future<void> _voiceEntry() async {
    final speech = ref.read(speechServiceProvider);
    if (_listening) {
      await speech.stop();
      setState(() => _listening = false);
      return;
    }
    final started = await speech.listen(
      onResult: (words, isFinal) {
        if (!isFinal || !mounted) return;
        setState(() => _listening = false);
        _applyVoice(words);
      },
    );
    if (!started) {
      _toast('Speech recognition is unavailable on this device.');
      return;
    }
    setState(() => _listening = true);
  }

  void _applyVoice(String phrase) {
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    final parsed = ExpenseVoiceParser.parse(
      phrase,
      categories: categories,
      accounts: accounts,
    );

    setState(() {
      if (parsed.amount != null) {
        _amount.text = parsed.amount!.toStringAsFixed(0);
      }
      if (parsed.categoryId != null) _categoryId = parsed.categoryId;
      if (parsed.accountId != null) _accountId = parsed.accountId;
      if (parsed.kind != null) _kind = parsed.kind!;
      _note.text = parsed.note;
    });
  }

  /// Creates a category without leaving the sheet, and selects it.
  Future<void> _newCategory() async {
    final id = await CategoryEditor.show(
      context,
      ref,
      isIncome: _kind == TxKind.income,
    );
    if (id != null && mounted) setState(() => _categoryId = id);
  }

  /// Adds a household member without leaving the sheet, and selects them.
  Future<void> _newPerson() async {
    final id = await PersonEditor.show(context, ref);
    if (id != null && mounted) setState(() => _personId = id);
  }

  void _toast(String m) {
    if (!mounted) return;
    brandToast(context, m);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      _toast('Enter an amount first.');
      return;
    }
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    final accountId = _accountId ?? accounts.firstOrNull?.id;
    if (accountId == null) {
      _toast('Add an account first.');
      return;
    }
    if (_kind == TxKind.transfer && _transferAccountId == null) {
      _toast('Choose the destination account.');
      return;
    }
    if (_isBill) {
      if (_name.text.trim().isEmpty) {
        _toast('Name the bill first.');
        return;
      }
      final billId = await ref
          .read(expenseRepositoryProvider)
          .createRecurring(
            RecurringExpensesCompanion.insert(
              name: _name.text.trim(),
              amount: amount,
              period: drift.Value(_period),
              isSubscription: drift.Value(_isSubscription),
              nextDueDate: _date,
              accountId: drift.Value(accountId),
              categoryId: drift.Value(_categoryId),
            ),
          );
      if (mounted) Navigator.pop(context, billId);
      return;
    }

    final repo = ref.read(expenseRepositoryProvider);
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    final categoryId = _kind == TxKind.transfer ? null : _categoryId;
    final transferAccountId = _kind == TxKind.transfer
        ? _transferAccountId
        : null;

    final existing = _existing;
    int id;
    if (existing == null) {
      id = await repo.addTransaction(
        amount: amount,
        accountId: accountId,
        categoryId: categoryId,
        kind: _kind,
        transferAccountId: transferAccountId,
        personId: _kind == TxKind.transfer ? null : _personId,
        note: note,
        receiptPath: widget.receiptPath,
        date: _date,
      );
    } else {
      id = existing.id;
      await repo.updateTransaction(
        existing.id,
        amount: amount,
        accountId: accountId,
        categoryId: drift.Value(categoryId),
        kind: _kind,
        transferAccountId: drift.Value(transferAccountId),
        personId: _kind == TxKind.transfer ? null : _personId,
        note: drift.Value(note),
        date: _date,
      );
    }

    if (mounted) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final allCategories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final categories = allCategories
        .where((c) => c.isIncome == (_kind == TxKind.income))
        .toList();
    final household = ref.watch(householdProvider).valueOrNull ?? const [];
    final self = household.where((p) => p.isSelf).firstOrNull;
    final muted = Theme.of(context).colorScheme.outline;

    _accountId ??= accounts.firstOrNull?.id;

    return SheetScaffold(
      title: switch ((_kind, _existing != null)) {
        (TxKind.income, false) => 'Add income',
        (TxKind.income, true) => 'Edit income',
        (TxKind.transfer, _) => 'Transfer',
        (ExpenseEntrySheet.billMode, _) => 'Add bill',
        (_, true) => 'Edit expense',
        _ => 'Add expense',
      },
      actions: [
        // The parser only ever produces an expense or income, so dictating
        // into the bill form would silently leave it.
        if (!_isBill)
          CircleIconButton(
            icon: _listening ? AppIcons.micOff : AppIcons.mic,
            tooltip: 'Voice entry',
            color: _listening ? context.brand.danger : null,
            size: 40,
            onPressed: _voiceEntry,
          ),
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
            options: {
              TxKind.expense: 'Expense',
              TxKind.income: 'Income',
              TxKind.transfer: 'Transfer',
              if (_existing == null) ExpenseEntrySheet.billMode: 'Bill',
            },
            selected: _kind,
            onSelected: (k) => setState(() {
              _kind = k;
              _categoryId = null;
              // A bill is dated by when it next falls due, not today.
              _date = _isBill
                  ? DateTime.now().add(const Duration(days: 30))
                  : DateTime.now();
            }),
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
            // The field centres its prefix on the input's full height while the
            // amount itself sits on a baseline. The two only line up when the
            // symbol's line box matches the amount's, so this size tracks the
            // textStyle above; weight and colour still set it back.
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

          if (_isBill) ...[
            BrandField(
              controller: _name,
              label: 'Name',
              hint: 'Internet',
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            BrandSegmented<String>(
              options: const {
                'weekly': 'Weekly',
                'monthly': 'Monthly',
                'yearly': 'Yearly',
              },
              selected: _period,
              onSelected: (v) => setState(() => _period = v),
            ),
            const SizedBox(height: 8),
            BrandSwitchTile(
              title: 'This is a subscription',
              value: _isSubscription,
              onChanged: (v) => setState(() => _isSubscription = v),
            ),
            const SizedBox(height: 8),
          ],

          if (_kind != TxKind.transfer) ...[
            Text('Category', style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  Pill(
                    label: c.name,
                    icon: AppIcons.category(c.icon),
                    selected: _categoryId == c.id,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => setState(() => _categoryId = c.id),
                  ),
                Pill(
                  label: 'New',
                  icon: AppIcons.add,
                  color: muted,
                  onTap: _newCategory,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          Text(
            _kind == TxKind.transfer ? 'From account' : 'Account',
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

          if (_kind == TxKind.transfer) ...[
            const SizedBox(height: 16),
            Text('To account', style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: accounts
                  .where((a) => a.id != _accountId)
                  .map(
                    (a) => Pill(
                      label: a.name,
                      icon: AppIcons.account(a.type),
                      selected: _transferAccountId == a.id,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => setState(() => _transferAccountId = a.id),
                    ),
                  )
                  .toList(),
            ),
          ],

          if (_kind != TxKind.transfer && !_isBill) ...[
            const SizedBox(height: 16),
            Text('For', style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in household)
                  Pill(
                    label: p.isSelf ? 'Me' : p.name,
                    icon: AppIcons.person,
                    selected: (_personId ?? self?.id) == p.id,
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
          ],

          if (!_isBill) ...[
            const SizedBox(height: 16),
            BrandField(
              controller: _note,
              label: 'Note',
              textCapitalization: TextCapitalization.sentences,
              prefix: const AppIcon(AppIcons.note),
            ),
          ],
          const SizedBox(height: 8),
          BrandTile(
            leading: const AppIcon(AppIcons.calendar),
            title: Text(_isBill ? 'Next due' : 'Date'),
            subtitle: Text(Fmt.dayMonthYear(_date)),
            trailing: const AppIcon(AppIcons.chevronRight),
            onTap: () async {
              final picked = await brandDatePicker(
                context,
                initial: _date,
                first: DateTime(2000),
                last: DateTime(2100),
                title: 'Date',
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          if (widget.receiptPath != null) ...[
            const SizedBox(height: cardGap),
            BrandTile(
              leading: const AppIcon(AppIcons.bills),
              title: const Text('Receipt attached'),
              subtitle: Text(widget.receiptPath!.split('/').last),
            ),
          ],
        ],
      ),
    );
  }
}
