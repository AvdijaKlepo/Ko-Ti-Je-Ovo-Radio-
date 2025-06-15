
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class CompanyProvider extends BaseProvider<Company> {
  CompanyProvider(): super("Company");
  @override
  Company fromJson(data) {
    return Company.fromJson(data);
  }
}