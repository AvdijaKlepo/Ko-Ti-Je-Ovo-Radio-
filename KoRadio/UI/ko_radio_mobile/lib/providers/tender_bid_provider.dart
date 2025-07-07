import 'package:ko_radio_mobile/models/tender_bids.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class TenderBidProvider extends BaseProvider<TenderBid>{
  TenderBidProvider() : super("TenderBid");

  @override
  TenderBid fromJson(data) {
    return TenderBid.fromJson(data);
  }
}