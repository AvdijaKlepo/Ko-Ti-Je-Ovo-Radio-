import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/service.dart';



part 'company_services.g.dart';
@JsonSerializable()
class CompanyServices {

  int? companyId;
  int? serviceId;

  Service? service;


  CompanyServices();
  factory CompanyServices.fromJson(Map<String, dynamic> json) => _$CompanyServicesFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyServicesToJson(this);
}