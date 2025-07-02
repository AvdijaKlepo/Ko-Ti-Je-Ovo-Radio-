// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_services.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductsServices _$ProductsServicesFromJson(Map<String, dynamic> json) =>
    ProductsServices()
      ..productId = (json['productId'] as num?)?.toInt()
      ..serviceId = (json['serviceId'] as num?)?.toInt()
      ..service = json['service'] == null
          ? null
          : Service.fromJson(json['service'] as Map<String, dynamic>);

Map<String, dynamic> _$ProductsServicesToJson(ProductsServices instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'serviceId': instance.serviceId,
      'service': instance.service,
    };
