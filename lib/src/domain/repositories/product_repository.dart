import '../entities/product.dart';

/// Abstract contract cho Data layer.
abstract class ProductRepository {
  Future<List<Product>> getProducts();
}
