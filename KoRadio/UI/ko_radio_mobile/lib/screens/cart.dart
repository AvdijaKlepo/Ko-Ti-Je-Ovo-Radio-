import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/order_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/order_list.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  late OrderProvider orderProvider;

  @override
  void initState() {
    super.initState();
    orderProvider = context.read<OrderProvider>();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title:  Text('Vaša korpa',style: TextStyle(color:const Color.fromRGBO(27, 76, 125, 25),fontFamily: GoogleFonts.lobster().fontFamily),),centerTitle: true,),
      body: cart.items.isEmpty
          ? Column(mainAxisAlignment: MainAxisAlignment.center,children: [const Center(child: Text("Korpa je prazna",style: TextStyle(fontWeight: FontWeight.bold),)),
          const SizedBox(height: 10,),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(27, 76, 125, 25)) ,onPressed: () async{
            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrderList()));
          }, child: const Text('Pregled narudžbi',style: TextStyle(color: Colors.white),))],)
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final item = cart.items[i];
                final p = item.product;

                return Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: p.image != null
                              ? imageFromString(p.image!, height: 80, width: 80, fit: BoxFit.cover)
                              : Image.asset('assets/images/productPlaceholder.jpg', height: 80, width: 80,fit: BoxFit.cover,),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.productName ?? '', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text('${p.price?.toStringAsFixed(2)} KM',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Color.fromRGBO(27, 76, 125, 25),
                                  )),
                              const SizedBox(height: 6),
                             
                              Row(
                              
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        cart.update(p, item.quantity - 1);
                                      }
                                    },
                                  ),
                                  Text('${item.quantity}', style: theme.textTheme.titleMedium),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      cart.update(p, item.quantity + 1);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                        
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => cart.remove(p),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ukupno:', style: theme.textTheme.titleMedium),
                      Text('${cart.total.toStringAsFixed(2)} KM',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(27, 76, 125, 25)),
                      icon: const Icon(Icons.shopping_bag,color:Colors.white),
                      label: const Text('Naruči putem PayPal-a',style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PaypalCheckoutView(
                              sandboxMode: true,
                                clientId: dotenv.env['clientId'],
          secretKey: dotenv.env['secretKey'],
                              transactions: [
                                {
                                  "amount": {
                                    "total": cart.total.toStringAsFixed(2),
                                    "currency": "USD",
                                    "details": {
                                      "subtotal": cart.total.toStringAsFixed(2),
                                      "shipping": '0',
                                      "shipping_discount": 0
                                    }
                                  },
                                  "description": "Plaćanje za proizvode",
                                  "item_list": {
                                    "items": cart.items
                                        .map((item) => {
                                              "name": item.product.productName ?? "Proizvod",
                                              "quantity": item.quantity,
                                              "price": item.product.price!.toStringAsFixed(2),
                                              "currency": "USD"
                                            })
                                        .toList(),
                                  }
                                }
                              ],
                              note: "Hvala što koristite našu aplikaciju!",
                              onSuccess: (params) async {
                                DateTime now = DateTime.now();
                                Map<int, List<CartItem>> groupedByStore = {};

for (var item in cart.items) {
  groupedByStore.putIfAbsent(item.product.storeId ?? 0, () => []).add(item);
}

                            
                                try {
                                  for (var entry in groupedByStore.entries) {
  int storeId = entry.key;
  List<CartItem> storeItems = entry.value;

  final orderRequest = {
     "userId": AuthProvider.user!.userId,
                                    "orderNumber": Random().nextInt(100000),
                                    'isCancelled': false,
                                    'isShipped': false,
                                    'createdAt': now.toIso8601String().split('T')[0],
    "orderItems": storeItems.map((item) => {
      "productId": item.product.productId,
      "quantity": item.quantity,
      "storeId": storeId,
    }).toList(),
    
  };

  await orderProvider.insert(orderRequest); 
}

                                    
                
                                
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Narudžba spremljena!")),
                                  );
                                  cart.clear();
                                } catch (e) {
                                  print(e);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Greška pri narudžbi: $e")),
                                  );
                                } finally {
                                  Navigator.of(context).pop();
                                }
                              },
                              onCancel: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Plaćanje otkazano.")),
                                );
                                Navigator.of(context).pop();
                              },
                              onError: (error) {
                                print(error);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Greška tokom plaćanja.")),
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
