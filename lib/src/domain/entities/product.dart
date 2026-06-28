/// Product Entity – Domain Layer
///
/// Enterprise-wide business object. Pure Dart – không import Flutter.
/// Đây là lớp trong cùng của Clean Architecture.
class Product {
  final String id;
  final String name;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.price,
  });
}
