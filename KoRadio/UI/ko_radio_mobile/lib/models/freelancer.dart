

import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/freelancer_service.dart';
import 'package:ko_radio_mobile/models/user.dart';


part 'freelancer.g.dart';
@JsonSerializable()
class Freelancer{
  int? freelancerId;
  String? bio;
  double? rating;
  double? hourlyRate;
  String? availability;
  int? experianceYears;
  String? location;
  List<String>? workingDays;
  String? startTime;
  String? endTime;
  List<FreelancerService>? freelancerServices;
  User user;


  
  Freelancer({required this.bio, required this.rating, required this.hourlyRate, required this.availability, required this.experianceYears, required this.location, required this.freelancerServices,required this.user,required this.workingDays});

  factory Freelancer.fromJson(Map<String, dynamic> json) => _$FreelancerFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FreelancerToJson(this);
}
