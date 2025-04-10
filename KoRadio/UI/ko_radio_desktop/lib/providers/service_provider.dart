import 'package:ko_radio_desktop/models/service.dart';

import 'package:ko_radio_desktop/providers/base_provider.dart';

class ServiceProvider extends BaseProvider<Service>{
  ServiceProvider(): super("Service");

  @override
  Service fromJson(data) {
    return Service.fromJson(data);
  }
}
