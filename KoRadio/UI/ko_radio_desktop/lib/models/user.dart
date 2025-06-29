import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/role.dart';
import 'package:ko_radio_desktop/models/user_role.dart';

part 'user.g.dart';
@JsonSerializable()
class User{
  int userId;
  String firstName;
  String lastName;
  String email;
  List<UserRole>? userRoles;
  String? image;
  String phoneNumber;
  Location? location;
  String address;
  bool isDeleted;
  DateTime createdAt;
  List<CompanyEmployee>? companyEmployees;
  User({ required this.userId, required this.firstName, required this.lastName, required this.email, required this.userRoles, required this.image, required this.phoneNumber, required this.location, required this.address, required this.isDeleted, required this.createdAt, required this.companyEmployees });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
