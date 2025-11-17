import 'package:drift/drift.dart';
import 'package:mvvm_flutter_boilerplate/core/db/tables/products_table.dart';
import 'package:mvvm_flutter_boilerplate/core/db/tables/transaction_details_table.dart';
import 'package:mvvm_flutter_boilerplate/core/db/tables/transactions_table.dart';
import '../../domain/daos/product_dao.dart';

import '../../domain/daos/transaction_dao.dart';
import 'connection/connection_web.dart'
if (dart.library.io) 'connection/connection_native.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Products, Transactions, TransactionDetails],
  daos: [ProductDao, TransactionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}


