import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/storage/local_store.dart';
import '../core/utils/formatters.dart';
import '../models/expense.dart';

class ExpensesController extends ChangeNotifier {
  ExpensesController(this._store) {
    _load();
  }

  static const _key = 'expenses';
  static const _uuid = Uuid();
  final LocalStore _store;
  final List<Expense> _items = [];

  /// Most recent first.
  List<Expense> get all {
    final list = [..._items];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void _load() {
    _items
      ..clear()
      ..addAll(_store.readList(_key).map(Expense.fromJson));
  }

  Future<void> _persist() =>
      _store.writeList(_key, _items.map((e) => e.toJson()).toList());

  String newId() => _uuid.v4();

  Expense add(Expense e) {
    _items.add(e);
    _persist();
    notifyListeners();
    return e;
  }

  void delete(String id) {
    _items.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  bool _inMonth(DateTime d, DateTime month) =>
      d.year == month.year && d.month == month.month;

  List<Expense> month(DateTime month) =>
      all.where((e) => _inMonth(e.date, month)).toList();

  double spentToday() {
    final now = DateTime.now();
    return _items
        .where((e) => !e.isIncome && Day.same(e.date, now))
        .fold(0.0, (s, e) => s + e.amount);
  }

  double spentThisMonth() => month(DateTime.now())
      .where((e) => !e.isIncome)
      .fold(0.0, (s, e) => s + e.amount);

  double incomeThisMonth() => month(DateTime.now())
      .where((e) => e.isIncome)
      .fold(0.0, (s, e) => s + e.amount);

  double get balance => _items.fold(0.0, (s, e) => s + e.signed);

  /// Spend grouped by category for [month] (expenses only), sorted desc.
  List<MapEntry<String, double>> byCategory(DateTime month) {
    final map = <String, double>{};
    for (final e in this.month(month).where((e) => !e.isIncome)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Net total per day for the last [days] days (oldest first) — bar chart.
  List<double> dailySpend(int days) {
    final today = Day.today();
    return List.generate(days, (i) {
      final d = today.subtract(Duration(days: days - 1 - i));
      return _items
          .where((e) => !e.isIncome && Day.same(e.date, d))
          .fold(0.0, (s, e) => s + e.amount);
    });
  }
}
