import 'package:ko_radio_desktop/models/company_role.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class CompanyRoleProvider extends BaseProvider<CompanyRole> {
  CompanyRoleProvider(): super("CompanyRole");
  @override
  CompanyRole fromJson(data) {
    return CompanyRole.fromJson(data);
  }
}