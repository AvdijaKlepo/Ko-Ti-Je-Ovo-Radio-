

import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/freelancer_service.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/user.dart';

part 'freelancer.g.dart';
@JsonSerializable()
class Freelancer{
  int? freelancerId;
  int? userId;
  String? bio;
  double? rating;
  int? experianceYears;
  List<String>? workingDays;
  String? startTime;
  String? endTime;
  List<FreelancerService>? freelancerServices;
  User? user;
  


  
  Freelancer({required this.bio,  required this.freelancerServices});

  factory Freelancer.fromJson(Map<String, dynamic> json) => _$FreelancerFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FreelancerToJson(this);
}
