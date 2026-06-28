import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_api_data_source.dart';

/// ProductRepositoryImpl – Data Layer
///
/// Implements ProductRepository interface từ Domain layer.
/// Đây là nơi Dependency Inversion xảy ra:
///   - Domain định nghĩa interface (ProductRepository)
///   - Data cung cấp implementation (ProductRepositoryImpl)
///   - UseCase chỉ biết interface, không biết class này
///
/// Repository pattern: trung gian giữa UseCase và DataSource.
class ProductRepositoryImpl implements ProductRepository {
  final ProductApiDataSource _dataSource;

  /// DataSource được inject qua constructor
  ProductRepositoryImpl(this._dataSource);

  @override
  Future<List<Product>> getProducts() async {
    // Gọi DataSource (lớp ngoài cùng)
    // Trả về List<ProductModel> nhưng cast thành List<Product> (polymorphism)
    final products = await _dataSource.getProducts();
    return products;
  }
}
