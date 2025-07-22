import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/order.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/order_provider.dart';
import 'package:provider/provider.dart';

class StoreOrders extends StatefulWidget {
  const StoreOrders({super.key});

  @override
  State<StoreOrders> createState() => _StoreOrdersState();
}

class _StoreOrdersState extends State<StoreOrders> {
  late OrderProvider orderProvider;
  SearchResult<Order>? orderResult;

   final TextEditingController _userNameController = TextEditingController();
   Timer? _debounce;
  
    void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _getOrders);
  }
  @override 
  void initState() {
    super.initState();
      awaitOrders();
  }

  Future<void> awaitOrders() async {
    orderProvider = context.read<OrderProvider>();
    await _getOrders();
  }

  Future<void> _getOrders() async {
    var filter = {'StoreId':AuthProvider.selectedStoreId};
    try {
      final fetchedOrders = await orderProvider.get(filter: filter);
      setState(() {
        orderResult = fetchedOrders;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ime Korisnika narudžbe',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
              
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 16),
        const Row(
  children: [
    Expanded(flex: 2, child: Text("Broj narudžbe", style: TextStyle(fontWeight: FontWeight.bold))),
    Expanded(flex: 2, child: Text("Datum", style: TextStyle(fontWeight: FontWeight.bold))),
    Expanded(flex: 2, child: Text("Korisnik", style: TextStyle(fontWeight: FontWeight.bold))),
    Expanded(flex: 2, child: Text("Poslano", style: TextStyle(fontWeight: FontWeight.bold))),

      Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.local_shipping, size: 18),
    )),
    Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.delete, size: 18),
    )),
      ],
),


          Expanded(
            child: orderResult == null
                ? const Center(child: CircularProgressIndicator())
                : orderResult!.result.isEmpty
                    ? const Center(child: Text('Nisu pronađene narudžbe.'))
                    : ListView.separated(
                      itemCount: orderResult!.result.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                       itemBuilder: (context, index) {
  final order = orderResult!.result[index];

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(order.orderNumber.toString())),
        Expanded(
          flex:2,
          child:   Text(
              DateFormat('dd.MM.yyyy').format(order.createdAt!),
              
            ),
        )
     ,
  
       Expanded(flex: 2, child: Text('${order.user?.firstName ?? ''} ${order.user?.lastName ?? ''}')),
        Expanded(flex: 2, child: Text(order.isShipped==true ? 'Poslano' : 'Nije poslano')),
        Expanded(
                        flex: 1,
                        child: Checkbox(
                          value: order.isShipped ?? false,
                          onChanged: (val) {
                            setState(() {
                              order.isShipped = val;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Izbriši',
                          onPressed: () {
                            // TODO: Handle soft delete
                          },
                        ),
                      ),        
      ],
    ),
  );
}

                      ),

          ),
            Align(
                  alignment: Alignment.topCenter,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(27, 76, 125, 25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                    ),
                   onPressed: () async {
                  },
                    child: const Text("Označi kao poslano", style: TextStyle(color: Colors.white)),
                  ),
                ),
        ],
      ),
    );
  }
}