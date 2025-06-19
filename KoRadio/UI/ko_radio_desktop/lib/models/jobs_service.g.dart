// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobsService _$JobsServiceFromJson(Map<String, dynamic> json) => JobsService(
      jobId: (json['jobId'] as num?)?.toInt(),
      serviceId: (json['serviceId'] as num?)?.toInt(),
      service: json['service'] == null
          ? null
          : Service.fromJson(json['service'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobsServiceToJson(JobsService instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'serviceId': instance.serviceId,
      'service': instance.service,
    };
