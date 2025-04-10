

import 'package:json_annotation/json_annotation.dart';
part 'service.g.dart';
@JsonSerializable()
class Service{
  int serviceId;
  String? serviceName;
  String? image;


  
  Service({required this.serviceId, required this.serviceName, this.image});

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
