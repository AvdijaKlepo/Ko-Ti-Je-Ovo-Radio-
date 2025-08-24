import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/user.dart';
part 'freelancer_recommended_dto.g.dart';

@JsonSerializable()
class FreelancerRecommendedDto {
 int freelancerId;
 User? freelancerNavigation;

 FreelancerRecommendedDto({required this.freelancerId, required this.freelancerNavigation});

 factory FreelancerRecommendedDto.fromJson(Map<String, dynamic> json) => _$FreelancerRecommendedDtoFromJson(json);
 Map<String, dynamic> toJson() => _$FreelancerRecommendedDtoToJson(this);
 
}