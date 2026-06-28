import '../models/product_model.dart';

/// ProductApiDataSource – Data Layer
///
/// Lớp ngoài cùng: giao tiếp trực tiếp với nguồn dữ liệu (API, DB, etc.)
/// Ở demo này, giả lập API call với Future.delayed 500ms.
///
/// Trong production, đây sẽ là nơi gọi HTTP request thực tế:
///   final response = await http.get(Uri.parse('https://api.example.com/products'));
class ProductApiDataSource {
  /// Giả lập: GET /products
  ///
  /// Response giả lập:
  /// ```json
  /// [
  ///   {"id": "1", "name": "iPhone 16", "price": 999},
  ///   {"id": "2", "name": "MacBook Pro", "price": 2499}
  /// ]
  /// ```
  Future<List<ProductModel>> getProducts() async {
    // Giả lập network delay 500ms
    await Future.delayed(const Duration(milliseconds: 500));

    // Giả lập JSON response từ API
    final List<Map<String, dynamic>> jsonResponse = [
      {'id': '1', 'name': 'iPhone 16', 'price': 999},
      {'id': '2', 'name': 'MacBook Pro', 'price': 2499},
    ];

    // Parse JSON → ProductModel objects
    return jsonResponse.map((json) => ProductModel.fromJson(json)).toList();
  }
}
