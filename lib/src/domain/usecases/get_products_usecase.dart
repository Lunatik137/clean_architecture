import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase extends UseCase<List<Product>, void> {
  final ProductRepository _productRepository;

  GetProductsUseCase(this._productRepository);

  @override
  Future<Stream<List<Product>?>> buildUseCaseStream(void params) async {
    final StreamController<List<Product>> controller = StreamController();
    try {
      final List<Product> products = await _productRepository.getProducts();
      controller.add(products);
      logger.finest('GetProductsUseCase successful.');
      controller.close();
    } catch (e) {
      logger.severe('GetProductsUseCase unsuccessful.');
      controller.addError(e);
    }
    return controller.stream;
  }
}
