import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/role.dart';
part 'user_role.g.dart';
@JsonSerializable()
class UserRole {
	int userRoleId;
	int userId;
	int roleId;
  DateTime createdAt;
	DateTime changedAt;
	Role role;

  UserRole({ required this.userRoleId, required this.userId, required this.roleId, required this.createdAt, required this.changedAt, required this.role });

	factory UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);

	Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}