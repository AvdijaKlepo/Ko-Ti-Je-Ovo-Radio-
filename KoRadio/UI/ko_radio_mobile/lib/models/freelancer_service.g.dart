// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freelancer_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreelancerService _$FreelancerServiceFromJson(Map<String, dynamic> json) =>
    FreelancerService(
      freelancerId: (json['freelancerId'] as num?)?.toInt(),
      serviceId: (json['serviceId'] as num?)?.toInt(),
      service: json['service'] == null
          ? null
          : Service.fromJson(json['service'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FreelancerServiceToJson(FreelancerService instance) =>
    <String, dynamic>{
      'freelancerId': instance.freelancerId,
      'serviceId': instance.serviceId,
      'service': instance.service,
    };
