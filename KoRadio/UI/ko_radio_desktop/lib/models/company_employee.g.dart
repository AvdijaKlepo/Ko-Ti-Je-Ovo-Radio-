// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyEmployee _$CompanyEmployeeFromJson(Map<String, dynamic> json) =>
    CompanyEmployee()
      ..userId = (json['userId'] as num?)?.toInt()
      ..companyId = (json['companyId'] as num?)?.toInt()
      ..isDeleted = json['isDeleted'] as bool?
      ..isApplicant = json['isApplicant'] as bool?
      ..user = json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$CompanyEmployeeToJson(CompanyEmployee instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'companyId': instance.companyId,
      'isDeleted': instance.isDeleted,
      'isApplicant': instance.isApplicant,
      'user': instance.user,
    };
