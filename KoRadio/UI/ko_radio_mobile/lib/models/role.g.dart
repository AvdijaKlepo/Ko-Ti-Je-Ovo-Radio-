// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
      (json['roleId'] as num).toInt(),
      json['roleName'] as String,
      json['roleDescription'] as String,
      json['isDeleted'] as bool,
    );

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
      'roleId': instance.roleId,
      'roleName': instance.roleName,
      'roleDescription': instance.roleDescription,
      'isDeleted': instance.isDeleted,
    };
