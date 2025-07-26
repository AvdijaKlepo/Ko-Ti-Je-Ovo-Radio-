

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:ko_radio_mobile/models/user.dart';


part 'messages.g.dart';
@JsonSerializable()
class Messages{
 int? messageId;
 String? message1;
 DateTime? createdAt;
 int? userId;
 bool? isOpened;
 User? user;


  
  Messages();

  factory Messages.fromJson(Map<String, dynamic> json) => _$MessagesFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$MessagesToJson(this);
}
