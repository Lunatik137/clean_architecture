import 'package:flutter/foundation.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';
import 'product_presenter.dart';

class ProductController extends Controller {
  List<Product> products = [];
  bool isLoading = false;

  final ProductPresenter _presenter;

  ProductController(ProductRepository repository)
      : _presenter = ProductPresenter(repository),
        super();

  @override
  void initListeners() {
    _presenter.getProductsOnNext = (List<Product> productList) {
      products = productList;
      refreshUI();
    };

    _presenter.getProductsOnComplete = () {
      isLoading = false;
      refreshUI();
    };

    _presenter.getProductsOnError = (dynamic e) {
      isLoading = false;
      products = [];
      refreshUI();
      debugPrint('Error: $e');
    };
  }

  void loadProducts() {
    isLoading = true;
    refreshUI();
    _presenter.getProducts();
  }

  @override
  void onDisposed() {
    _presenter.dispose();
    super.onDisposed();
  }
}
