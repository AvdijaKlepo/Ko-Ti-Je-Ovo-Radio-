// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Worker _$WorkerFromJson(Map<String, dynamic> json) => Worker(
      workerId: (json['workerId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      bio: json['bio'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkerToJson(Worker instance) => <String, dynamic>{
      'workerId': instance.workerId,
      'userId': instance.userId,
      'bio': instance.bio,
      'user': instance.user,
    };
