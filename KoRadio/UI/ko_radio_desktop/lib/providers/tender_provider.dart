


import 'package:ko_radio_desktop/models/tender.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class TenderProvider extends BaseProvider<Tender>{
  TenderProvider() : super("Tender");

  @override
  Tender fromJson(data) {
    return Tender.fromJson(data);

  }
}