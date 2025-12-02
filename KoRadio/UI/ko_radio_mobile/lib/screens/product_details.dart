import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/product.dart';
import 'package:ko_radio_mobile/models/store.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/product_provider.dart'; // Ensure this is imported
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
  late ProductProvider productProvider; // Add ProductProvider
  bool _isLoading = false;
  
  // Create a local variable to hold the product data
  Product? _displayedProduct;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    productProvider = context.read<ProductProvider>(); // Initialize ProductProvider
    
    // Initialize displayed product with the passed widget data
    _displayedProduct = widget.product;

    if (AuthProvider.user != null && widget.product != null) {
      recommendedProducts = getRecommendedProducts(AuthProvider.user!.userId);
      // Fetch full details to get fresh stockQuantity
      _fetchFullProduct(widget.product!.productId!);
    } else {
      recommendedProducts = Future.value([]);
    }
  }

  // NEW METHOD: Fetch full product details (including stock)
  Future<void> _fetchFullProduct(int productId) async {
    try {
      // Assuming you have a getById or similar method in your ProductProvider
      // If not, you need to implement the API call here.
      var fullProduct = await productProvider.getById(productId); 
      
      if (mounted && fullProduct != null) {
        setState(() {
          _displayedProduct = fullProduct;
        });
      }
    } catch (e) {
      print("Error fetching full product details: $e");
    }
  }

  Future<List<Product>> getRecommendedProducts(int userId) async {
    // Note: We don't want to trigger global loading for background recs
    // so we kept this local or silent.
    try {
      final recommendedProducts = await userProvider.getRecommendedProducts(userId);
      return recommendedProducts;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // USE _displayedProduct instead of widget.product
    final product = _displayedProduct;
    final cart = context.watch<CartProvider>();

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text("Proizvod nije pronađen.")),
      );
    }

    final cartQuantity = cart.items
        .where((item) => item.product.productId == product.productId)
        .fold<int>(0, (sum, item) => sum + item.quantity);

    // Now this will use the updated stockQuantity once _fetchFullProduct completes
    final remainingQty = (product.stockQuantity ?? 0) - cartQuantity;

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
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: product.image != null
                      ? imageFromString(
                          product.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Image.asset(
                          'assets/images/productPlaceholder.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                ),
              ),
              if (product.isOnSale == true)
                Positioned(
                    top: 0,
                    left: 0,
                    child: Banner(
                      message: "Akcija",
                      location: BannerLocation.topStart,
                      color: Colors.redAccent,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )),
            ]),
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
            product.isOnSale == false
                ? Text(
                    'Cijena: ${product.price} KM',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color.fromRGBO(27, 76, 125, 25),
                        fontWeight: FontWeight.bold),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stara cijena: ${product.price} KM',
                        style: const TextStyle(decoration: TextDecoration.lineThrough),
                      ),
                      Text(
                        'Akcijska cijena: ${product.salePrice} KM',
                      ),
                      if (product.saleExpires != null)
                        Text(
                          'Ponuda traje do: ${DateFormat('dd.MM.yyyy').format(product.saleExpires!)}',
                        ),
                    ],
                  ),

            const SizedBox(height: 5),
            
            // Stock Quantity Display
            Text(
              'Na lageru: ${product.stockQuantity ?? "..."} komada', // Show ... while loading if null
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color.fromRGBO(27, 76, 125, 25),
                  fontWeight: FontWeight.bold),
            ),

            // Store info
            Text(
              'Trgovina: ${widget.store?.storeName ?? "..."}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  final cart = context.read<CartProvider>();

                  if (remainingQty > 0) {
                    cart.add(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.productName} dodan u korpu.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.productName} nije na lageru.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Dodaj u korpu',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),

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
                        title: Text(
                          p.productName ?? "Nepoznat proizvod",
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              '${p.price} KM',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        trailing: Wrap(
                          children: [
                            
                            IconButton(
                              icon: const Icon(Icons.arrow_circle_right_sharp),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ProductDetails(
                                          product: p,
                                          // Note: Recommended products often don't include store details.
                                          // You might want to pass widget.store if it's the same store, 
                                          // or handle null store in the UI.
                                          store: widget.store, 
                                        )));
                              },
                            ),
                           
                            
                            
                          ],
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