

import 'package:ko_radio_mobile/models/company_job_assignment.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class CompanyJobAssignmentProvider extends BaseProvider<CompanyJobAssignment> {
  CompanyJobAssignmentProvider(): super("CompanyJobAssignment");
  @override
  CompanyJobAssignment fromJson(data) {
    return CompanyJobAssignment.fromJson(data);
  }
}