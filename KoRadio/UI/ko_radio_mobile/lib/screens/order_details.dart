import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/order.dart';


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
      appBar: AppBar(title:  Text('Detalji narudžbe', style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25),fontFamily: GoogleFonts.lobster().fontFamily),),centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Broj narudžbe: ${widget.order?.orderNumber ?? "-"}',
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
                            tileColor: Color.fromRGBO(27, 76, 125, 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(product?.productName ?? "Proizvod",style: TextStyle(color: Colors.white),),
                            subtitle: Text('Količina: ${item.quantity}\nUkupno plaćeno: ${item.quantity!*item.productPrice!} KM',style: TextStyle(color: Colors.white),),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${item.productPrice!.toStringAsFixed(2)} KM',style: TextStyle(color: Colors.white),),
                               
                                
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Summary
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unikatnih proizvoda: ${items.length}',
                    style: Theme.of(context).textTheme.bodyMedium),
                    Text('Ukupno: ${widget.order!.price} KM',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
           
          ],
        ),
      ),
    );
  }
}
