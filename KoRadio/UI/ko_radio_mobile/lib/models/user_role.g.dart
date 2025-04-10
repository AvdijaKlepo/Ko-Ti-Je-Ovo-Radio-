// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRole _$UserRoleFromJson(Map<String, dynamic> json) => UserRole(
      (json['userRolesId'] as num).toInt(),
      (json['userId'] as num?)?.toInt(),
      (json['roleId'] as num?)?.toInt(),
      json['changedAt'] == null
          ? null
          : DateTime.parse(json['changedAt'] as String),
      Role.fromJson(json['role'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
      'userRolesId': instance.userRolesId,
      'userId': instance.userId,
      'roleId': instance.roleId,
      'changedAt': instance.changedAt?.toIso8601String(),
      'role': instance.role,
    };
