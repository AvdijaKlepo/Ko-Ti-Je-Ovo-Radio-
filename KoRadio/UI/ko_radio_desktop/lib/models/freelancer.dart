

import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/freelancer_service.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/models/user.dart';

part 'freelancer.g.dart';
@JsonSerializable()
class Freelancer{
  int? freelancerId;
  String? bio;
  double? rating;

  int? experianceYears;
  List<String>? workingDays;
  String? startTime;
  String? endTime;
  List<FreelancerService>? freelancerServices;
  Location? locationId;
  User user;
  


  
  Freelancer({required this.bio,  required this.locationId, required this.freelancerServices,required this.user});

  factory Freelancer.fromJson(Map<String, dynamic> json) => _$FreelancerFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FreelancerToJson(this);
}
