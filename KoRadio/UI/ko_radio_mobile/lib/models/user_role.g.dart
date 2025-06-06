// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRole _$UserRoleFromJson(Map<String, dynamic> json) => UserRole(
      userRoleId: (json['userRoleId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      roleId: (json['roleId'] as num).toInt(),
      role: Role.fromJson(json['role'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      changedAt: DateTime.parse(json['changedAt'] as String),
    );

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
      'userRoleId': instance.userRoleId,
      'userId': instance.userId,
      'roleId': instance.roleId,
      'createdAt': instance.createdAt.toIso8601String(),
      'changedAt': instance.changedAt.toIso8601String(),
      'role': instance.role,
    };
