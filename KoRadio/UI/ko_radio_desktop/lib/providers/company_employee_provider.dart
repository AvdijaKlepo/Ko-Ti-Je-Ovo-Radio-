import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class CompanyEmployeeProvider extends BaseProvider<CompanyEmployee> {
  CompanyEmployeeProvider(): super("CompanyEmployee");
  @override
  CompanyEmployee fromJson(data) {
    return CompanyEmployee.fromJson(data);
  }

}