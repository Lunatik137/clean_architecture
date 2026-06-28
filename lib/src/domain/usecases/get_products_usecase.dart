import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// GetProductsUseCase – Domain Layer
///
/// Application-specific business rule.
/// Extends `UseCase<List<Product>, void>` từ package:
///   - `List<Product>`: kiểu dữ liệu trả về qua Stream
///   - void: không cần tham số đầu vào
///
/// Luồng:
///   Presenter gọi execute(observer) →
///   buildUseCaseStream() chạy →
///   Repository.getProducts() →
///   Kết quả add vào StreamController →
///   Observer nhận qua onNext()
class GetProductsUseCase extends UseCase<List<Product>, void> {
  final ProductRepository _productRepository;

  /// Repository được inject qua constructor (Dependency Inversion)
  GetProductsUseCase(this._productRepository);

  @override
  Future<Stream<List<Product>?>> buildUseCaseStream(void params) async {
    final StreamController<List<Product>> controller = StreamController();
    try {
      // Gọi repository (abstract) – không biết implementation
      final List<Product> products = await _productRepository.getProducts();

      // Add data vào stream → trigger Observer.onNext()
      controller.add(products);
      logger.finest('GetProductsUseCase successful.');

      // Đóng stream → trigger Observer.onComplete()
      controller.close();
    } catch (e) {
      logger.severe('GetProductsUseCase unsuccessful.');
      // Gửi lỗi vào stream → trigger Observer.onError()
      controller.addError(e);
    }
    return controller.stream;
  }
}
