# 🏗️ Clean Architecture trong Flutter

> **Package**: `flutter_clean_architecture` v6.2.0 (pub.dev)
>
> **Tác giả gốc**: Robert C. Martin (Uncle Bob), 2012
>
> **Demo**: Product List – tải danh sách sản phẩm từ API giả lập

---

## Mục lục

1. [Vấn đề: Tại sao cần Clean Architecture?](#1-vấn-đề-tại-sao-cần-clean-architecture)
2. [Clean Architecture là gì?](#2-clean-architecture-là-gì)
3. [Dependency Rule](#3-dependency-rule)
4. [4 Module kiến trúc](#4-bốn-module-kiến-trúc)
5. [6 Components chính](#5-sáu-components-chính)
6. [Luồng dữ liệu (Data Flow)](#6-luồng-dữ-liệu)
7. [Presenter + Observer hoạt động như thế nào?](#7-presenter--observer-hoạt-động-như-thế-nào)
8. [Code demo chi tiết](#8-code-demo-chi-tiết)
9. [Dependency Injection](#9-dependency-injection)
10. [Cấu trúc thư mục](#10-cấu-trúc-thư-mục)
11. [Khi nào nên dùng?](#11-khi-nào-nên-dùng)
12. [3 điều mang về](#12-ba-điều-mang-về)
13. [Demo Script 3 phút](#13-demo-script-3-phút)
14. [Chạy project](#14-chạy-project)

---

## 1. Vấn đề: Tại sao cần Clean Architecture?

**(Slide 2 – "Spaghetti Code")**

Hầu hết dự án Flutter bắt đầu với code như thế này:

```dart
// ❌ Spaghetti Code – mọi thứ gộp trong View.build()
void build(BuildContext context) {
  setState(() async {
    final res = await http.get('api/products');
    _data = json.decode(res);
    if (_data['ok']) {
      // validate...
      // map model...
      // call another API
    }
  });
}
```

### Vấn đề phát sinh:

| Triệu chứng | Hậu quả |
|---|---|
| **Logic & UI lẫn lộn** | Business logic sống trong `View.build()` |
| **Không thể Unit Test** | API call trực tiếp từ View |
| **State Chaos** | `setState()` rải rác khắp nơi |
| **Tight Coupling** | Thêm feature → phá feature cũ |

**Kết quả**: Ứng dụng khó bảo trì, không thể test, team block nhau.

---

## 2. Clean Architecture là gì?

**(Slide 3 – "Before vs After" & Slide 4 – "Clean Architecture là gì?")**

Clean Architecture là kiến trúc do **Robert C. Martin (Uncle Bob)** đề xuất năm 2012, tập trung vào **tách biệt trách nhiệm** (separation of concerns) và **khả năng mở rộng** (scalability).

### Before vs After

| BEFORE ❌ | AFTER ✅ |
|---|---|
| Business logic trong `View.build()` | **View** – chỉ render, không có logic |
| API call trực tiếp từ View | **Controller** – điều khiển View, gọi Presenter |
| `setState` quản lý toàn bộ state | **Presenter** – chuẩn bị data, lắng nghe UseCase |
| Không có separation of concerns | **UseCase** – một hành động nghiệp vụ cụ thể |
| Không thể mock → không test được | **Repository** – abstract interface (Domain) |

### 3 đặc tính cốt lõi:

1. **Độc lập với Framework** – Domain không phụ thuộc Flutter, Dio, Hive hay bất kỳ thư viện UI nào
2. **Dễ kiểm thử** – Test business logic mà không cần View, Database hay Server
3. **Độc lập với View & DB** – Thay đổi giao diện hoặc database mà không sửa business logic

---

## 3. Dependency Rule

**(Slide 4 – "Dependency Rule")**

> **"Mọi phụ thuộc chỉ hướng vào trong – về phía Domain"**
>
> – Robert C. Martin (Uncle Bob), 2012

```
Domain → không biết App/Data/Device
App/Data/Device → phụ thuộc vào Domain
```

**Nghĩa là**:
- **Domain** (lớp trong cùng) – Pure Dart, không import bất kỳ thứ gì từ lớp ngoài
- **App/Data/Device** (lớp ngoài) – biết và phụ thuộc vào Domain

Trong code demo, bạn có thể xác nhận:

```
✗ Domain KHÔNG BAO GIỜ import Data hoặc App
✗ Data KHÔNG BAO GIỜ import App (Presentation)
✓ Mỗi Controller nên sở hữu một Presenter
```

---

## 4. Bốn module kiến trúc

**(Slide 5 – "Bốn module kiến trúc")**

Package `flutter_clean_architecture` chia ứng dụng thành 4 module:

```
┌─────────────────────────────────────────────────┐
│                    APP                          │
│         View · Controller · Presenter           │
│         Widgets · Navigator                     │
├─────────────────────────────────────────────────┤
│          DATA              │       DEVICE       │
│    Repository Impl         │  Repository Impl   │
│  DataSource (API/DB)       │  GPS, sensors,     │
│    Helpers                 │  storage...        │
├─────────────────────────────────────────────────┤
│                   DOMAIN                        │
│       Entity · UseCase · Repository Interface   │
│                  Pure Dart                       │
└─────────────────────────────────────────────────┘

       Phụ thuộc luôn hướng vào trong:
       App / Data / Device  →  Domain
```

| Module | Vai trò | Phụ thuộc |
|---|---|---|
| **Domain** | Business logic thuần Dart. Entity, UseCase, Repository interface | Không phụ thuộc ai |
| **App** | Presentation layer. View, Controller, Presenter | → Domain |
| **Data** | Triển khai data access. Repository Impl, DataSource, Model | → Domain |
| **Device** | Tương tác platform. GPS, sensors, local storage | → Domain |

---

## 5. Sáu Components chính

**(Slide 11 – "Vai trò từng thành phần")**

Package `flutter_clean_architecture` cung cấp 6 thành phần cốt lõi:

### ① View

**Định nghĩa**: `StatefulWidget` – page/screen. Chỉ render UI, được Controller điều khiển.

**Trong demo** → [product_view.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/app/pages/product_list/product_view.dart)

```dart
// 2 class: View (Widget) + ViewState (UI implementation)
class ProductListPage extends CleanView { ... }
class ProductListViewState extends CleanViewState<ProductListPage, ProductController> {
  // UI code ở đây - sử dụng ControlledWidgetBuilder để bind data
  @override
  Widget get view => Scaffold( ... );
}
```

### ② Controller

**Định nghĩa**: Gắn với View. Nhận user event, sở hữu Presenter, gọi `refreshUI()` khi cần.

**Trong demo** → [product_controller.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/app/pages/product_list/product_controller.dart)

```dart
class ProductController extends Controller {
  List<Product> products = [];
  bool isLoading = false;
  final ProductPresenter _presenter;

  // DI qua constructor
  ProductController(ProductRepository repository)
      : _presenter = ProductPresenter(repository), super();

  @override
  void initListeners() {
    _presenter.getProductsOnNext = (List<Product> productList) {
      products = productList;
      refreshUI();   // ← Rebuild View với data mới
    };
    _presenter.getProductsOnComplete = () {
      isLoading = false;
      refreshUI();
    };
    _presenter.getProductsOnError = (dynamic e) {
      isLoading = false;
      products = [];
      refreshUI();
    };
  }

  void loadProducts() {
    isLoading = true;
    refreshUI();
    _presenter.getProducts();  // ← Gọi Presenter, KHÔNG gọi UseCase
  }
}
```

### ③ Presenter

**Định nghĩa**: Chuẩn bị data cho Controller, tạo & quản lý lifecycle UseCase, dispose khi xong.

**Trong demo** → [product_presenter.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/app/pages/product_list/product_presenter.dart)

```dart
class ProductPresenter extends Presenter {
  late Function(List<Product>) getProductsOnNext;   // Callback từ Controller
  late Function getProductsOnComplete;
  late Function(dynamic) getProductsOnError;
  final GetProductsUseCase _getProductsUseCase;

  // DI qua constructor
  ProductPresenter(ProductRepository repo)
      : _getProductsUseCase = GetProductsUseCase(repo);

  void getProducts() {
    _getProductsUseCase.execute(
      _GetProductsObserver(this),   // ← Tạo Observer, execute UseCase
    );
  }

  @override
  void dispose() => _getProductsUseCase.dispose();
}
```

### ④ Observer

**Định nghĩa**: Nhận kết quả từ UseCase qua `onNext` / `onComplete` / `onError`, gọi callback tương ứng trên Presenter.

**Trong demo** → [product_presenter.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/app/pages/product_list/product_presenter.dart) (cùng file với Presenter)

```dart
class _GetProductsObserver extends Observer<List<Product>> {
  final ProductPresenter _presenter;
  _GetProductsObserver(this._presenter);

  @override
  void onNext(List<Product>? products) {
    if (products != null) {
      _presenter.getProductsOnNext(products);   // ← Forward data lên Controller
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
```

> **Tại sao không dùng inner class?**
> Dart không hỗ trợ inner class. Observer được viết thành private class `_GetProductsObserver` trong cùng file với Presenter.

### ⑤ UseCase

**Định nghĩa**: Một hành động nghiệp vụ cụ thể (`buildUseCaseStream`). Nhận Repository qua constructor.

**Trong demo** → [get_products_usecase.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/domain/usecases/get_products_usecase.dart)

```dart
class GetProductsUseCase extends UseCase<List<Product>, void> {
  final ProductRepository _productRepository;

  GetProductsUseCase(this._productRepository);  // ← DI: Repository inject vào

  @override
  Future<Stream<List<Product>?>> buildUseCaseStream(void params) async {
    final StreamController<List<Product>> controller = StreamController();
    try {
      final products = await _productRepository.getProducts();
      controller.add(products);    // ← Emit data → Observer.onNext()
      controller.close();          // ← Đóng stream → Observer.onComplete()
    } catch (e) {
      controller.addError(e);      // ← Gửi lỗi → Observer.onError()
    }
    return controller.stream;
  }
}
```

### ⑥ Repository

**Định nghĩa**: Abstract interface định nghĩa ở Domain. Hợp đồng, không biết implementation.

**Interface (Domain)** → [product_repository.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/domain/repositories/product_repository.dart)

```dart
// Domain layer – Pure Dart, không biết Data layer
abstract class ProductRepository {
  Future<List<Product>> getProducts();
}
```

**Implementation (Data)** → [product_repository_impl.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/data/repositories/product_repository_impl.dart)

```dart
// Data layer – implements interface từ Domain
class ProductRepositoryImpl implements ProductRepository {
  final ProductApiDataSource _dataSource;
  ProductRepositoryImpl(this._dataSource);

  @override
  Future<List<Product>> getProducts() async {
    final products = await _dataSource.getProducts();
    return products;  // ProductModel (Data) → Product (Domain) qua polymorphism
  }
}
```

**DataSource (Data/Device)**: Truy xuất API / DB / sensors thực tế, triển khai Repository interface.

**Trong demo** → [product_api_data_source.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/data/datasources/product_api_data_source.dart)

```dart
class ProductApiDataSource {
  Future<List<ProductModel>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));  // Giả lập network
    final jsonResponse = [
      {'id': '1', 'name': 'iPhone 16', 'price': 999},
      {'id': '2', 'name': 'MacBook Pro', 'price': 2499},
    ];
    return jsonResponse.map((json) => ProductModel.fromJson(json)).toList();
  }
}
```

---

## 6. Luồng dữ liệu

**(Slide 6 – "Luồng dữ liệu" & Slide 10 – "Demo: Product List Feature")**

Clean Architecture sử dụng luồng **Unidirectional** (một chiều) kết hợp **Observer pattern**.

### Request Flow (User → Data)

```
 ① VIEW                  User nhấn "Load Products"
    ↓                    controller.loadProducts()
 ② CONTROLLER            Nhận event, gọi Presenter
    ↓                    _presenter.getProducts()
 ③ PRESENTER             Tạo Observer, execute UseCase
    ↓                    _useCase.execute(_GetProductsObserver(this))
 ④ USE CASE              Business logic chạy
    ↓                    _productRepository.getProducts()
 ⑤ REPOSITORY            Interface → Implementation
    ↓                    _dataSource.getProducts()
 ⑥ DATA SOURCE           HTTP / JSON (giả lập 500ms)
```

### Response Flow (Data → User)

```
 ⑥ DATA SOURCE           Trả về List<ProductModel>
    ↓
 ⑤ REPOSITORY            Trả về List<Product> (polymorphism)
    ↓
 ④ USE CASE              controller.add(products) → controller.close()
    ↓
 ③ OBSERVER              onNext(products) được gọi
    ↓
 ② PRESENTER             getProductsOnNext callback → Controller
    ↓
 ① CONTROLLER            products = data; refreshUI()
    ↓
    VIEW                  Re-renders với data mới
```

### Ý nghĩa trong demo:

> API thay đổi REST → GraphQL: **chỉ sửa DataSource**.
> UseCase / Presenter / Controller / View – **KHÔNG thay đổi**.

---

## 7. Presenter + Observer hoạt động như thế nào?

**(Slide 7 – "Presenter + Observer" & Slide 8 – "Presenter + Controller Code" & Slide 9 – "Observer – Cầu nối UseCase & Presenter")**

Đây là trái tim của kiến trúc. Controller **KHÔNG gọi UseCase trực tiếp**. Presenter đóng vai trò trung gian.

### Sơ đồ chi tiết:

```
① VIEW              User tap button
       ↓             → controller.loadProducts()
② CONTROLLER        Gọi presenter.getProducts()
       ↓
③ PRESENTER         Tạo Observer, execute UseCase
       ↓             → _useCase.execute(_GetProductsObserver(this))
④ UseCase.execute() Chạy business logic (buildUseCaseStream)
       ↓
⑤ Observer.onNext() Nhận kết quả từ UseCase stream
       ↓
⑥ PRESENTER         Gọi callback → getProductsOnNext(products)
    callback
       ↓
⑦ CONTROLLER        products = data; refreshUI()
    → VIEW           View re-renders
```

### Observer – 4 methods quan trọng:

| Method | Khi nào được gọi | Trong UseCase |
|---|---|---|
| `buildUseCaseStream()` | Khi `execute(observer)` được gọi | Chạy business logic, tạo Stream |
| `onNext(data)` | Stream emit dữ liệu (`controller.add()`) | Nhận `List<Product>` |
| `onComplete()` | Stream đóng thành công (`controller.close()`) | Báo hoàn thành |
| `onError(e)` | Stream gặp lỗi (`controller.addError()`) | Xử lý exception |

### Tại sao cần Observer thay vì gọi trực tiếp?

1. **Bất đồng bộ**: UseCase trả về Stream, Observer lắng nghe kết quả
2. **Tách biệt**: Controller không biết UseCase tồn tại
3. **Linh hoạt**: Một UseCase có thể emit nhiều lần (real-time data)
4. **Testable**: Mock Observer dễ dàng trong unit test

---

## 8. Code demo chi tiết

### Entity (Domain Layer)

**File**: [product.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/domain/entities/product.dart)

```dart
/// Pure Dart – không import Flutter
class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});
}
```

**Tại sao Entity nằm ở Domain?**
- Entity là business object cốt lõi, ít thay đổi nhất
- Pure Dart: không phụ thuộc Flutter, có thể dùng cho web, server
- Các layer khác đều sử dụng Entity này

### Model (Data Layer)

**File**: [product_model.dart](file:///d:/PRM393/Project/clean_architecture/lib/src/data/models/product_model.dart)

```dart
class ProductModel extends Product {
  ProductModel({required super.id, required super.name, required super.price});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}
```

**Tại sao Model tách khỏi Entity?**
- Entity (Domain) không biết JSON – nó là business object thuần
- Model (Data) biết cách parse JSON – nó là data transfer object
- Nếu API thay đổi format, chỉ sửa Model, Entity không bị ảnh hưởng

---

## 9. Dependency Injection

**(Slide 8 – "Dependency Injection")**

DI chain bắt đầu từ View (lớp ngoài cùng) và truyền vào trong:

```dart
// product_view.dart – DI chain hoàn chỉnh
ProductListViewState() : super(
  ProductController(                    // ← App layer
    ProductRepositoryImpl(              // ← Data layer (implements Domain interface)
      ProductApiDataSource(),           // ← Data layer (nguồn dữ liệu)
    ),
  ),
);
```

### Chuỗi DI qua các layer:

```
View  ─────────────────→  Controller
                               │
                               │  repository (constructor param)
                               ↓
                          Presenter
                               │
                               │  repository → UseCase (constructor param)
                               ↓
                          GetProductsUseCase
                               │
                               │  _productRepository.getProducts()
                               ↓
                     ProductRepository (abstract)
                               │
                               │  polymorphism
                               ↓
                    ProductRepositoryImpl
                               │
                               │  _dataSource.getProducts()
                               ↓
                     ProductApiDataSource
```

| Inject cái gì | Inject ở đâu | Ai inject |
|---|---|---|
| `ProductApiDataSource` | `ProductRepositoryImpl` constructor | `ProductListViewState` |
| `ProductRepository` (impl) | `ProductController` constructor | `ProductListViewState` |
| `ProductRepository` | `ProductPresenter` → `GetProductsUseCase` | `ProductController` |

**Nguyên tắc**: Lớp ngoài cung cấp implementation, lớp trong chỉ biết interface.

---

## 10. Cấu trúc thư mục

**(Slide 12 – "Cấu trúc thư mục")**

> "Nhìn vào folder là biết architecture"

```
lib/
├── main.dart                                    ← Entry point
└── src/
    ├── app/                                     ← APP LAYER (Presentation)
    │   ├── pages/
    │   │   └── product_list/
    │   │       ├── product_view.dart            ← View (CleanView + CleanViewState)
    │   │       ├── product_controller.dart      ← Controller (state + events + refreshUI)
    │   │       └── product_presenter.dart       ← Presenter + _GetProductsObserver
    │   ├── widgets/                             ← Reusable UI components
    │   ├── utils/                               ← Utility functions
    │   └── navigator.dart                       ← Navigation config
    │
    ├── data/                                    ← DATA LAYER (Implementation)
    │   ├── datasources/
    │   │   └── product_api_data_source.dart     ← API giả lập (HTTP/JSON)
    │   ├── models/
    │   │   └── product_model.dart               ← Extends Entity + fromJson()
    │   ├── repositories/
    │   │   └── product_repository_impl.dart     ← Implements Domain interface
    │   ├── helpers/                             ← HTTP helpers, etc.
    │   └── constants.dart                       ← API keys, URLs
    │
    ├── device/                                  ← DEVICE LAYER (Platform)
    │   ├── repositories/                        ← GPS, sensors, local storage
    │   └── utils/
    │
    └── domain/                                  ← DOMAIN LAYER (Business Logic)
        ├── entities/
        │   └── product.dart                     ← Business object – Pure Dart
        ├── repositories/
        │   └── product_repository.dart          ← Abstract interface (contract)
        └── usecases/
            └── get_products_usecase.dart         ← Business rule (buildUseCaseStream)
```

### Quy tắc import:

```
✗  Domain KHÔNG BAO GIỜ import Data hoặc App
✗  Data KHÔNG BAO GIỜ import App (Presentation)
✓  Mỗi Controller sở hữu một Presenter
```

### CLI tự động tạo page:

```bash
flutter pub run flutter_clean_architecture:cli create --page <feature>
```

---

## 11. Khi nào nên dùng?

**(Slide 13 – "Khi nào nên dùng?")**

> Clean Architecture **không phải** "silver bullet"

### ✅ NÊN DÙNG

| Tình huống | Lý do |
|---|---|
| Dự án lớn, phát triển dài hạn | Dễ bảo trì, tìm và sửa lỗi cực nhanh |
| Đội ngũ từ 3 người trở lên | Phân chia trách nhiệm rõ ràng |
| Cần Unit Test đầy đủ | Mock Repository ở bất kỳ layer nào |
| Business logic phức tạp | UseCase tách biệt, dễ kiểm soát |

### ⚠️ CÂN NHẮC

| Tình huống | Lý do |
|---|---|
| App nhỏ, vài màn hình đơn giản | Boilerplate quá nhiều (View + Controller + Presenter mỗi feature) |
| MVP cần tốc độ tối đa | Overhead ban đầu cao |
| Đội 1–2 người, ưu tiên shipping | Có thể dùng pattern đơn giản hơn |
| Side-project ngắn hạn | Không cần kiến trúc phức tạp |

### Trade-off:

| Ưu điểm | Nhược điểm |
|---|---|
| Dễ bảo trì | Boilerplate nhiều |
| Test dễ dàng | View + Controller + Presenter mỗi feature |
| Tìm sửa lỗi nhanh | Learning curve ban đầu |

---

## 12. Ba điều mang về

**(Slide 14 – "3 điều mang về hôm nay")**

### 01 – Dependency Rule

> App / Data / Device đều phụ thuộc Domain. Domain không phụ thuộc ai – Pure Dart.

**Trong code**: `product_repository.dart` (Domain) không import bất kỳ file nào từ Data hay App.

### 02 – Domain là bất khả xâm phạm

> Pure Dart. Không Flutter. Không Dio. Chỉ: Entity, UseCase, Repository interface.

**Trong code**: Toàn bộ folder `domain/` không có `import 'package:flutter/...'`.

### 03 – Presenter + Observer tách rời UI khỏi UseCase

> Controller không gọi UseCase trực tiếp. Observer trả kết quả `onNext` → Presenter → `Controller.refreshUI()`.

**Trong code**: `ProductController.loadProducts()` chỉ gọi `_presenter.getProducts()`, không biết `GetProductsUseCase` tồn tại.

---

## 13. Demo Script 3 phút

**(Kịch bản trình bày trước khán giả)**

### Bước 1 – Folder Structure (30s)
- **Mở**: IDE sidebar hiện cây thư mục `lib/src/`
- **Nói**: *"Đây là cấu trúc 4 layer: Domain (lõi, Pure Dart), Data (implementation), App (UI), Device (platform). Dependency luôn hướng vào trong – Domain không biết ai."*

### Bước 2 – Domain Layer (30s)
- **Mở lần lượt**: `product.dart` → `product_repository.dart` → `get_products_usecase.dart`
- **Nói**: *"Domain chỉ chứa Dart thuần. Entity Product – business object. Repository – abstract interface, chỉ là hợp đồng. UseCase nhận Repository qua constructor – Dependency Inversion."*

### Bước 3 – Data Layer (30s)
- **Mở lần lượt**: `product_model.dart` → `product_api_data_source.dart` → `product_repository_impl.dart`
- **Nói**: *"Data layer implement repository interface từ Domain. Model extends Entity thêm fromJson. DataSource giả lập API call. RepositoryImpl kết nối DataSource với Domain. Nếu API đổi từ REST sang GraphQL – chỉ sửa DataSource."*

### Bước 4 – Controller & Presenter (40s)
- **Mở**: `product_controller.dart` → `product_presenter.dart`
- **Nói**: *"Đây là điểm mấu chốt. Controller KHÔNG gọi UseCase trực tiếp. Controller gọi Presenter, Presenter tạo Observer rồi execute UseCase. Khi UseCase trả kết quả, Observer.onNext() nhận data, forward qua Presenter callback, rồi Controller gọi refreshUI() để cập nhật View."*

### Bước 5 – View (20s)
- **Mở**: `product_view.dart`, chỉ vào constructor
- **Nói**: *"View chỉ biết Controller. DI chain bắt đầu từ đây – Controller nhận RepositoryImpl nhận DataSource. ControlledWidgetBuilder bind data từ Controller."*

### Bước 6 – Run App (30s)
- **Chạy app**, nhấn **"Load Products"**, chờ 500ms, 2 sản phẩm hiện
- **Nói**: *"Khi nhấn nút, luồng đi: View → Controller → Presenter → UseCase → Repository → DataSource. Kết quả trả ngược: DataSource → Repository → UseCase stream → Observer.onNext() → Presenter callback → Controller.refreshUI() → View rebuild."*

### Bước 7 – Tổng kết (10s)
- **Nói**: *"3 điều mang về: Dependency Rule – hướng vào Domain. Domain bất khả xâm phạm – Pure Dart. Presenter + Observer tách UI khỏi UseCase."*

---

## 14. Chạy project

```bash
# Cài dependencies
flutter pub get

# Chạy app
flutter run

# Kiểm tra code quality
flutter analyze
```

### API giả lập

```
GET /products

Response:
[
  {"id": "1", "name": "iPhone 16", "price": 999},
  {"id": "2", "name": "MacBook Pro", "price": 2499}
]
```

Nhấn **"Load Products"** → loading 500ms → hiện 2 sản phẩm.

---

## Tham khảo

- [flutter_clean_architecture – pub.dev](https://pub.dev/packages/flutter_clean_architecture)
- [Uncle Bob – The Clean Architecture (2012)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- Slide: `Clean_Architecture_Flutter_Conference.pptx`
