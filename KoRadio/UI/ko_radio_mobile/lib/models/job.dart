

import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/jobs_service.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/models/service.dart';


part 'job.g.dart';
@JsonSerializable()
class Job{
  int jobId;
  Freelancer? freelancer;
  User? user;
  Service? service;
  String? startEstimate;
  String? jobTitle;
  String? endEstimate;
  double? payEstimate;
  double? payInvoice;
  bool? isTenderFinalized; 
  bool? isInvoiced;
  bool? isRated;
  DateTime jobDate;
  String jobDescription;
  String? image;
  List<JobsService>? jobsServices;
  JobStatus jobStatus;
  Company? company;
  DateTime? dateFinished;
  bool? isDeletedWorker;
  bool? isEdited;
  bool? isApproved;
  String? rescheduleNote;


  




  
  Job({ required this.jobId ,required this.endEstimate,required this.startEstimate,required this.payEstimate,required this.payInvoice,required this.jobDate, required this.jobStatus, required this.jobDescription, required this.image, required this.jobsServices, required this.freelancer, required this.user, required this.service});

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$JobToJson(this);

  copyWith({DateTime? jobDate}) {}
}

	