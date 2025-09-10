import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/order_items.dart';
import 'package:ko_radio_desktop/models/user.dart';


part 'order.g.dart';

@JsonSerializable()
class Order {
  int orderId;
  int? orderNumber;
  User? user;
  bool? isCancelled;
  bool? isShipped;
  double? price;
  DateTime? createdAt;
  List<OrderItems>? orderItems;

  Order(this.orderId);

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
  
}