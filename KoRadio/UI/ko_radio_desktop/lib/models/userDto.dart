import 'package:json_annotation/json_annotation.dart';

part 'userDto.g.dart';
@JsonSerializable()
class UserDto{
  int userId;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  UserDto({ required this.userId, required this.firstName, required this.lastName, required this.email, required this.phoneNumber });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
