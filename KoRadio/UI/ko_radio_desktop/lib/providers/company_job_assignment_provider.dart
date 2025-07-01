import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';
import 'package:ko_radio_desktop/screens/company_job.dart';

class CompanyJobAssignmentProvider extends BaseProvider<CompanyJobAssignment> {
  CompanyJobAssignmentProvider(): super("CompanyJobAssignment");
  @override
  CompanyJobAssignment fromJson(data) {
    return CompanyJobAssignment.fromJson(data);
  }
}