import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';

part 'tender_bids.g.dart';

@JsonSerializable()
class TenderBid{

  int tenderBidId;
  int? jobId;
  int? freelancerId;
  int? companyId;
  String? startEstimate;
  String? endEstimate;
  double? bidAmount;
  String? bidDescription;
  DateTime? dateFinished;
  DateTime? createdAt;
  Company? company;
  Freelancer? freelancer;
  Job? job;

  TenderBid(this.tenderBidId);

  factory TenderBid.fromJson(Map<String, dynamic> json) => _$TenderBidFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$TenderBidToJson(this);
}