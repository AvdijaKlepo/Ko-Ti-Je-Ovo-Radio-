import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/service.dart';

part 'tender_service.g.dart';

@JsonSerializable()
class TenderService {
  int? tenderId;
  int? serviceId;

  Service? service;

  TenderService({required this.tenderId, required this.serviceId, required this.service});

  factory TenderService.fromJson(Map<String, dynamic> json) => _$TenderServiceFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$TenderServiceToJson(this);
 
}