// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User()
  ..userId = (json['userId'] as num?)?.toInt()
  ..firstName = json['firstName'] as String?
  ..lastName = json['lastName'] as String?
  ..email = json['email'] as String?
  ..role = json['role'] == null
      ? null
      : Role.fromJson(json['role'] as Map<String, dynamic>)
  ..userRoles = (json['userRoles'] as List<dynamic>?)
      ?.map((e) => UserRole.fromJson(e as Map<String, dynamic>))
      .toList()
  ..image = json['image'] as String?
  ..location = json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'role': instance.role,
      'userRoles': instance.userRoles,
      'image': instance.image,
      'location': instance.location,
    };
