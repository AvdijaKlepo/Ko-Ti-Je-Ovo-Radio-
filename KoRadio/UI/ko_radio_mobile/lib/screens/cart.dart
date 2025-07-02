import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Vaša košarica')),
      body: ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (_, i) {
          final p = cart.items[i];
          return ListTile(
            leading: p.image != null
                ? imageFromString(p.image!, height: 100, width: 100)
                : Image.asset('assets/images/logo.png'),
            title: Text(p.productName ?? ''),
            subtitle: Text('${p.price?.toStringAsFixed(2)} KM'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => cart.remove(p),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ukupno:', style: Theme.of(context).textTheme.headline6),
            Text('${cart.total.toStringAsFixed(2)} KM',
               style: Theme.of(context).textTheme.headline6),
          ],
        ),
      ),
    );
  }
}