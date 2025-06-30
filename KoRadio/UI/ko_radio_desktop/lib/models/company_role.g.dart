// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyRole _$CompanyRoleFromJson(Map<String, dynamic> json) => CompanyRole(
      (json['companyId'] as num?)?.toInt(),
      json['roleName'] as String?,
    )..companyRoleId = (json['companyRoleId'] as num?)?.toInt();

Map<String, dynamic> _$CompanyRoleToJson(CompanyRole instance) =>
    <String, dynamic>{
      'companyRoleId': instance.companyRoleId,
      'companyId': instance.companyId,
      'roleName': instance.roleName,
    };
