
import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_role.dart';
import 'package:ko_radio_desktop/models/user.dart';


part 'company_employee.g.dart';
@JsonSerializable()
class CompanyEmployee {
  int companyEmployeeId;
  int? userId;
  int? companyId;
  bool? isDeleted;
  bool? isApplicant;
  String? companyName;
  int? companyRoleId;
  String? companyRoleName;
  DateTime? dateJoined;
  User? user;


  CompanyEmployee( this.companyEmployeeId, this.userId, this.companyId, this.isDeleted, this.isApplicant, this.user);

  factory CompanyEmployee.fromJson(Map<String, dynamic> json) => _$CompanyEmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyEmployeeToJson(this);
}