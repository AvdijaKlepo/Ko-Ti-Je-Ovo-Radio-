import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/order.dart';
import 'package:ko_radio_mobile/models/product.dart';
import 'package:ko_radio_mobile/models/store.dart';

part 'order_items.g.dart';

@JsonSerializable()
class OrderItems {
  int orderItemsId;
  int? quantity;
  Order? order;
  Product? product;
  Store? store;

  OrderItems(this.orderItemsId);

  factory OrderItems.fromJson(Map<String, dynamic> json) => _$OrderItemsFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemsToJson(this);

}