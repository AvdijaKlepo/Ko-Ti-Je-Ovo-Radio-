// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyEmployee _$CompanyEmployeeFromJson(Map<String, dynamic> json) =>
    CompanyEmployee(
      (json['companyEmployeeId'] as num).toInt(),
    )
      ..userId = (json['userId'] as num?)?.toInt()
      ..companyId = (json['companyId'] as num?)?.toInt()
      ..isDeleted = json['isDeleted'] as bool?
      ..isApplicant = json['isApplicant'] as bool?
      ..isOwner = json['isOwner'] as bool?
      ..companyName = json['companyName'] as String?
      ..companyRoleName = json['companyRoleName'] as String?
      ..dateJoined = json['dateJoined'] == null
          ? null
          : DateTime.parse(json['dateJoined'] as String)
      ..user = json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$CompanyEmployeeToJson(CompanyEmployee instance) =>
    <String, dynamic>{
      'companyEmployeeId': instance.companyEmployeeId,
      'userId': instance.userId,
      'companyId': instance.companyId,
      'isDeleted': instance.isDeleted,
      'isApplicant': instance.isApplicant,
      'isOwner': instance.isOwner,
      'companyName': instance.companyName,
      'companyRoleName': instance.companyRoleName,
      'dateJoined': instance.dateJoined?.toIso8601String(),
      'user': instance.user,
    };
