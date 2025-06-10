
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class LocationProvider extends BaseProvider<Location>{
  LocationProvider(): super("Location");

  @override
  Location fromJson(data) {
    return Location.fromJson(data);
  }
}
