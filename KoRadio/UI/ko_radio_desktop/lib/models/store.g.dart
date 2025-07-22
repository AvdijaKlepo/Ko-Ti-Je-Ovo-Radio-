// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
      storeId: (json['storeId'] as num).toInt(),
    )
      ..storeName = json['storeName'] as String?
      ..user = json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>)
      ..description = json['description'] as String?
      ..isDeleted = json['isDeleted'] as bool?
      ..isApplicant = json['isApplicant'] as bool?
      ..location = json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>)
      ..address = json['address'] as String?;

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'user': instance.user,
      'description': instance.description,
      'isDeleted': instance.isDeleted,
      'isApplicant': instance.isApplicant,
      'location': instance.location,
      'address': instance.address,
    };
