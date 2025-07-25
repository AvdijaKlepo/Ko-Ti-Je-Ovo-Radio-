// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyEmployee _$CompanyEmployeeFromJson(Map<String, dynamic> json) =>
    CompanyEmployee(
      (json['companyEmployeeId'] as num).toInt(),
      (json['userId'] as num?)?.toInt(),
      (json['companyId'] as num?)?.toInt(),
      json['isDeleted'] as bool?,
      json['isApplicant'] as bool?,
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    )
      ..companyName = json['companyName'] as String?
      ..companyRole = json['companyRole'] == null
          ? null
          : CompanyRole.fromJson(json['companyRole'] as Map<String, dynamic>)
      ..companyRoleName = json['companyRoleName'] as String?
      ..dateJoined = json['dateJoined'] == null
          ? null
          : DateTime.parse(json['dateJoined'] as String);

Map<String, dynamic> _$CompanyEmployeeToJson(CompanyEmployee instance) =>
    <String, dynamic>{
      'companyEmployeeId': instance.companyEmployeeId,
      'userId': instance.userId,
      'companyId': instance.companyId,
      'isDeleted': instance.isDeleted,
      'isApplicant': instance.isApplicant,
      'companyName': instance.companyName,
      'companyRole': instance.companyRole,
      'companyRoleName': instance.companyRoleName,
      'dateJoined': instance.dateJoined?.toIso8601String(),
      'user': instance.user,
    };
