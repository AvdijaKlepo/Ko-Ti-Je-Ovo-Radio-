





import 'package:ko_radio_mobile/models/store.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class StoreProvider extends BaseProvider<Store>{
  StoreProvider(): super("Store");

  @override
  Store fromJson(data) {
    return Store.fromJson(data);
  
  }
}
