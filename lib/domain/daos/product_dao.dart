import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/tables/product_table.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(AppDatabase db) : super(db);

  Future<List<ProductData>> getAllProducts() => select(products).get();
  Future<int> insertProduct(ProductsCompanion entry) => into(products).insert(entry);
  Future<bool> updateProduct(ProductsCompanion entry) => update(products).replace(entry);
  Future<int> deleteProduct(int id) =>
      (delete(products)..where((t) => t.id.equals(id))).go();
}