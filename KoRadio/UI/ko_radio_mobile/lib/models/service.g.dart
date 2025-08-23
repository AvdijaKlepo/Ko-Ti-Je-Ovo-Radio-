// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
      serviceId: (json['serviceId'] as num).toInt(),
      serviceName: json['serviceName'] as String,
      isDeleted: json['isDeleted'] as bool,
    )
      ..image = json['image'] as String?
      ..freelancerCount = (json['freelancerCount'] as num?)?.toInt()
      ..companyCount = (json['companyCount'] as num?)?.toInt();

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'image': instance.image,
      'isDeleted': instance.isDeleted,
      'freelancerCount': instance.freelancerCount,
      'companyCount': instance.companyCount,
    };
