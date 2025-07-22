import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/order_items.dart';
import 'package:ko_radio_desktop/models/products_services.dart';
import 'package:ko_radio_desktop/models/store.dart';
part 'product.g.dart';

@JsonSerializable()
class Product {
  int productId;
  String? productName;
  String? productDescription;
  double? price;
  bool? isDeleted;
  String? image;
  Store? store;
  List<OrderItems>? orderItems;
  List<ProductsServices>? productsServices;

  Product({
    required this.productId,
    
  });
  
 factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

