// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
      serviceId: (json['serviceId'] as num).toInt(),
      serviceName: json['serviceName'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'image': instance.image,
    };
