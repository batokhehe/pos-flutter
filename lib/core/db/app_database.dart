import 'package:drift/drift.dart';
import 'package:mvvm_flutter_boilerplate/core/db/tables/product_table.dart';
import '../../domain/daos/product_dao.dart';

import 'connection/connection_web.dart'
if (dart.library.io) 'connection/connection_native.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Products],
  daos: [ProductDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
