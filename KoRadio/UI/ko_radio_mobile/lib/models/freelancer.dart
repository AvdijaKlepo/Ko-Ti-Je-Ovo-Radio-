

import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/freelancer_service.dart';
import 'package:ko_radio_mobile/models/user.dart';


part 'freelancer.g.dart';
@JsonSerializable()
class Freelancer{
  int freelancerId;
  String bio;
  double rating;
  int experianceYears;
  List<String> workingDays;
  String startTime;
  String endTime;
  List<FreelancerService> freelancerServices;
  User freelancerNavigation;


  
  Freelancer({required this.bio, required this.rating,  required this.experianceYears,required this.freelancerServices,required this.workingDays, required this.startTime, required this.endTime, required this.freelancerNavigation, required this.freelancerId});

  factory Freelancer.fromJson(Map<String, dynamic> json) => _$FreelancerFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FreelancerToJson(this);
}
