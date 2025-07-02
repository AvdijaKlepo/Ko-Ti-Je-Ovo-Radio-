import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/service.dart';

part 'products_services.g.dart';

@JsonSerializable()
class ProductsServices {
  int? productId;
  int? serviceId;

  Service? service;

  ProductsServices();

 factory ProductsServices.fromJson(Map<String, dynamic> json) => _$ProductsServicesFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ProductsServicesToJson(this);
  }