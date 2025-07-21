import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/freelancer.dart';
import 'package:ko_radio_desktop/models/tender_bids.dart';
import 'package:ko_radio_desktop/models/tender_service.dart';
import 'package:ko_radio_desktop/models/user.dart';
part 'tender.g.dart';

@JsonSerializable()
class Tender{
  int tenderId;
  DateTime? jobDate; 
  String? jobDescription;
  String? image;
  bool? isFinalized;
  int? userId;
  int? freelancerId;
  int? companyId;
  bool? isFreelancer;
  Company? company;
  User? user;
  Freelancer? freelancer;
  List<TenderBid>? tenderBids;
  List<TenderService>? tenderServices;

  Tender(this.tenderId);

  factory Tender.fromJson(Map<String, dynamic> json) => _$TenderFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$TenderToJson(this);

}