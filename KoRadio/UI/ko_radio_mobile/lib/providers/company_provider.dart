import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class CompanyProvider extends BaseProvider<Company> {
  CompanyProvider() : super("Company");

  @override
  Company fromJson(data) {
    return Company.fromJson(data);
  }
}