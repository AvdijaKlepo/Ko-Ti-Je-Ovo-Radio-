// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeTask _$EmployeeTaskFromJson(Map<String, dynamic> json) => EmployeeTask(
      employeeTaskId: (json['employeeTaskId'] as num).toInt(),
    )
      ..task = json['task'] as String?
      ..isFinished = json['isFinished'] as bool?
      ..companyEmployeeId = (json['companyEmployeeId'] as num?)?.toInt()
      ..createdAt = json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String)
      ..jobId = (json['jobId'] as num?)?.toInt()
      ..companyId = (json['companyId'] as num?)?.toInt()
      ..companyEmployee = json['companyEmployee'] == null
          ? null
          : CompanyEmployee.fromJson(
              json['companyEmployee'] as Map<String, dynamic>);

Map<String, dynamic> _$EmployeeTaskToJson(EmployeeTask instance) =>
    <String, dynamic>{
      'employeeTaskId': instance.employeeTaskId,
      'task': instance.task,
      'isFinished': instance.isFinished,
      'companyEmployeeId': instance.companyEmployeeId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'jobId': instance.jobId,
      'companyId': instance.companyId,
      'companyEmployee': instance.companyEmployee,
    };
