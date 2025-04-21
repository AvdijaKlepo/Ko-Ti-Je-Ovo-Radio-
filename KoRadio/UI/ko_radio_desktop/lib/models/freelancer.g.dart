// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freelancer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Freelancer _$FreelancerFromJson(Map<String, dynamic> json) => Freelancer(
      bio: json['bio'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      availability: json['availability'] as String?,
      experianceYears: (json['experianceYears'] as num?)?.toInt(),
      location: json['location'] as String?,
      freelancerServices: (json['freelancerServices'] as List<dynamic>?)
          ?.map((e) => FreelancerService.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    )
      ..freelancerId = (json['freelancerId'] as num?)?.toInt()
      ..workingDays = (json['workingDays'] as num?)?.toInt()
      ..startTime = json['startTime'] as String?
      ..endTime = json['endTime'] as String?;

Map<String, dynamic> _$FreelancerToJson(Freelancer instance) =>
    <String, dynamic>{
      'freelancerId': instance.freelancerId,
      'bio': instance.bio,
      'rating': instance.rating,
      'hourlyRate': instance.hourlyRate,
      'availability': instance.availability,
      'experianceYears': instance.experianceYears,
      'location': instance.location,
      'workingDays': instance.workingDays,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'freelancerServices': instance.freelancerServices,
      'user': instance.user,
    };
