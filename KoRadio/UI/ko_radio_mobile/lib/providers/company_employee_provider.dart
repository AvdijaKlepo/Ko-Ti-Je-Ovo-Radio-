

import 'package:ko_radio_mobile/models/company_employee.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class CompanyEmployeeProvider extends BaseProvider<CompanyEmployee> {
  CompanyEmployeeProvider(): super("CompanyEmployee");
  @override
  CompanyEmployee fromJson(data) {
    return CompanyEmployee.fromJson(data);
  }

}