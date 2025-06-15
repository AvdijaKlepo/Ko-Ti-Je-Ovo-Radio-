
import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/user.dart';

part 'company_employee.g.dart';
@JsonSerializable()
class CompanyEmployee {
  int? userId;
  int? companyId;
  bool? isDeleted;
  bool? isApplicant;

  User? user;

  CompanyEmployee();

  factory CompanyEmployee.fromJson(Map<String, dynamic> json) => _$CompanyEmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyEmployeeToJson(this);
}