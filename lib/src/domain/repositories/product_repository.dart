import '../entities/product.dart';

/// ProductRepository – Domain Layer
///
/// Abstract class định nghĩa contract cho Data layer.
/// Domain KHÔNG biết implementation cụ thể (Dependency Rule).
/// UseCase chỉ phụ thuộc vào interface này.
abstract class ProductRepository {
  /// Lấy danh sách tất cả sản phẩm
  Future<List<Product>> getProducts();
}
