import 'package:json_annotation/json_annotation.dart';

import 'package:ko_radio_mobile/models/role.dart';
import 'package:ko_radio_mobile/models/user.dart';
part 'user_role.g.dart';
@JsonSerializable()
class UserRole {
	int userRoleId;
	int userId;
	int roleId;
  DateTime createdAt;
	DateTime changedAt;
	Role? role;


	UserRole({required this.userRoleId, required this.userId, required this.roleId, required this.role,  required this.createdAt, required this.changedAt});

	factory UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);

	Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}