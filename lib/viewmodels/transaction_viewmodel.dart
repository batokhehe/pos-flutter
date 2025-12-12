import 'package:flutter/material.dart';
import 'package:mvvm_flutter_boilerplate/data/models/transaction_with_items.dart';

import '../../core/db/app_database.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repo;

  List<TransactionWithItems> transactions = [];
  List<ExpenseData> expenses = [];

  Stream<List<TransactionWithItems>> get transactionStream =>
      _repo.watchAllTransactions();


  TransactionViewModel(this._repo) {
    // Listen transaksi
    _repo.watchAllTransactions().listen((data) {
      transactions = data;
      notifyListeners();
    });

    // Listen expenses
    _repo.watchAllExpenses().listen((data) {
      expenses = data;
      notifyListeners();
    });
  }

  // ====== TAMBAH TRANSACTION ======
  Future<void> addTransaction(
      double total, List<Map<String, dynamic>> items) async {
    await _repo.saveTransaction(total, items);
  }

  // ====== TAMBAH EXPENSE ======
  Future<void> addSingleExpense(String name, int qty, double price) async {
    final total = qty * price;

    await _repo.saveExpense(
      name: name,
      qty: qty,
      price: price,
      total: total,
      date: DateTime.now(),
    );
  }
}
