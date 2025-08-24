// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_recommended_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyRecommendedDto _$CompanyRecommendedDtoFromJson(
        Map<String, dynamic> json) =>
    CompanyRecommendedDto()
      ..companyId = (json['companyId'] as num?)?.toInt()
      ..companyName = json['companyName'] as String?
      ..image = json['image'] as String?;

Map<String, dynamic> _$CompanyRecommendedDtoToJson(
        CompanyRecommendedDto instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'companyName': instance.companyName,
      'image': instance.image,
    };
