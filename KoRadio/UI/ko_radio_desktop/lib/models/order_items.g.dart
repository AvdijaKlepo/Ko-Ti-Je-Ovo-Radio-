// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_items.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItems _$OrderItemsFromJson(Map<String, dynamic> json) => OrderItems(
      (json['orderItemsId'] as num).toInt(),
    )
      ..order = json['order'] == null
          ? null
          : Order.fromJson(json['order'] as Map<String, dynamic>)
      ..quantity = (json['quantity'] as num?)?.toInt()
      ..product = json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>)
      ..store = json['store'] == null
          ? null
          : Store.fromJson(json['store'] as Map<String, dynamic>);

Map<String, dynamic> _$OrderItemsToJson(OrderItems instance) =>
    <String, dynamic>{
      'orderItemsId': instance.orderItemsId,
      'order': instance.order,
      'quantity': instance.quantity,
      'product': instance.product,
      'store': instance.store,
    };
