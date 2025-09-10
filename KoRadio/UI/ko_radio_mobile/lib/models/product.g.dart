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
      ..stockQuantity = (json['stockQuantity'] as num?)?.toInt()
      ..isOnSale = json['isOnSale'] as bool?
      ..salePrice = (json['salePrice'] as num?)?.toDouble()
      ..isOutOfStock = json['isOutOfStock'] as bool?
      ..saleExpires = json['saleExpires'] == null
          ? null
          : DateTime.parse(json['saleExpires'] as String)
      ..isDeleted = json['isDeleted'] as bool?
      ..image = json['image'] as String?
      ..storeId = (json['storeId'] as num?)?.toInt()
      ..store = json['store'] == null
          ? null
          : Store.fromJson(json['store'] as Map<String, dynamic>)
      ..productsServices = (json['productsServices'] as List<dynamic>?)
          ?.map((e) => ProductsServices.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'productDescription': instance.productDescription,
      'price': instance.price,
      'stockQuantity': instance.stockQuantity,
      'isOnSale': instance.isOnSale,
      'salePrice': instance.salePrice,
      'isOutOfStock': instance.isOutOfStock,
      'saleExpires': instance.saleExpires?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'image': instance.image,
      'storeId': instance.storeId,
      'store': instance.store,
      'productsServices': instance.productsServices,
    };
