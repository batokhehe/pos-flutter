import '../../core/db/app_database.dart';
import '../../domain/entities/product.dart';

class ProductRepository {
  final AppDatabase _db;

  ProductRepository(this._db);

  Future<List<Product>> getAll() async {
    final rows = await _db.productDao.getAllProducts();
    return rows.map(Product.fromDrift).toList();
  }

  Future<void> insert(Product product) async {
    await _db.productDao.insertProduct(product.toCompanion());
  }

  Future<void> update(Product product) async {
    await _db.productDao.updateProduct(product.toCompanion());
  }

  Future<void> delete(int id) async {
    await _db.productDao.deleteProduct(id);
  }
}
