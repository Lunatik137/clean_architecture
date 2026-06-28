import 'package:flutter/foundation.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';
import 'product_presenter.dart';

/// ProductController – App Layer
///
/// Mỗi View có 1 Controller. Controller:
///   1. Giữ state (products, isLoading) cho View
///   2. Xử lý events từ View (loadProducts)
///   3. Quản lý Presenter lifecycle
///   4. GỌI refreshUI() để rebuild View
///
/// QUAN TRỌNG:
///   - Controller KHÔNG gọi Repository
///   - Controller KHÔNG gọi UseCase
///   - Controller chỉ gọi Presenter
///   - Presenter là cầu nối duy nhất đến business logic
class ProductController extends Controller {
  /// State data – View đọc từ đây qua ControlledWidgetBuilder
  List<Product> products = [];
  bool isLoading = false;

  /// Presenter – cầu nối đến UseCase layer
  final ProductPresenter _presenter;

  /// Constructor: Repository inject vào → truyền cho Presenter
  /// DI chain: View → Controller(repo) → Presenter(repo) → UseCase(repo)
  ProductController(ProductRepository repository)
      : _presenter = ProductPresenter(repository),
        super();

  /// BẮT BUỘC override – Khởi tạo listeners cho Presenter
  ///
  /// Đây là nơi Controller "đăng ký" nhận kết quả từ UseCase
  /// thông qua callback functions của Presenter.
  ///
  /// Luồng: UseCase stream → Observer → Presenter callback → Controller method
  @override
  void initListeners() {
    // Khi UseCase stream emit data (List<Product>)
    _presenter.getProductsOnNext = (List<Product> productList) {
      products = productList;
      refreshUI(); // Rebuild View với data mới
    };

    // Khi UseCase stream hoàn tất
    _presenter.getProductsOnComplete = () {
      isLoading = false;
      refreshUI(); // Ẩn loading indicator
    };

    // Khi UseCase stream gặp lỗi
    _presenter.getProductsOnError = (dynamic e) {
      isLoading = false;
      products = [];
      refreshUI();
      debugPrint('Error: $e'); // Trong production, hiện dialog/snackbar
    };
  }

  /// Được gọi khi user nhấn "Load Products" trên View
  ///
  /// Controller chỉ:
  ///   1. Set loading state
  ///   2. Gọi Presenter (KHÔNG gọi UseCase/Repository trực tiếp)
  ///   3. refreshUI() để hiện loading indicator
  void loadProducts() {
    isLoading = true;
    refreshUI();

    // Gọi Presenter → Presenter gọi UseCase → UseCase gọi Repository
    _presenter.getProducts();
  }

  /// Cleanup khi Controller bị dispose
  @override
  void onDisposed() {
    _presenter.dispose();
    super.onDisposed();
  }
}
