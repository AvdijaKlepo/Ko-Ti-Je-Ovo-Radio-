import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/order.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/messages_provider.dart';
import 'package:ko_radio_desktop/providers/order_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/order_details.dart';
import 'package:provider/provider.dart';

class StoreOrders extends StatefulWidget {
  const StoreOrders({super.key});

  @override
  State<StoreOrders> createState() => _StoreOrdersState();
}

class _StoreOrdersState extends State<StoreOrders> {
  late OrderProvider orderProvider;
  late MessagesProvider messagesProvider;
  late PaginatedFetcher<Order> orderPagination;
  late ScrollController _scrollController;
  SearchResult<Order>? orderResult;

   final TextEditingController _userNameController = TextEditingController();
   bool showShipped = false;
   bool showCancelled = false;
   bool _isInitialized = false;
   bool isLoading = false;
   Timer? _debounce;
   final Set<int> _selectedOrders = {};
  
   
  @override 
  void initState() {
    super.initState();
      orderPagination = PaginatedFetcher<Order>(
        pageSize: 20,
        initialFilter: {},
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
          
        }) async {
          final result = await orderProvider.get(filter: filter);
          return PaginatedResult(result: result.result, count: result.count);
        },
      );
      _scrollController = ScrollController();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 100 &&
            orderPagination.hasNextPage &&
            !orderPagination.isLoading) {
          orderPagination.loadMore();
        }
      });
      orderProvider = context.read<OrderProvider>();
      messagesProvider = context.read<MessagesProvider>();
      orderPagination = PaginatedFetcher<Order>(
        pageSize: 20,
        initialFilter: {},
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
          
        }) async {
          final result = await orderProvider.get(filter: filter);
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));
      
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await orderPagination.refresh(newFilter: {
        'StoreId': AuthProvider.selectedStoreId,
        'IsShipped': showShipped,
        'IsCancelled': showCancelled,
      });
      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
     
  
    });
  }

 void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _refreshWithFilter);
  }
  Future<void> _refreshWithFilter() async {
    setState(() => isLoading = true);
    final filter =<String, dynamic> {
      'StoreId': AuthProvider.selectedStoreId,
      'IsShipped': showShipped,
      'IsCancelled': showCancelled,
  
    };
    if(_userNameController.text.trim().isNotEmpty)
    {
      filter['Name'] = _userNameController.text.trim();
    }
   
    await orderPagination.refresh(newFilter: filter);
    setState(() => isLoading = false);
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
  Future<void> _showCancellDialog(Order order) async {
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Otkaži?'),
        content:
            const Text('Jeste li sigurni da želite otkazati ovu narudžbu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              try {
  await orderProvider.delete(order.orderId);
  await messagesProvider.insert({
    'message1': 'Narudžba ${order.orderNumber} je otkazana.',
    'userId':order.user?.userId,
    'isOpened': false,
    'createdAt': DateTime.now().toIso8601String(),
  });

  orderPagination.refresh(newFilter: {
    'StoreId': AuthProvider.selectedStoreId,
    'IsShipped': showShipped,
    'IsCancelled': showCancelled,
  });
  if (!mounted) return;
} on Exception {
  
  ScaffoldMessenger.of(context).showSnackBar(
   
    const SnackBar(content: Text('Greška pri otkazivanju. Pokušajte ponoovo.')),
  );
  
}
              Navigator.of(context).pop(true);
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if(!_isInitialized) return const Center(child: CircularProgressIndicator());
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
              Row(
                children: [
                  const Text("Prikaži poslane"),
                  Switch(
                    value: showShipped,
                    onChanged: (val) {
                      setState(() => showShipped = val);
                      _onSearchChanged();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("Prikaži otkazane"),
                  Switch(
                    value: showCancelled,
                    onChanged: (val) {
                      setState(() => showCancelled = val);
                      _onSearchChanged();
                    },
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 16),
         Row(
  children: [
    const Expanded(flex: 2, child: Text("Broj narudžbe", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 2, child: Text("Datum", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 2, child: Text("Korisnik", style: TextStyle(fontWeight: FontWeight.bold))),
 
    const Expanded(flex: 2, child: Text("Poslano", style: TextStyle(fontWeight: FontWeight.bold))),
 const Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.receipt_long, size: 18),
    )),
      if(!showShipped && !showCancelled)
      const Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.local_shipping, size: 18),
    )),
    if(!showShipped && !showCancelled)
    const Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.delete, size: 18),
    )),
      ],
),


        Expanded(
            child: orderPagination.isLoading && orderPagination.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : orderPagination.items.isEmpty
                    ? const Center(child: Text('Nisu pronađene narudžbe.'))
                    : ListView.separated(
                        controller: _scrollController,
                        itemCount: orderPagination.items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final order = orderPagination.items[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: Text(order.orderNumber.toString())),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    DateFormat('dd.MM.yyyy').format(order.createdAt!),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('${order.user?.firstName ?? ''} ${order.user?.lastName ?? ''}'),
                                ),
                                
                                Expanded(
                                  flex: 2,
                                  child: Text(order.isShipped == true ? 'Poslano' : 'Nije poslano'),
                                ),
                                Expanded(flex:1,child: IconButton(
                                  icon: const Icon(Icons.receipt_long),
                                  tooltip: 'Prikaži detalje',
                                  onPressed: () async {
                                   await showDialog(context: context, builder: (context) => OrderDetails(order: order));
                                   await orderPagination.refresh(newFilter: {
                                  'StoreId': AuthProvider.selectedStoreId,
                                  'IsShipped': showShipped,
                                });
                                  },
                                )),
                                if(!showShipped && !showCancelled)
                                Expanded(
                                  flex: 1,
                                  child: Checkbox(
                                    value: _selectedOrders.contains(order.orderId),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedOrders.add(order.orderId);
                                        } else {
                                          _selectedOrders.remove(order.orderId);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                if(!showShipped && !showCancelled)
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Otkaži',
                                    onPressed: () {
                                     _showCancellDialog(order);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _selectedOrders.isEmpty
                  ? null
                  : () async {
                      try {
                        for (var order in orderPagination.items.where((o) => _selectedOrders.contains(o.orderId))) {
                          await orderProvider.update(order.orderId, {
                            'orderNumber': order.orderNumber,
                            'userId': order.user?.userId,
                            'isCancelled': order.isCancelled,
                            'isShipped': true, 
                          });
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Odabrane narudžbe su označene kao poslane.")),
                        );

             
                        await orderPagination.refresh(newFilter: {
                          'StoreId': AuthProvider.selectedStoreId,
                          'IsShipped': showShipped,
                        });

                        setState(() => _selectedOrders.clear());
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Greška pri ažuriranju: $e")),
                        );
                      }
                    },
              child: const Text("Označi odabrane kao poslane", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}