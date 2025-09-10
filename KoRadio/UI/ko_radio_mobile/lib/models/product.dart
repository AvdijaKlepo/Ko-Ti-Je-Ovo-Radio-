import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/products_service.dart';
import 'package:ko_radio_mobile/models/store.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  int productId;
  String? productName;
  String? productDescription;
  double? price;
  int? stockQuantity;
  bool? isOnSale;
  double? salePrice;
  bool? isOutOfStock;
  DateTime? saleExpires;
  bool? isDeleted;
  String? image;
  int? storeId;
  Store? store;
  List<ProductsServices>? productsServices;

  Product({
    required this.productId,
    
  });
  
 factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

