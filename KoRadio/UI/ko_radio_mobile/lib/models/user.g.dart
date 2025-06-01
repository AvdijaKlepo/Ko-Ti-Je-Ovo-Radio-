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
  ..userRoles = (json['userRoles'] as List<dynamic>?)
      ?.map((e) => UserRole.fromJson(e as Map<String, dynamic>))
      .toList()
  ..image = json['image'] as String?
  ..locationId = (json['locationId'] as num?)?.toInt()
  ..location = json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>)
  ..freelancer = json['freelancer'] == null
      ? null
      : Freelancer.fromJson(json['freelancer'] as Map<String, dynamic>);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'userRoles': instance.userRoles,
      'image': instance.image,
      'locationId': instance.locationId,
      'location': instance.location,
      'freelancer': instance.freelancer,
    };
