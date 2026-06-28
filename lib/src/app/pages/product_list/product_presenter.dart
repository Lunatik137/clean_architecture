import 'package:flutter_clean_architecture/flutter_clean_architecture.dart'
    as clean;

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/get_products_usecase.dart';

/// Lớp trung gian kết nối Controller với UseCase.
class ProductPresenter extends clean.Presenter {
  late Function(List<Product>) getProductsOnNext;
  late Function getProductsOnComplete;
  late Function(dynamic) getProductsOnError;

  final GetProductsUseCase _getProductsUseCase;

  ProductPresenter(ProductRepository repository)
      : _getProductsUseCase = GetProductsUseCase(repository);

  void getProducts() {
    _getProductsUseCase.execute(_GetProductsObserver(this));
  }

  @override
  void dispose() {
    _getProductsUseCase.dispose();
  }
}

/// Bắt kết quả từ UseCase stream và forward qua Presenter callbacks.
class _GetProductsObserver extends clean.Observer<List<Product>> {
  final ProductPresenter _presenter;

  _GetProductsObserver(this._presenter);

  @override
  void onNext(List<Product>? products) {
    if (products != null) {
      _presenter.getProductsOnNext(products);
    }
  }

  @override
  void onComplete() {
    _presenter.getProductsOnComplete();
  }

  @override
  void onError(dynamic e) {
    _presenter.getProductsOnError(e);
  }
}
