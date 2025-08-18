import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/order.dart';
import 'package:ko_radio_desktop/models/order_items.dart';
import 'package:ko_radio_desktop/providers/order_provider.dart';
import 'package:provider/provider.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({required this.order, super.key});
  final Order order;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  late OrderProvider orderProvider;
  final _currencyFormat = NumberFormat.currency(locale: 'hr', symbol: 'KM');
  @override
  initState() {
    super.initState();
    orderProvider = context.read<OrderProvider>();
  }



  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 140,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final uniqueProducts = order.orderItems
        ?.map((e) => e.product)
        .where((p) => p != null)
        .toSet() ?? {};
var total =  order.orderItems?.map((e) => e.product!.price! * e.quantity!).toList().reduce((value, element) => value + element);
    return Dialog(

      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: 
      
      SizedBox(
        width: 500,
        child: Stack(
          children: [
           
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: SvgPicture.asset(
                  'assets/images/undraw_data-input_whqw.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
        
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
          
                    const Row(
                      children: [
                        Icon(Icons.receipt_long,
                            size: 28, color: Colors.blueGrey),
                        SizedBox(width: 10),
                        Text("Detalji narudžbe",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 32),
        
                    _buildRow("Broj narudžbe:", '${order.orderNumber}'),
                    _buildRow(
                        "Datum:",
                        order.createdAt != null
                            ? DateFormat("dd.MM.yyyy")
                                .format(order.createdAt!)
                            : "-"),
                    _buildRow("Korisnik:",
                        "${order.user?.firstName ?? ''} ${order.user?.lastName ?? ''}"),
                    _buildRow("Poslano:", order.isShipped ?? false ? "Da" : "Ne"),
                    _buildRow("Otkazano:", order.isCancelled ?? false ? "Da" : "Ne"),
                    _buildRow('Unikatnih proizvoda', order.orderItems?.length.toString() ?? '-'),
                


...uniqueProducts.map((product) {
  return _buildRow(
    product!.productName ?? '-',
    product.price?.toString() ?? '-',
  );
}),

                    
        
                    const Divider(height: 32),
        
              
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Proizvodi",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        ...?order.orderItems?.map((item) {
                          final product = item.product;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(product?.productName ?? "-",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500))),
                                Expanded(
                                    child: Text("x${item.quantity}",
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    child: Text(
                                        _currencyFormat.format(
                                            (product?.price ?? 0) *
                                                (item.quantity ?? 0)),
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600))),

                                           
                                              
                              ],
                            ),
                          );
                        }),
                      
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                              children: [
                                const Expanded(
                                    flex: 2,
                                    child: Text("Ukupna cijena",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500))),
                               
                                Expanded(
                                    child: Text(
                                        '${total.toString()} KM',
                                        
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600))),

                                           
                                              
                              ],
                            )
                    ),
                    if(widget.order.isCancelled!=true && widget.order.isShipped!=true)
                    ElevatedButton(onPressed: () async{
                     await orderProvider.update(widget.order.orderId,{'orderNumber': order.orderNumber,
                            'userId': order.user?.userId,
                            'isCancelled': order.isCancelled,
                            'isShipped': true,});
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ), child: const Text('Označi kao poslanu.',style: TextStyle(color: Colors.white),),
                    )
                  
                  ],
               
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
