
import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/freelancer_service.dart';

part 'freelancer_dto.g.dart';
@JsonSerializable()
class FreelancerDto{
  int? freelancerId;
  List<FreelancerService>? freelancerServices;
  

  FreelancerDto({this.freelancerId});

   factory FreelancerDto.fromJson(Map<String, dynamic> json) => _$FreelancerDtoFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FreelancerDtoToJson(this);
}