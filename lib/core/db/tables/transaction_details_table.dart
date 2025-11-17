import 'package:drift/drift.dart';
import 'package:mvvm_flutter_boilerplate/core/db/tables/transactions_table.dart';

@DataClassName('TransactionDetailData')
class
TransactionDetails extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get transactionId => integer().references(Transactions, #id)();

  IntColumn get productId => integer()();

  IntColumn get quantity => integer()();

  RealColumn get price => real()();
}
