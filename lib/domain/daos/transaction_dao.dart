import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/tables/transaction_details_table.dart';
import '../../core/db/tables/transactions_table.dart';
import '../../data/models/transaction_with_items.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, TransactionDetails])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(AppDatabase db) : super(db);

  Future<int> insertTransaction(double total) async {
    return into(transactions)
        .insert(TransactionsCompanion.insert(total: total, items: ''));
  }

  Future<void> insertDetails(
      int transactionId, List<TransactionDetailsCompanion> items) async {
    await batch((batch) {
      batch.insertAll(transactionDetails, items);
    });
  }

  Future<List<TransactionDetailData>> getDetailsByTransactionId(int id) {
    return (select(transactionDetails)
          ..where((tbl) => tbl.transactionId.equals(id)))
        .get();
  }

  Stream<List<TransactionWithItems>> watchAllTransactions() {
    final txStream = select(transactions).watch();

    return txStream.asyncMap((txRows) async {
      final result = <TransactionWithItems>[];

      for (final tx in txRows) {
        final details = await (select(transactionDetails)
              ..where((d) => d.transactionId.equals(tx.id)))
            .get();

        result.add(TransactionWithItems(
          transaction: tx,
          items: details,
        ));
      }

      return result;
    });
  }
}
