// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freelancer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Freelancer _$FreelancerFromJson(Map<String, dynamic> json) => Freelancer(
      bio: json['bio'] as String?,
      freelancerServices: (json['freelancerServices'] as List<dynamic>?)
          ?.map((e) => FreelancerService.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..freelancerId = (json['freelancerId'] as num?)?.toInt()
      ..userId = (json['userId'] as num?)?.toInt()
      ..rating = (json['rating'] as num?)?.toDouble()
      ..experianceYears = (json['experianceYears'] as num?)?.toInt()
      ..workingDays = (json['workingDays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..startTime = json['startTime'] as String?
      ..endTime = json['endTime'] as String?
      ..user = json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$FreelancerToJson(Freelancer instance) =>
    <String, dynamic>{
      'freelancerId': instance.freelancerId,
      'userId': instance.userId,
      'bio': instance.bio,
      'rating': instance.rating,
      'experianceYears': instance.experianceYears,
      'workingDays': instance.workingDays,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'freelancerServices': instance.freelancerServices,
      'user': instance.user,
    };
