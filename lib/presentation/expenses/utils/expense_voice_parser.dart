import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../repository/expense_repository.dart';

@immutable
class ParsedExpense {
  final double? amount;
  final int? categoryId;
  final int? accountId;
  final int? kind;
  final String note;

  const ParsedExpense({
    this.amount,
    this.categoryId,
    this.accountId,
    this.kind,
    this.note = '',
  });
}

/// Turns a spoken phrase such as *"Spent 200 taka on lunch with bKash"* into
/// entry-sheet fields.
///
/// Matching against the user's own category and account names means the parser
/// automatically understands whatever they have set up, including Bangla names.
class ExpenseVoiceParser {
  const ExpenseVoiceParser._();

  /// Words that hint at a category but are not the category's own name.
  ///
  /// Public because the assistant's name resolver reuses the same hints, so
  /// "lunch" lands in Food whether it was typed here or spoken there.
  static const categoryHints = <String, List<String>>{
    'Food': [
      'lunch',
      'dinner',
      'breakfast',
      'snack',
      'restaurant',
      'meal',
      'tea',
      'coffee',
    ],
    'Transport': [
      'bus',
      'taxi',
      'uber',
      'pathao',
      'rickshaw',
      'fuel',
      'petrol',
      'cng',
      'train',
      'fare',
    ],
    'Groceries': ['grocery', 'groceries', 'bazar', 'market', 'vegetables'],
    'Bills': [
      'bill',
      'electricity',
      'gas',
      'water',
      'internet',
      'wifi',
      'recharge',
    ],
    'Health': ['medicine', 'doctor', 'pharmacy', 'hospital', 'clinic'],
    'Entertainment': ['movie', 'cinema', 'game', 'netflix', 'concert'],
    'Shopping': ['shirt', 'shoes', 'clothes', 'dress', 'shopping'],
    'Education': ['book', 'course', 'tuition', 'exam', 'fee'],
  };

  static const _incomeWords = [
    'earned',
    'received',
    'got paid',
    'income',
    'salary',
    'refund',
  ];

  static ParsedExpense parse(
    String phrase, {
    required List<ExpenseCategory> categories,
    required List<Account> accounts,
  }) {
    final lower = phrase.toLowerCase();
    var note = phrase.trim();

    // --- Amount ---
    // Accepts "200", "1,200", "৳200", "200 taka", "200tk".
    final amountMatch = RegExp(
      r'(\d[\d,]*(?:\.\d+)?)',
    ).firstMatch(lower.replaceAll('৳', ' '));
    final amount = amountMatch == null
        ? null
        : double.tryParse(amountMatch.group(1)!.replaceAll(',', ''));

    // --- Kind ---
    final isIncome = _incomeWords.any(lower.contains);
    final kind = isIncome ? TxKind.income : TxKind.expense;

    // --- Account, matched on the user's own account names ---
    int? accountId;
    for (final a in accounts) {
      if (lower.contains(a.name.toLowerCase()) ||
          lower.contains(a.type.toLowerCase())) {
        accountId = a.id;
        break;
      }
    }

    // --- Category: exact name first, then the hint words ---
    int? categoryId;
    for (final c in categories) {
      if (c.isIncome != isIncome) continue;
      if (lower.contains(c.name.toLowerCase())) {
        categoryId = c.id;
        break;
      }
    }
    if (categoryId == null) {
      outer:
      for (final entry in categoryHints.entries) {
        for (final hint in entry.value) {
          if (!RegExp('\\b$hint').hasMatch(lower)) continue;
          final match = categories
              .where((c) => c.name == entry.key && c.isIncome == isIncome)
              .firstOrNull;
          if (match != null) {
            categoryId = match.id;
            break outer;
          }
        }
      }
    }

    // Strip the bookkeeping words so the note reads as a description.
    note = note
        .replaceAll(
          RegExp(
            r'\b(spent|paid|spend|bought|for|on|with|using|taka|tk|bdt|'
            r'earned|received|income)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'[\d,]+(\.\d+)?'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return ParsedExpense(
      amount: amount,
      categoryId: categoryId,
      accountId: accountId,
      kind: kind,
      note: note,
    );
  }
}
