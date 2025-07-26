// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Messages _$MessagesFromJson(Map<String, dynamic> json) => Messages()
  ..messageId = (json['messageId'] as num?)?.toInt()
  ..message1 = json['message1'] as String?
  ..createdAt = json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String)
  ..userId = (json['userId'] as num?)?.toInt()
  ..isOpened = json['isOpened'] as bool?
  ..user = json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$MessagesToJson(Messages instance) => <String, dynamic>{
      'messageId': instance.messageId,
      'message1': instance.message1,
      'createdAt': instance.createdAt?.toIso8601String(),
      'userId': instance.userId,
      'isOpened': instance.isOpened,
      'user': instance.user,
    };
