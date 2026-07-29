import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../providers/expenses_provider.dart';
import '../repository/expense_repository.dart';
import '../utils/expense_voice_parser.dart';

/// Two-tap entry: amount is prefilled and focused, category and account are
/// one tap each, then Save.
class ExpenseEntrySheet extends ConsumerStatefulWidget {
  final int initialKind;
  final String? initialNote;
  final double? initialAmount;
  final String? receiptPath;

  const ExpenseEntrySheet({
    super.key,
    this.initialKind = TxKind.expense,
    this.initialNote,
    this.initialAmount,
    this.receiptPath,
  });

  static Future<void> show(
    BuildContext context, {
    int kind = TxKind.expense,
    String? note,
    double? amount,
    String? receiptPath,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExpenseEntrySheet(
        initialKind: kind,
        initialNote: note,
        initialAmount: amount,
        receiptPath: receiptPath,
      ),
    );
  }

  @override
  ConsumerState<ExpenseEntrySheet> createState() => _ExpenseEntrySheetState();
}

class _ExpenseEntrySheetState extends ConsumerState<ExpenseEntrySheet> {
  late final TextEditingController _amount;
  late final TextEditingController _note;
  final _speech = stt.SpeechToText();

  late int _kind;
  int? _categoryId;
  int? _accountId;
  int? _transferAccountId;
  DateTime _date = DateTime.now();
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind;
    _amount = TextEditingController(
        text: widget.initialAmount == null
            ? ''
            : widget.initialAmount!.toStringAsFixed(0));
    _note = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _voiceEntry() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    if (!await _speech.initialize()) {
      _toast('Speech recognition is unavailable on this device.');
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(onResult: (r) {
      if (!r.finalResult) return;
      setState(() => _listening = false);
      _applyVoice(r.recognizedWords);
    });
  }

  void _applyVoice(String phrase) {
    final categories = ref.read(categoriesProvider).valueOrNull ?? const [];
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    final parsed = ExpenseVoiceParser.parse(phrase,
        categories: categories, accounts: accounts);

    setState(() {
      if (parsed.amount != null) _amount.text = parsed.amount!.toStringAsFixed(0);
      if (parsed.categoryId != null) _categoryId = parsed.categoryId;
      if (parsed.accountId != null) _accountId = parsed.accountId;
      if (parsed.kind != null) _kind = parsed.kind!;
      _note.text = parsed.note;
    });
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
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

    await ref.read(expenseRepositoryProvider).addTransaction(
          amount: amount,
          accountId: accountId,
          categoryId: _kind == TxKind.transfer ? null : _categoryId,
          kind: _kind,
          transferAccountId: _transferAccountId,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          receiptPath: widget.receiptPath,
          date: _date,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currencySymbol;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final allCategories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final categories = allCategories
        .where((c) => c.isIncome == (_kind == TxKind.income))
        .toList();
    final muted = Theme.of(context).colorScheme.outline;

    _accountId ??= accounts.firstOrNull?.id;

    return SheetScaffold(
      title: switch (_kind) {
        TxKind.income => 'Add income',
        TxKind.transfer => 'Transfer',
        _ => 'Add expense',
      },
      actions: [
        IconButton(
          tooltip: 'Voice entry',
          icon: AppIcon(_listening ? AppIcons.mic : AppIcons.mic),
          color: _listening ? AppColors.dangerLight : null,
          onPressed: _voiceEntry,
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: TxKind.expense, label: Text('Expense')),
              ButtonSegment(value: TxKind.income, label: Text('Income')),
              ButtonSegment(value: TxKind.transfer, label: Text('Transfer')),
            ],
            selected: {_kind},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() {
              _kind = s.first;
              _categoryId = null;
            }),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style:
                const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              prefixText: '$currency ',
              prefixStyle: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w600, color: muted),
              hintText: '0',
            ),
          ),
          const SizedBox(height: 16),

          if (_kind != TxKind.transfer) ...[
            Text('Category', style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .map((c) => ChoiceChip(
                        avatar: AppIcon(AppIcons.category(c.icon),
                            size: 16, color: Color(c.color)),
                        label: Text(c.name),
                        selected: _categoryId == c.id,
                        onSelected: (_) => setState(() => _categoryId = c.id),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          Text(_kind == TxKind.transfer ? 'From account' : 'Account',
              style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accounts
                .map((a) => ChoiceChip(
                      avatar: AppIcon(AppIcons.account(a.type),
                          size: 16, color: Color(a.color)),
                      label: Text(a.name),
                      selected: _accountId == a.id,
                      onSelected: (_) => setState(() => _accountId = a.id),
                    ))
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
                  .map((a) => ChoiceChip(
                        avatar: AppIcon(AppIcons.account(a.type),
                            size: 16, color: Color(a.color)),
                        label: Text(a.name),
                        selected: _transferAccountId == a.id,
                        onSelected: (_) =>
                            setState(() => _transferAccountId = a.id),
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 16),
          TextField(
            controller: _note,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Note',
              prefixIcon: AppIcon(AppIcons.note),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const AppIcon(AppIcons.calendar),
            title: const Text('Date'),
            subtitle: Text(Fmt.dayMonthYear(_date)),
            trailing: const AppIcon(AppIcons.chevronRight),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          if (widget.receiptPath != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(AppIcons.bills),
              title: const Text('Receipt attached'),
              subtitle: Text(widget.receiptPath!.split('/').last),
            ),
        ],
      ),
    );
  }
}
