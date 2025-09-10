import 'package:json_annotation/json_annotation.dart';


part 'company_dto.g.dart';
@JsonSerializable()
class CompanyDto {
 
  bool isDeleted;


  CompanyDto({required this.isDeleted});

  factory CompanyDto.fromJson(Map<String, dynamic> json) => _$CompanyDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyDtoToJson(this);
}