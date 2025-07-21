import 'package:ko_radio_desktop/models/tender_bids.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class TenderBidProvider extends BaseProvider<TenderBid>{
  TenderBidProvider() : super("TenderBid");

  @override
  TenderBid fromJson(data) {
    return TenderBid.fromJson(data);
  }
}