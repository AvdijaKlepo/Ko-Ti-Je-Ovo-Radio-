import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class CompanyJobAssignmentProvider extends BaseProvider {
  CompanyJobAssignmentProvider(): super("CompanyJobAssignment");
  @override
  CompanyJobAssignment fromJson(data) {
    return CompanyJobAssignment.fromJson(data);
  }
}