// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyRole _$CompanyRoleFromJson(Map<String, dynamic> json) => CompanyRole(
      (json['companyId'] as num?)?.toInt(),
      json['roleName'] as String,
    );

Map<String, dynamic> _$CompanyRoleToJson(CompanyRole instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'roleName': instance.roleName,
    };
