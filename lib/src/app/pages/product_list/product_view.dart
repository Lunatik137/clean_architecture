import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../data/datasources/product_api_data_source.dart';
import '../../../data/repositories/product_repository_impl.dart';
import 'product_controller.dart';

/// ProductListPage – App Layer (View)
///
/// View gồm 2 class:
///   1. ProductListPage (extends CleanView) – Widget gốc, nơi inject dependencies
///   2. ProductListViewState (extends CleanViewState) – UI implementation
///
/// View chỉ biết Controller, không biết Presenter/UseCase/Repository.
class ProductListPage extends CleanView {
  const ProductListPage({super.key});

  /// DI bắt đầu từ đây:
  ///   ProductController(
  ///     ProductRepositoryImpl(    ← Data layer implementation
  ///       ProductApiDataSource()  ← Data layer data source
  ///     )
  ///   )
  @override
  State<StatefulWidget> createState() => ProductListViewState();
}

/// ViewState – UI implementation
///
/// Constructor inject Controller với đầy đủ dependency chain.
/// View sử dụng ControlledWidgetBuilder để bind data từ Controller.
class ProductListViewState
    extends CleanViewState<ProductListPage, ProductController> {
  /// DI Chain hoàn chỉnh:
  ///   View → Controller → Presenter → UseCase → Repository → DataSource
  ProductListViewState()
      : super(
          ProductController(
            ProductRepositoryImpl(
              ProductApiDataSource(),
            ),
          ),
        );

  @override
  Widget get view => Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: const Text('🏗️ Clean Architecture Demo'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: Column(
          children: [
            // ===== Header Card =====
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'Product List',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'View → Controller → Presenter → UseCase → Repository → DataSource',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ===== Load Button =====
            // ControlledWidgetBuilder binds Controller data to Widget
            ControlledWidgetBuilder<ProductController>(
              builder: (context, controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.isLoading ? null : controller.loadProducts,
                      icon: controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_download),
                      label: Text(
                        controller.isLoading
                            ? 'Đang tải...'
                            : '📡 Load Products',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ===== Product List =====
            Expanded(
              child: ControlledWidgetBuilder<ProductController>(
                builder: (context, controller) {
                  if (controller.products.isEmpty && !controller.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nhấn "Load Products" để tải dữ liệu',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Luồng: Controller → Presenter → UseCase → Repository → DataSource',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.devices,
                              color: Colors.deepPurple,
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${product.id}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '\$${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ===== Footer =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: const Text(
                '🔄 Response: DataSource → Repository → UseCase → Observer.onNext() → Presenter → Controller.refreshUI() → View',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
}
