import 'package:json_annotation/json_annotation.dart';

part 'company_recommended_dto.g.dart';

@JsonSerializable()
class CompanyRecommendedDto {
  int? companyId;
  String? companyName;
  String? image;

  CompanyRecommendedDto();

  factory CompanyRecommendedDto.fromJson(Map<String, dynamic> json) => _$CompanyRecommendedDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyRecommendedDtoToJson(this);
  
}