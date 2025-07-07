import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/order.dart';
import 'package:ko_radio_mobile/models/order_items.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({this.order, super.key});
  final Order? order;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
 

  @override
  Widget build(BuildContext context) {
    final items = widget.order?.orderItems ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Detalji narudžbe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Narudžba #${widget.order?.orderNumber ?? "-"}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Order Items List
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("Nema stavki u narudžbi."))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final product = item.product;
                        final price = product?.price ?? 0.0;
                      

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            title: Text(product?.productName ?? "Proizvod"),
                            subtitle: Text('Količina: ${item.quantity}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${price.toStringAsFixed(2)} KM'),
                               
                                
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Summary
            const SizedBox(height: 16),
            Text('Broj stavki: ${items.length}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
           
          ],
        ),
      ),
    );
  }
}
