import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';

class Product {
  final int? id;
  final String name;
  final double price;

  Product({
    this.id,
    required this.name,
    required this.price,
  });

  factory Product.fromDrift(ProductData data) {
    return Product(
      id: data.id,
      name: data.name,
      price: data.price,
    );
  }

  ProductsCompanion toCompanion() {
    return ProductsCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      name: Value(name),
      price: Value(price),
    );
  }
}
