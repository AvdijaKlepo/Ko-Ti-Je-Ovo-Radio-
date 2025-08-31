import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/product.dart';
import 'package:ko_radio_mobile/models/store.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/user_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProductDetails extends StatefulWidget {
  const ProductDetails({this.product, this.store, super.key});
  final Product? product;
  final Store? store;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late Future<List<Product>> recommendedProducts;
  late UserProvider userProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    if (AuthProvider.user != null && widget.product != null) {
      recommendedProducts = getRecommendedProducts(AuthProvider.user!.userId);
    } else {
      recommendedProducts = Future.value([]);
    }
  }
  Future<List<Product>> getRecommendedProducts(int userId) async {
    if(mounted) setState(() => _isLoading = true);
    try{
      final recommendedProducts = await userProvider.getRecommendedProducts(userId);
      if(mounted) setState(() => _isLoading = false);
      return recommendedProducts;
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text("Proizvod nije pronađen.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalji proizvoda",
          style: TextStyle(
            fontFamily: GoogleFonts.lobster().fontFamily,
            color: const Color.fromRGBO(27, 76, 125, 25),
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
    
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
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

            // Product name
            if (product.productName != null)
              Text(
                'Naziv: ${product.productName}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 12),

            // Product description
            if (product.productDescription != null)
              Text(
                'Specifikacije: ${product.productDescription}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 20),

            // Price
            if (product.price != null)
              Text(
                'Cijena: ${product.price} KM',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                        color: const Color.fromRGBO(27, 76, 125, 25),
                        fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),

            // Store info
            Text(
              'Trgovina: ${widget.store?.storeName ?? "Nepoznata"}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.bottomRight,

              child:   ElevatedButton(onPressed: (){
              context.read<CartProvider>().add(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.productName} dodan u korpu.')),
          );
            }, child: Text('Dodaj u korpu',style: TextStyle(color: Colors.white),)
            
          ,
            style: ElevatedButton.styleFrom(backgroundColor:  Color.fromRGBO(27, 76, 125, 25),elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
            ),
            )
          ,
SizedBox(height: 30,),
            // Recommended products section
            Text(
              'Popularno sa drugim kupcima i trgovinama',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Product>>(
              future: recommendedProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Greška: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nema preporučenih proizvoda.');
                }

                final products = snapshot.data!;
                return Column(
                  children: products.map((p) {
                    return Card(
                      color: const Color.fromRGBO(27, 76, 125, 25),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: p.image != null
                            ? imageFromString(p.image!, width: 50, height: 50)
                            : Image.asset(
                                'assets/images/productPlaceholder.jpg',
                                width: 50,
                                height: 50,
                              ),
                        title: Text(p.productName ?? "Nepoznat proizvod",style: TextStyle(color: Colors.white),),
                        subtitle: Text('${p.price} KM', style: TextStyle(color: Colors.white),),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          color: Colors.white,
                          onPressed: () {
                            context.read<CartProvider>().add(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${p.productName} dodan u korpu.')),
                            );
                          },
                        ),
                        
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



