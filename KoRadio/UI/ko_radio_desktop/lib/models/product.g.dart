// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      productId: (json['productId'] as num).toInt(),
    )
      ..productName = json['productName'] as String?
      ..productDescription = json['productDescription'] as String?
      ..price = (json['price'] as num?)?.toDouble()
      ..isDeleted = json['isDeleted'] as bool?
      ..image = json['image'] as String?
      ..store = json['store'] == null
          ? null
          : Store.fromJson(json['store'] as Map<String, dynamic>)
      ..orderItems = (json['orderItems'] as List<dynamic>?)
          ?.map((e) => OrderItems.fromJson(e as Map<String, dynamic>))
          .toList()
      ..productsServices = (json['productsServices'] as List<dynamic>?)
          ?.map((e) => ProductsServices.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'productDescription': instance.productDescription,
      'price': instance.price,
      'isDeleted': instance.isDeleted,
      'image': instance.image,
      'store': instance.store,
      'orderItems': instance.orderItems,
      'productsServices': instance.productsServices,
    };
