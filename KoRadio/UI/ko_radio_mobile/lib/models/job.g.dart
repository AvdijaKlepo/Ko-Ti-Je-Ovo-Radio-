// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      endEstimate: json['endEstimate'] as String,
      startEstimate: json['startEstimate'] as String,
      payEstimate: (json['payEstimate'] as num).toDouble(),
      payInvoice: (json['payInvoice'] as num).toDouble(),
      jobDate: DateTime.parse(json['jobDate'] as String),
    )
      ..jobId = (json['jobId'] as num?)?.toInt()
      ..freelancer = json['freelancer'] == null
          ? null
          : Freelancer.fromJson(json['freelancer'] as Map<String, dynamic>)
      ..user = json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'jobId': instance.jobId,
      'freelancer': instance.freelancer,
      'user': instance.user,
      'startEstimate': instance.startEstimate,
      'endEstimate': instance.endEstimate,
      'payEstimate': instance.payEstimate,
      'payInvoice': instance.payInvoice,
      'jobDate': instance.jobDate.toIso8601String(),
    };
