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
    )..freelancerId = (json['freelancerId'] as num?)?.toInt();

Map<String, dynamic> _$FreelancerToJson(Freelancer instance) =>
    <String, dynamic>{
      'freelancerId': instance.freelancerId,
      'bio': instance.bio,
      'rating': instance.rating,
      'hourlyRate': instance.hourlyRate,
      'availability': instance.availability,
      'experianceYears': instance.experianceYears,
      'location': instance.location,
      'freelancerServices': instance.freelancerServices,
      'user': instance.user,
    };
