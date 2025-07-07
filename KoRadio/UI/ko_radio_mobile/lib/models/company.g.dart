// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
      (json['companyId'] as num).toInt(),
      json['companyName'] as String,
      json['bio'] as String,
      (json['rating'] as num).toDouble(),
      json['phoneNumber'] as String,
      (json['experianceYears'] as num).toInt(),
      json['image'] as String?,
      (json['workingDays'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['startTime'] as String,
      json['endTime'] as String,
      json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      json['isDeleted'] as bool,
      json['isApplicant'] as bool,
      (json['companyEmployees'] as List<dynamic>)
          .map((e) => CompanyEmployee.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['companyServices'] as List<dynamic>)
          .map((e) => CompanyServices.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['email'] as String,
    )..locationId = (json['locationId'] as num?)?.toInt();

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'companyId': instance.companyId,
      'companyName': instance.companyName,
      'email': instance.email,
      'bio': instance.bio,
      'rating': instance.rating,
      'phoneNumber': instance.phoneNumber,
      'experianceYears': instance.experianceYears,
      'image': instance.image,
      'workingDays': instance.workingDays,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'locationId': instance.locationId,
      'location': instance.location,
      'isDeleted': instance.isDeleted,
      'isApplicant': instance.isApplicant,
      'companyEmployees': instance.companyEmployees,
      'companyServices': instance.companyServices,
    };
