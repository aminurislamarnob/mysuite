import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/expense_categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/expense.dart';
import '../../state/expenses_controller.dart';

/// Fast expense/income entry: amount + category + account in ~2 taps (spec 4.5).
class AddExpenseSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddExpenseBody(),
    );
  }
}

class _AddExpenseBody extends StatefulWidget {
  const _AddExpenseBody();

  @override
  State<_AddExpenseBody> createState() => _AddExpenseBodyState();
}

class _AddExpenseBodyState extends State<_AddExpenseBody> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _income = false;
  String _category = 'Food';
  AccountType _account = AccountType.cash;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  List<CategoryMeta> get _categories =>
      _income ? kIncomeCategories : kExpenseCategories;

  void _save() {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    final controller = context.read<ExpensesController>();
    controller.add(Expense(
      id: controller.newId(),
      amount: amount,
      category: _category,
      account: _account,
      date: _date,
      isIncome: _income,
      note: _note.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final accent = _income ? AppColors.successLight : AppColors.expenses;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Expense')),
                  ButtonSegment(value: true, label: Text('Income')),
                ],
                selected: {_income},
                onSelectionChanged: (s) => setState(() {
                  _income = s.first;
                  _category = _categories.first.name;
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              textAlign: TextAlign.center,
              style: context.text.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800, color: accent),
              decoration: const InputDecoration(
                prefixText: '৳ ',
                hintText: '0',
                border: InputBorder.none,
                filled: false,
              ),
            ),
            const SizedBox(height: 8),
            Text('Category',
                style: context.text.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _categories)
                  ChoiceChip(
                    avatar: Icon(c.icon,
                        size: 16,
                        color: _category == c.name
                            ? Color(c.color)
                            : context.muted),
                    label: Text(c.name),
                    selected: _category == c.name,
                    selectedColor: Color(c.color).withValues(alpha: 0.18),
                    onSelected: (_) => setState(() => _category = c.name),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Account',
                style: context.text.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in AccountType.values)
                  ChoiceChip(
                    label: Text(a.label),
                    selected: _account == a,
                    onSelected: (_) => setState(() => _account = a),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _date = picked);
                      }
                    },
                    icon: const Icon(LucideIcons.calendar, size: 18),
                    label: Text(_dateLabel()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(LucideIcons.pencil),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(backgroundColor: accent),
                child: Text(_income ? 'Add income' : 'Add expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel() {
    final now = DateTime.now();
    if (_date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day) {
      return 'Today';
    }
    return '${_date.day}/${_date.month}/${_date.year}';
  }
}
