/// Locally relevant accounts including bKash, Nagad and Rocket (spec 4.5).
enum AccountType { cash, bank, card, bkash, nagad, rocket }

extension AccountTypeX on AccountType {
  String get label => switch (this) {
        AccountType.cash => 'Cash',
        AccountType.bank => 'Bank',
        AccountType.card => 'Card',
        AccountType.bkash => 'bKash',
        AccountType.nagad => 'Nagad',
        AccountType.rocket => 'Rocket',
      };
}

class ExpenseCategory {
  const ExpenseCategory(this.name, this.iconCode, this.color);
  final String name;
  final int iconCode;
  final int color;
}

class Expense {
  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.account,
    required this.date,
    this.isIncome = false,
    this.note = '',
    this.tags = const [],
  });

  final String id;
  double amount;
  String category;
  AccountType account;
  DateTime date;
  bool isIncome;
  String note;
  List<String> tags;

  /// Signed value: income positive, expense negative (for balances/cash flow).
  double get signed => isIncome ? amount : -amount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category,
        'account': account.name,
        'date': date.toIso8601String(),
        'isIncome': isIncome,
        'note': note,
        'tags': tags,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        account: AccountType.values.byName(json['account'] as String? ?? 'cash'),
        date: DateTime.parse(json['date'] as String),
        isIncome: json['isIncome'] as bool? ?? false,
        note: json['note'] as String? ?? '',
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      );
}
