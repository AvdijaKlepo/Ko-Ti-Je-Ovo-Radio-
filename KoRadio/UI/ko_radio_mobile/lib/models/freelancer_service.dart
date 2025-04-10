
import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/service.dart';


part 'freelancer_service.g.dart';
@JsonSerializable()
class FreelancerService{
  int? freelancerId;
  int? serviceId;

  Service? service;
 

  
  FreelancerService({required this.freelancerId, required this.serviceId, required this.service});

  factory FreelancerService.fromJson(Map<String, dynamic> json) => _$FreelancerServiceFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FreelancerServiceToJson(this);
}