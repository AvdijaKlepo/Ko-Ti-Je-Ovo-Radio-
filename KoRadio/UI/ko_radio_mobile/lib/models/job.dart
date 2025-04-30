

import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/jobs_service.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/models/service.dart';


part 'job.g.dart';
@JsonSerializable()
class Job{
  int? jobId;
  Freelancer? freelancer;
  User? user;
  Service? service;
  String startEstimate;
  String? endEstimate;
  double? payEstimate;
  double? payInvoice;
  DateTime jobDate;
  String? jobDescription;
  String? image;
  List<JobsService>? jobsServices;

  




  
  Job({required this.endEstimate,required this.startEstimate,required this.payEstimate,required this.payInvoice,required this.jobDate});

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$JobToJson(this);
}

	