import '../../core/db/app_database.dart';
import '../../core/db/tables/transactions_table.dart';
import '../../domain/daos/transaction_dao.dart';
import '../models/transaction_with_items.dart';

class TransactionRepository {
  final TransactionDao _dao;

  TransactionRepository(this._dao);

  Future<void> saveTransaction(
      double total, List<Map<String, dynamic>> items) async {
    final id = await _dao.insertTransaction(total);
    final details = items.map((e) {
      return TransactionDetailsCompanion.insert(
        transactionId: id,
        productId: e['productId'],
        price: e['price'],
        quantity: e['quantity'],
      );
    }).toList();

    await _dao.insertDetails(id, details);
  }

  // Stream<List<TransactionData>> watchAll() => _dao.watchAllTransactions();
  Stream<List<TransactionWithItems>> watchAll() =>
      _dao.watchAllTransactions();

}
