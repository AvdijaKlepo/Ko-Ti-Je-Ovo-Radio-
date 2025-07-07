import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/product.dart';
import 'package:ko_radio_mobile/models/store.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({this.product, this.store, super.key});
  final Product? product;
  final Store? store;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text("Proizvod nije pronađen.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Detalji proizvoda")),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromRGBO(27, 76, 125, 25),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text("Dodaj u košaricu"),
        onPressed: () {
          context.read<CartProvider>().add(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.productName} dodan u košaricu.')),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product.image != null
                  ? imageFromString(
                      product.image!,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/productPlaceholder.jpg',
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 20),

    
            if (product.productName != null)
              Text(
                product.productName!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

            const SizedBox(height: 12),

  
            if (product.productDescription != null)
              Text(
                product.productDescription!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

            const SizedBox(height: 20),

       
            if (product.price != null)
              Text(
                'Cijena: ${product.price} KM',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Color.fromRGBO(27, 76, 125, 25),
                      fontWeight: FontWeight.bold,
                    ),
              ),

            const SizedBox(height: 20),

            // Store Info
            Text(
              'Trgovina: ${widget.store?.storeName ?? "Nepoznata"}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
