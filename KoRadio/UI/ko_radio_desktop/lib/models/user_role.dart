import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/role.dart';
part 'user_role.g.dart';
@JsonSerializable()
class UserRole {
	int userRolesId;
	int? userId;
	int? roleId;
	DateTime? changedAt;
	Role role;

	UserRole(this.userRolesId,this.userId,this.roleId,this.changedAt,this.role,);

	factory UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);

	Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}