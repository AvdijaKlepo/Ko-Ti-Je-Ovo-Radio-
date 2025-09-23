import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/order.dart';
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
        .toSet() ??
    {};

final total = order.orderItems
        ?.map((e) => (e.productPrice ?? 0) * (e.quantity ?? 0))
        .fold(0.0, (sum, el) => sum + el) ??
    0.0;

return Dialog(
  surfaceTintColor: Colors.white,
  insetPadding: const EdgeInsets.all(24),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: SizedBox(
    width: 500,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.receipt_long, size: 28, color: Colors.white),
           
                const Text(
                  "Detalji narudžbe",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                
              ],
            ),
          ),

          // 🔹 Order metadata
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildRow("Broj narudžbe:", '${order.orderNumber}'),
                _buildRow(
                  "Datum:",
                  order.createdAt != null
                      ? DateFormat("dd.MM.yyyy").format(order.createdAt!)
                      : "-",
                ),
                _buildRow("Korisnik:",
                    "${order.user?.firstName ?? ''} ${order.user?.lastName ?? ''}"),
                _buildRow("Poslano:", order.isShipped == true ? "Da" : "Ne"),
                _buildRow("Otkazano:", order.isCancelled == true ? "Da" : "Ne"),
                _buildRow("Unikatnih proizvoda:",
                    uniqueProducts.length.toString()),
              ],
            ),
          ),

          const Divider(height: 24),

     ...uniqueProducts.map((product) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildRow(
                    product!.productName ?? '-',
                    widget.order.orderItems
                            ?.where((element) =>
                                element.product?.productId == product.productId)
                            .map((e) => e.productPrice ?? 0)
                            .reduce((value, element) => value + element)
                            .toString() ??
                        '-',
                  ),
                );
              }),
          const Divider(height: 24),

          // 🔹 Products list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Proizvodi",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ...?order.orderItems?.map((item) {
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
                          child: Text(item.product?.productName ?? "-",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                        Expanded(
                          child: Text("x${item.quantity}",
                              textAlign: TextAlign.center),
                        ),
                        Expanded(
                          child: Text(
                            "${_currencyFormat.format((item.productPrice ?? 0) * (item.quantity ?? 0))}",
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 🔹 Total
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
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
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    child: Text(
                      "${_currencyFormat.format(total)} KM",
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Action button
          if (widget.order.isCancelled != true &&
              widget.order.isShipped != true)
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 24, top: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await orderProvider.update(order.orderId, {
                        'orderNumber': order.orderNumber,
                        'userId': order.user?.userId,
                        'isCancelled': order.isCancelled,
                        'isShipped': true,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Korisnik uspješno obaviješten.")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Greška tokom slanja obaviještenja. Pokušajte ponovo.")),
                      );
                    }
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Označi kao poslanu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  ),
);

  }
}
