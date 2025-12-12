import '../../core/db/app_database.dart';
import '../../core/db/tables/transactions_table.dart';
import '../../domain/daos/expense_dao.dart';
import '../../domain/daos/transaction_dao.dart';
import '../models/transaction_with_items.dart';

class TransactionRepository {
  final TransactionDao _txDao;
  final ExpenseDao _expDao;

  TransactionRepository(this._txDao, this._expDao);

  // =============================
  //  TRANSACTION (masih ada)
  // =============================
  Future<void> saveTransaction(
      double total, List<Map<String, dynamic>> items) async {

    final id = await _txDao.insertTransaction(total);

    final details = items.map((e) {
      return TransactionDetailsCompanion.insert(
        transactionId: id,
        productId: e['productId'],
        price: e['price'],
        quantity: e['quantity'],
      );
    }).toList();

    await _txDao.insertDetails(id, details);
  }

  Stream<List<TransactionWithItems>> watchAllTransactions() =>
      _txDao.watchAllTransactions();

  // =============================
  //  EXPENSE
  // =============================
  Future<void> saveExpense({
    required String name,
    required int qty,
    required double price,
    required double total,
    required DateTime date,
  }) async {
    final data = ExpensesCompanion.insert(
      name: name,
      qty: qty,
      price: price,
      total: total,
      date: date,
    );

    await _expDao.insertExpense(data);
  }

  Stream<List<ExpenseData>> watchAllExpenses() =>
      _expDao.watchAllExpenses();
}

