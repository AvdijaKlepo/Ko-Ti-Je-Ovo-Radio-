// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freelancer_recommended_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreelancerRecommendedDto _$FreelancerRecommendedDtoFromJson(
        Map<String, dynamic> json) =>
    FreelancerRecommendedDto(
      freelancerId: (json['freelancerId'] as num).toInt(),
      freelancerNavigation: json['freelancerNavigation'] == null
          ? null
          : User.fromJson(json['freelancerNavigation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FreelancerRecommendedDtoToJson(
        FreelancerRecommendedDto instance) =>
    <String, dynamic>{
      'freelancerId': instance.freelancerId,
      'freelancerNavigation': instance.freelancerNavigation,
    };
