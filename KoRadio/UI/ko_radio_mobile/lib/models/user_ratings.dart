

import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/user.dart';
part 'user_ratings.g.dart';
@JsonSerializable()
class UserRating{
  int? userId;
  int? freelancerId;
  int? jobId;
  double? rating;
  User? user;
  Freelancer? freelancer;
  Job? job;



  UserRating();
  factory UserRating.fromJson(Map<String, dynamic> json) => _$UserRatingFromJson(json);
  Map<String, dynamic> toJson() => _$UserRatingToJson(this);
}