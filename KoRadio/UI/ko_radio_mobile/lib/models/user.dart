import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/role.dart';
import 'package:ko_radio_mobile/models/user_role.dart';


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




  User({ required this.userId, required this.firstName, required this.lastName, required this.email,  required this.phoneNumber, required this.location, required this.isDeleted, required this.createdAt, required this.address});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserToJson(this);
}


