import '../../domain/entities/product.dart';

/// ProductModel – Data Layer
///
/// Extends Product Entity, thêm khả năng parse JSON.
/// Model thuộc Data layer vì nó biết format dữ liệu cụ thể (JSON).
/// Entity thuộc Domain – không biết JSON là gì.
class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.price,
  });

  /// Factory constructor: JSON Map → ProductModel object
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}
