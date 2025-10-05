import 'package:flutter/foundation.dart';
import 'package:ko_radio_mobile/models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.fold(0.0, (sum, item) => sum + ((item.product.isOnSale==false ? item.product.price  ?? 0: item.product.salePrice ?? 0) * item.quantity));

  void add(Product product) {
    final index = _items.indexWhere((item) => item.product.productId == product.productId);
    if (index != -1) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }
  



  void remove(Product product) {
    _items.removeWhere((item) => item.product.productId == product.productId);
    notifyListeners();
  }

  void clear(){
    _items.clear();
    notifyListeners();
  }
  void update(Product product, int quantity) {
  final index = _items.indexWhere((e) => e.product.productId == product.productId);
  if (index != -1) {
    _items[index].quantity = quantity;
    notifyListeners();
  }
}

}


class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
