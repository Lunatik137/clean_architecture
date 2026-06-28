import '../models/product_model.dart';

/// Lớp ngoài cùng: giao tiếp với nguồn dữ liệu (API, DB, etc.)
class ProductApiDataSource {
  Future<List<ProductModel>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Giả lập network
    
    final List<Map<String, dynamic>> jsonResponse = [
      {'id': '1', 'name': 'iPhone 16', 'price': 999},
      {'id': '2', 'name': 'MacBook Pro', 'price': 2499},
    ];

    return jsonResponse.map((json) => ProductModel.fromJson(json)).toList();
  }
}
