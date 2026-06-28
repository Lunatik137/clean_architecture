import 'package:flutter_clean_architecture/flutter_clean_architecture.dart'
    as clean;

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/get_products_usecase.dart';

/// ProductPresenter – App Layer
///
/// Lớp trung gian giữa Controller và UseCase.
/// Controller KHÔNG gọi UseCase trực tiếp – phải thông qua Presenter.
///
/// Presenter chứa:
///   1. UseCase instance
///   2. Callback functions (được Controller set trong initListeners)
///   3. Method để trigger UseCase execution
///
/// Luồng Request:
///   Controller.loadProducts() → Presenter.getProducts() → UseCase.execute(observer)
///
/// Luồng Response:
///   UseCase stream → Observer.onNext() → Presenter callback → Controller.refreshUI()
class ProductPresenter extends clean.Presenter {
  /// Callback functions – được set bởi Controller trong initListeners()
  late Function(List<Product>) getProductsOnNext;
  late Function getProductsOnComplete;
  late Function(dynamic) getProductsOnError;

  /// UseCase – nhận Repository qua constructor (DI chain)
  final GetProductsUseCase _getProductsUseCase;

  /// Constructor: Repository inject vào → truyền cho UseCase
  ProductPresenter(ProductRepository repository)
      : _getProductsUseCase = GetProductsUseCase(repository);

  /// Được gọi bởi Controller khi user nhấn "Load Products"
  ///
  /// Tạo Observer và execute UseCase.
  /// Observer sẽ nhận kết quả bất đồng bộ từ UseCase stream.
  void getProducts() {
    _getProductsUseCase.execute(
      _GetProductsObserver(this),
    );
  }

  /// Dispose tất cả UseCase để tránh memory leak
  @override
  void dispose() {
    _getProductsUseCase.dispose();
  }
}

/// _GetProductsObserver – Observer Pattern
///
/// Implements `Observer<List<Product>>` từ package.
/// Dart không hỗ trợ inner class, nên tạo private class riêng.
///
/// 3 methods đại diện cho tất cả output có thể của UseCase:
///   - onNext(data)    → Stream emit dữ liệu
///   - onComplete()    → Stream đóng thành công
///   - onError(e)      → Stream gặp lỗi
///
/// Observer giữ reference đến Presenter để gọi callback.
class _GetProductsObserver extends clean.Observer<List<Product>> {
  final ProductPresenter _presenter;

  _GetProductsObserver(this._presenter);

  /// Được gọi khi UseCase stream emit dữ liệu (`List<Product>`)
  /// → Forward đến Controller thông qua Presenter callback
  @override
  void onNext(List<Product>? products) {
    if (products != null) {
      _presenter.getProductsOnNext(products);
    }
  }

  /// Được gọi khi UseCase stream đóng thành công
  /// → Báo Controller biết quá trình hoàn tất
  @override
  void onComplete() {
    _presenter.getProductsOnComplete();
  }

  /// Được gọi khi UseCase stream gặp lỗi
  /// → Forward lỗi đến Controller để xử lý
  @override
  void onError(dynamic e) {
    _presenter.getProductsOnError(e);
  }
}
