// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freelancer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Freelancer _$FreelancerFromJson(Map<String, dynamic> json) => Freelancer(
      bio: json['bio'] as String,
      rating: (json['rating'] as num).toDouble(),
      experianceYears: (json['experianceYears'] as num).toInt(),
      freelancerServices: (json['freelancerServices'] as List<dynamic>)
          .map((e) => FreelancerService.fromJson(e as Map<String, dynamic>))
          .toList(),
      workingDays: (json['workingDays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      freelancerNavigation: json['freelancerNavigation'] == null
          ? null
          : User.fromJson(json['freelancerNavigation'] as Map<String, dynamic>),
      freelancerId: (json['freelancerId'] as num).toInt(),
      isApplicant: json['isApplicant'] as bool,
      isDeleted: json['isDeleted'] as bool,
    );

Map<String, dynamic> _$FreelancerToJson(Freelancer instance) =>
    <String, dynamic>{
      'freelancerId': instance.freelancerId,
      'bio': instance.bio,
      'rating': instance.rating,
      'experianceYears': instance.experianceYears,
      'workingDays': instance.workingDays,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'freelancerServices': instance.freelancerServices,
      'freelancerNavigation': instance.freelancerNavigation,
      'isApplicant': instance.isApplicant,
      'isDeleted': instance.isDeleted,
    };
