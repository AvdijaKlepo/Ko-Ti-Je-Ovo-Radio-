// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      jobId: (json['jobId'] as num).toInt(),
      endEstimate: json['endEstimate'] as String?,
      startEstimate: json['startEstimate'] as String,
      payEstimate: (json['payEstimate'] as num?)?.toDouble(),
      payInvoice: (json['payInvoice'] as num?)?.toDouble(),
      jobDate: DateTime.parse(json['jobDate'] as String),
      jobStatus: $enumDecode(_$JobStatusEnumMap, json['jobStatus']),
      jobDescription: json['jobDescription'] as String,
      image: json['image'] as String?,
      jobsServices: (json['jobsServices'] as List<dynamic>?)
          ?.map((e) => JobsService.fromJson(e as Map<String, dynamic>))
          .toList(),
      freelancer:
          Freelancer.fromJson(json['freelancer'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      service: Service.fromJson(json['service'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'jobId': instance.jobId,
      'freelancer': instance.freelancer,
      'user': instance.user,
      'service': instance.service,
      'startEstimate': instance.startEstimate,
      'endEstimate': instance.endEstimate,
      'payEstimate': instance.payEstimate,
      'payInvoice': instance.payInvoice,
      'jobDate': instance.jobDate.toIso8601String(),
      'jobDescription': instance.jobDescription,
      'image': instance.image,
      'jobsServices': instance.jobsServices,
      'jobStatus': _$JobStatusEnumMap[instance.jobStatus]!,
    };

const _$JobStatusEnumMap = {
  JobStatus.unapproved: 'unapproved',
  JobStatus.approved: 'approved',
  JobStatus.finished: 'finished',
  JobStatus.cancelled: 'cancelled',
  JobStatus.inProgress: 'inProgress',
};
