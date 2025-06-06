import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';
@JsonSerializable()
class Location{
  int locationId;
  String locationName;



  Location({ required this.locationId, required this.locationName});

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}