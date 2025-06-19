// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_job_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyJobAssignment _$CompanyJobAssignmentFromJson(
        Map<String, dynamic> json) =>
    CompanyJobAssignment(
      (json['companyEmployeeId'] as num?)?.toInt(),
      (json['jobId'] as num?)?.toInt(),
      DateTime.parse(json['assignedAt'] as String),
    )
      ..companyEmployee = json['companyEmployee'] == null
          ? null
          : CompanyEmployee.fromJson(
              json['companyEmployee'] as Map<String, dynamic>)
      ..job = json['job'] == null
          ? null
          : Job.fromJson(json['job'] as Map<String, dynamic>);

Map<String, dynamic> _$CompanyJobAssignmentToJson(
        CompanyJobAssignment instance) =>
    <String, dynamic>{
      'companyEmployeeId': instance.companyEmployeeId,
      'jobId': instance.jobId,
      'assignedAt': instance.assignedAt.toIso8601String(),
      'companyEmployee': instance.companyEmployee,
      'job': instance.job,
    };
