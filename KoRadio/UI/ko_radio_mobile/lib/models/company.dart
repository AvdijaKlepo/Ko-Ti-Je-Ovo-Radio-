import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/company_employee.dart';
import 'package:ko_radio_mobile/models/company_services.dart';
import 'package:ko_radio_mobile/models/location.dart';

part 'company.g.dart';
@JsonSerializable()
class Company {
  int? companyId;
  String? bio;
  String? email;
  double? rating;
  String? phoneNumber;
  int? experianceYears;
  String? image;
  List<String>? workingDays;
  String? startTime;
  String? endTime;
  Location? location;
  bool? isDeleted;
  bool? isApplicant;
  List<CompanyEmployee>? companyEmployee; 
  List<CompanyServices>? companyServices;

  Company();

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}