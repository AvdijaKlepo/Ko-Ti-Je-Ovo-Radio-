// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freelancer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Freelancer _$FreelancerFromJson(Map<String, dynamic> json) => Freelancer(
      bio: json['bio'] as String?,
      locationId: json['locationId'] == null
          ? null
          : Location.fromJson(json['locationId'] as Map<String, dynamic>),
      freelancerServices: (json['freelancerServices'] as List<dynamic>?)
          ?.map((e) => FreelancerService.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    )
      ..freelancerId = (json['freelancerId'] as num?)?.toInt()
      ..rating = (json['rating'] as num?)?.toDouble()
      ..workingDays = (json['workingDays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..startTime = json['startTime'] as String?
      ..endTime = json['endTime'] as String?;

Map<String, dynamic> _$FreelancerToJson(Freelancer instance) =>
    <String, dynamic>{
      'freelancerId': instance.freelancerId,
      'bio': instance.bio,
      'rating': instance.rating,
      'workingDays': instance.workingDays,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'freelancerServices': instance.freelancerServices,
      'locationId': instance.locationId,
      'user': instance.user,
    };
