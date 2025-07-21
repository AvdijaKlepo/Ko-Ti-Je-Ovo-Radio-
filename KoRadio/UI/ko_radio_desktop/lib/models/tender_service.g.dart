// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tender_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenderService _$TenderServiceFromJson(Map<String, dynamic> json) =>
    TenderService(
      tenderId: (json['tenderId'] as num?)?.toInt(),
      serviceId: (json['serviceId'] as num?)?.toInt(),
      service: json['service'] == null
          ? null
          : Service.fromJson(json['service'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TenderServiceToJson(TenderService instance) =>
    <String, dynamic>{
      'tenderId': instance.tenderId,
      'serviceId': instance.serviceId,
      'service': instance.service,
    };
