import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class LocationProvider extends BaseProvider<Location>{
  LocationProvider(): super("Location");

  @override
  Location fromJson(data) {
    return Location.fromJson(data);
  }
}
