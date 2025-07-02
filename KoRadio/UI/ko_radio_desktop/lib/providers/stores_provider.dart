import 'package:ko_radio_desktop/providers/base_provider.dart';

import '../models/store.dart';

class StoreProvider extends BaseProvider<Store>{
  StoreProvider(): super("Store");

  @override
  Store fromJson(data) {
    return Store.fromJson(data);
  
  }
}
