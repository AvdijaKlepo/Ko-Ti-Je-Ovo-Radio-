import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/product.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({this.product,super.key});
  final Product? product;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalji")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (widget.product?.productName != null)
              Text(widget.product!.productName!),
            if (widget.product?.productDescription != null)
              Text(widget.product!.productDescription!),
            if (widget.product?.price != null)
              Text('Cena: ${widget.product!.price}'),
            widget.product?.image != null ? 
              imageFromString(widget.product!.image!, height: 200, width: 200) : 
              Image.asset('assets/images/logo.png'),

              IconButton(
  icon: const Icon(Icons.add_shopping_cart),
  onPressed: () {
    context.read<CartProvider>().add(widget.product!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.product?.productName} dodan u košaricu.')),
    );
  },
)

          ],
        ),
      ),
    );
  }
}