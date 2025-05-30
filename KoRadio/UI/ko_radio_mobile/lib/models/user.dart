import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/role.dart';
import 'package:ko_radio_mobile/models/user_role.dart';


part 'user.g.dart';
@JsonSerializable()
class User{
  int? userId;
  String? firstName;
  String? lastName;
  String? email;
  Role? role;
  List<UserRole>? userRoles;
  String? image;
  Location? location;


  User();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
