

import 'package:ko_radio_mobile/models/product.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product>{
  ProductProvider(): super("Product");

  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  
  }
}