import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/order.dart';

import 'package:ko_radio_desktop/models/product.dart';
import 'package:ko_radio_desktop/models/store.dart';

part 'order_items.g.dart';

@JsonSerializable()
class OrderItems {
  int orderItemsId;
  Order? order;
  int? quantity;

  Product? product;
  Store? store;

  OrderItems(this.orderItemsId);

  factory OrderItems.fromJson(Map<String, dynamic> json) => _$OrderItemsFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemsToJson(this);

}