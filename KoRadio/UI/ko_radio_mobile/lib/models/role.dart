import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';

part 'role.g.dart';
@JsonSerializable()
class Role {
	int roleId;
	String roleName;
	String roleDescription;
  bool isDeleted;

	Role(this.roleId,this.roleName,this.roleDescription, this.isDeleted);

	factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

	Map<String, dynamic> toJson() => _$RoleToJson(this);
}