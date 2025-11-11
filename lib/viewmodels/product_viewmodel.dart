import 'package:flutter/foundation.dart';
import '../../data/repositories/product_repository.dart';
import '../../domain/entities/product.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  List<Product> _products = [];

  List<Product> get products => _products;

  ProductViewModel(this._repository);

  Future<void> loadProducts() async {
    _products = await _repository.getAll();
    notifyListeners();
  }

  Future<void> addProduct(String name, double price) async {
    final product = Product(name: name, price: price);
    await _repository.insert(product);
    await loadProducts();
  }

  Future<void> updateProduct(int id, String name, double price) async {
    final product = Product(id: id, name: name, price: price);
    await _repository.update(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _repository.delete(id);
    await loadProducts();
  }
}
