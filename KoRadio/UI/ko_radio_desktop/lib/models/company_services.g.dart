// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_services.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyServices _$CompanyServicesFromJson(Map<String, dynamic> json) =>
    CompanyServices()
      ..companyId = (json['companyId'] as num?)?.toInt()
      ..serviceId = (json['serviceId'] as num?)?.toInt()
      ..service = json['service'] == null
          ? null
          : Service.fromJson(json['service'] as Map<String, dynamic>);

Map<String, dynamic> _$CompanyServicesToJson(CompanyServices instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'serviceId': instance.serviceId,
      'service': instance.service,
    };
