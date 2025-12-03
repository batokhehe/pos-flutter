import 'package:flutter/material.dart';
import 'package:mvvm_flutter_boilerplate/data/models/transaction_with_items.dart';

import '../../core/db/app_database.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repo;

  TransactionViewModel(this._repo);

  Stream<List<TransactionWithItems>> get transactions => _repo.watchAll();

  Future<void> addTransaction(
      double total, List<Map<String, dynamic>> items) async {
    await _repo.saveTransaction(total, items);
    notifyListeners();
  }

  Future<void> addSingleExpense(String name, int qty, double price) async {
    final total = qty * price;

    await _repo.addExpense(
      name: name,
      qty: qty,
      price: price,
      total: total,
      date: DateTime.now(),
    );

    loadExpenses();
  }
}
