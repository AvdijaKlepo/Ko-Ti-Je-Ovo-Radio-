// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freelancer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreelancerDto _$FreelancerDtoFromJson(Map<String, dynamic> json) =>
    FreelancerDto(
      freelancerId: (json['freelancerId'] as num?)?.toInt(),
    )
      ..freelancerServices = (json['freelancerServices'] as List<dynamic>?)
          ?.map((e) => FreelancerService.fromJson(e as Map<String, dynamic>))
          .toList()
      ..isDeleted = json['isDeleted'] as bool?
      ..isApplicant = json['isApplicant'] as bool?;

Map<String, dynamic> _$FreelancerDtoToJson(FreelancerDto instance) =>
    <String, dynamic>{
      'freelancerId': instance.freelancerId,
      'freelancerServices': instance.freelancerServices,
      'isDeleted': instance.isDeleted,
      'isApplicant': instance.isApplicant,
    };
