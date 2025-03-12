import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/user.dart';


part 'worker.g.dart';
@JsonSerializable()
class Worker{
  int? workerId;
  int? userId;
  String? bio;
  User? user;

   Worker({required this.workerId, required this.userId, this.bio,this.user});

  factory Worker.fromJson(Map<String, dynamic> json) => _$WorkerFromJson(json);

  Map<String, dynamic> toJson() => _$WorkerToJson(this);
}