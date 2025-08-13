import 'package:json_annotation/json_annotation.dart';

import 'package:ko_radio_mobile/models/company_employee.dart';
import 'package:ko_radio_mobile/models/job.dart';

part 'company_job_assignment.g.dart';

@JsonSerializable()
class CompanyJobAssignment {
  int? companyJobId;
	int? companyEmployeeId;
	int? jobId;
	DateTime assignedAt;
  CompanyEmployee? companyEmployee;
  Job? job;

	CompanyJobAssignment(this.companyEmployeeId,this.jobId,this.assignedAt,);

	factory CompanyJobAssignment.fromJson(Map<String, dynamic> json) => _$CompanyJobAssignmentFromJson(json);

	Map<String, dynamic> toJson() => _$CompanyJobAssignmentToJson(this);
}