// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      jobId: (json['jobId'] as num).toInt(),
      endEstimate: json['endEstimate'] as String?,
      startEstimate: json['startEstimate'] as String?,
      payEstimate: (json['payEstimate'] as num?)?.toDouble(),
      payInvoice: (json['payInvoice'] as num?)?.toDouble(),
      jobDate: DateTime.parse(json['jobDate'] as String),
      jobStatus: $enumDecode(_$JobStatusEnumMap, json['jobStatus']),
      jobDescription: json['jobDescription'] as String,
      image: json['image'] as String?,
      jobsServices: (json['jobsServices'] as List<dynamic>?)
          ?.map((e) => JobsService.fromJson(e as Map<String, dynamic>))
          .toList(),
      freelancer: json['freelancer'] == null
          ? null
          : Freelancer.fromJson(json['freelancer'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      service: json['service'] == null
          ? null
          : Service.fromJson(json['service'] as Map<String, dynamic>),
    )
      ..jobTitle = json['jobTitle'] as String?
      ..isTenderFinalized = json['isTenderFinalized'] as bool?
      ..isInvoiced = json['isInvoiced'] as bool?
      ..isRated = json['isRated'] as bool?
      ..isEdited = json['isEdited'] as bool?
      ..dateFinished = json['dateFinished'] == null
          ? null
          : DateTime.parse(json['dateFinished'] as String)
      ..company = json['company'] == null
          ? null
          : Company.fromJson(json['company'] as Map<String, dynamic>);

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'jobId': instance.jobId,
      'freelancer': instance.freelancer,
      'user': instance.user,
      'service': instance.service,
      'startEstimate': instance.startEstimate,
      'jobTitle': instance.jobTitle,
      'endEstimate': instance.endEstimate,
      'payEstimate': instance.payEstimate,
      'payInvoice': instance.payInvoice,
      'isTenderFinalized': instance.isTenderFinalized,
      'isInvoiced': instance.isInvoiced,
      'isRated': instance.isRated,
      'isEdited': instance.isEdited,
      'jobDate': instance.jobDate.toIso8601String(),
      'jobDescription': instance.jobDescription,
      'image': instance.image,
      'jobsServices': instance.jobsServices,
      'jobStatus': _$JobStatusEnumMap[instance.jobStatus]!,
      'dateFinished': instance.dateFinished?.toIso8601String(),
      'company': instance.company,
    };

const _$JobStatusEnumMap = {
  JobStatus.unapproved: 'unapproved',
  JobStatus.approved: 'approved',
  JobStatus.finished: 'finished',
  JobStatus.cancelled: 'cancelled',
  JobStatus.inProgress: 'inProgress',
};
