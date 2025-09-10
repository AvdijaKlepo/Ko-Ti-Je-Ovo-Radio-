// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      (json['orderId'] as num).toInt(),
    )
      ..orderNumber = (json['orderNumber'] as num?)?.toInt()
      ..user = json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>)
      ..isCancelled = json['isCancelled'] as bool?
      ..isShipped = json['isShipped'] as bool?
      ..price = (json['price'] as num?)?.toDouble()
      ..createdAt = json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String)
      ..orderItems = (json['orderItems'] as List<dynamic>?)
          ?.map((e) => OrderItems.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'orderNumber': instance.orderNumber,
      'user': instance.user,
      'isCancelled': instance.isCancelled,
      'isShipped': instance.isShipped,
      'price': instance.price,
      'createdAt': instance.createdAt?.toIso8601String(),
      'orderItems': instance.orderItems,
    };
