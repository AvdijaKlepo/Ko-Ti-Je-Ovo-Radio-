import 'package:flutter/foundation.dart';
import 'package:ko_radio_mobile/models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);
  int get count => _items.length;

  void add(Product p) {
    _items.add(p);
    notifyListeners();
  }

  void remove(Product p) {
    _items.remove(p);
    notifyListeners();
  }

  double get total => _items.fold(0.0, (sum, p) => sum + (p.price ?? 0));
}
