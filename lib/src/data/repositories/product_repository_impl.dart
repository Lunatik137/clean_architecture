import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_api_data_source.dart';

/// Implements ProductRepository interface từ Domain layer.
class ProductRepositoryImpl implements ProductRepository {
  final ProductApiDataSource _dataSource;

  ProductRepositoryImpl(this._dataSource);

  @override
  Future<List<Product>> getProducts() async {
    return await _dataSource.getProducts();
  }
}
