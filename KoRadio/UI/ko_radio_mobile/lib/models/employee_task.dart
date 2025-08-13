import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_mobile/models/company_employee.dart';

part 'employee_task.g.dart';

@JsonSerializable()
class EmployeeTask {
  int employeeTaskId;
  String? task;
  bool? isFinished;
  int? companyEmployeeId;
  DateTime? createdAt;
  int? jobId;
  int? companyId;
  CompanyEmployee? companyEmployee;

  EmployeeTask({required this.employeeTaskId});
    factory EmployeeTask.fromJson(Map<String, dynamic> json) => _$EmployeeTaskFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$EmployeeTaskToJson(this);

}