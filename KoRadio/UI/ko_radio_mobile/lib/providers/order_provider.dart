import 'package:ko_radio_mobile/models/order.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
 OrderProvider() : super("Order");

  @override
  Order fromJson(data) {
    return Order.fromJson(data);
  }

}