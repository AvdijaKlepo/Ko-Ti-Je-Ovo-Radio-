
import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/service.dart';


part 'jobs_service.g.dart';
@JsonSerializable()
class JobsService{
  int? jobId;
  int? serviceId;

  Service? service;
 

  
  JobsService({required this.jobId, required this.serviceId, required this.service});

  factory JobsService.fromJson(Map<String, dynamic> json) => _$JobsServiceFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$JobsServiceToJson(this);
}