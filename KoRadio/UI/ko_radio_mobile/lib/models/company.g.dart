// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company()
  ..companyId = (json['companyId'] as num?)?.toInt()
  ..bio = json['bio'] as String?
  ..email = json['email'] as String?
  ..rating = (json['rating'] as num?)?.toDouble()
  ..phoneNumber = json['phoneNumber'] as String?
  ..experianceYears = (json['experianceYears'] as num?)?.toInt()
  ..image = json['image'] as String?
  ..workingDays =
      (json['workingDays'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..startTime = json['startTime'] as String?
  ..endTime = json['endTime'] as String?
  ..location = json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>)
  ..isDeleted = json['isDeleted'] as bool?
  ..isApplicant = json['isApplicant'] as bool?
  ..companyEmployee = (json['companyEmployee'] as List<dynamic>?)
      ?.map((e) => CompanyEmployee.fromJson(e as Map<String, dynamic>))
      .toList()
  ..companyServices = (json['companyServices'] as List<dynamic>?)
      ?.map((e) => CompanyServices.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'companyId': instance.companyId,
      'bio': instance.bio,
      'email': instance.email,
      'rating': instance.rating,
      'phoneNumber': instance.phoneNumber,
      'experianceYears': instance.experianceYears,
      'image': instance.image,
      'workingDays': instance.workingDays,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'location': instance.location,
      'isDeleted': instance.isDeleted,
      'isApplicant': instance.isApplicant,
      'companyEmployee': instance.companyEmployee,
      'companyServices': instance.companyServices,
    };
