import 'dart:async';

import 'package:flutter/material.dart';
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
  @override
  void dispose() {
    _debounce?.cancel();
    _userNameController.dispose();

    super.dispose();
  }
    void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _getOrders);
  }
  @override 
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
       orderProvider = context.read<OrderProvider>();
      _getOrders();

    });
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
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 16),
        const Row(
  children: [
    Expanded(flex: 2, child: Text("Broj narudžbe", style: TextStyle(fontWeight: FontWeight.bold))),
    Expanded(flex: 2, child: Text("Korisnik", style: TextStyle(fontWeight: FontWeight.bold))),
    Expanded(flex: 4, child: Text("Stavke narudžbe", style: TextStyle(fontWeight: FontWeight.bold))),
  ],
),


          Expanded(
            child: orderResult == null
                ? const Center(child: CircularProgressIndicator())
                : orderResult!.result.isEmpty
                    ? const Center(child: Text('Nisu pronađene trgovine.'))
                    : ListView.builder(
                       itemBuilder: (context, index) {
  final order = orderResult!.result[index];

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(order.orderNumber?.toString() ?? '-')),
        Expanded(flex: 2, child: Text('${order.user?.firstName ?? ''} ${order.user?.lastName ?? ''}')),
       
      ],
    ),
  );
}

                      ),
          ),
        ],
      ),
    );
  }
}