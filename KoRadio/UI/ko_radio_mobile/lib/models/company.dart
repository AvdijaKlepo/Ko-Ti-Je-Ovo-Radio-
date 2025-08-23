import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/company_employee.dart';
import 'package:ko_radio_mobile/models/company_services.dart';
import 'package:ko_radio_mobile/models/location.dart';

part 'company.g.dart';
@JsonSerializable()
class Company {
  int companyId;
  String companyName;
  String email;
  String bio;
  double rating;
  String phoneNumber;
  int experianceYears;
  String? image;
  List<String>? workingDays;
  String startTime;
  String endTime;
  int? locationId;
  Location? location;
  bool isDeleted;
  bool isApplicant;
  List<CompanyEmployee>? companyEmployees;
  List<CompanyServices> companyServices; 
  Company(this.companyId ,this.companyName, this.bio, this.rating,
   this.phoneNumber, this.experianceYears, this.image, this.workingDays, this.startTime, 
   this.endTime, this.location, this.isDeleted, this.isApplicant, this.companyEmployees, this.companyServices,this.email);

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}