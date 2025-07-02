// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: (json['userId'] as num).toInt(),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      userRoles: (json['userRoles'] as List<dynamic>?)
          ?.map((e) => UserRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      image: json['image'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      address: json['address'] as String?,
      isDeleted: json['isDeleted'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      companyEmployees: (json['companyEmployees'] as List<dynamic>?)
          ?.map((e) => CompanyEmployee.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..stores = (json['stores'] as List<dynamic>?)
        ?.map((e) => Store.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'userRoles': instance.userRoles,
      'image': instance.image,
      'phoneNumber': instance.phoneNumber,
      'location': instance.location,
      'address': instance.address,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'companyEmployees': instance.companyEmployees,
      'stores': instance.stores,
    };
