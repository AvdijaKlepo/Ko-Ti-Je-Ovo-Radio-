

import 'package:ko_radio_desktop/models/order.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
 OrderProvider() : super("Order");

  @override
  Order fromJson(data) {
    return Order.fromJson(data);
  }

}