import 'package:ko_radio_desktop/models/product.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product>{
  ProductProvider(): super("Product");

  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  
  }
}