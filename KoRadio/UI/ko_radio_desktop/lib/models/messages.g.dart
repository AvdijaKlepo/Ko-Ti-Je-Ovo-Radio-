// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Messages _$MessagesFromJson(Map<String, dynamic> json) => Messages()
  ..messageId = (json['messageId'] as num?)?.toInt()
  ..message1 = json['message1'] as String?
  ..userId = (json['userId'] as num?)?.toInt()
  ..isOpened = json['isOpened'] as bool?
  ..companyId = (json['companyId'] as num?)?.toInt()
  ..storeId = (json['storeId'] as num?)?.toInt();

Map<String, dynamic> _$MessagesToJson(Messages instance) => <String, dynamic>{
      'messageId': instance.messageId,
      'message1': instance.message1,
      'userId': instance.userId,
      'isOpened': instance.isOpened,
      'companyId': instance.companyId,
      'storeId': instance.storeId,
    };
