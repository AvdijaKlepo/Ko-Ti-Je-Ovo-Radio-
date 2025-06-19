import 'package:json_annotation/json_annotation.dart';

part 'company_role.g.dart';

@JsonSerializable()
class CompanyRole {
	int? companyId;
	String roleName;

	CompanyRole(this.companyId,this.roleName,);

	factory CompanyRole.fromJson(Map<String, dynamic> json) => _$CompanyRoleFromJson(json);

	Map<String, dynamic> toJson() => _$CompanyRoleToJson(this);
}