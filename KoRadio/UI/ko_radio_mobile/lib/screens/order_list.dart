import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/order.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/order_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/order_details.dart';
import 'package:provider/provider.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late OrderProvider orderProvider;
  late PaginatedFetcher<Order> orderPagination;
  late final ScrollController _scrollController;

  bool _isInitialized = false;
  bool _isLoading=false;
  Timer? _debounce;
     bool? isShipped=false;
    bool? isCancelled=false;


  String _selectedSegment = "made";

  @override
  void initState() {
    super.initState(); 

      setState(() {
        _isLoading=true;
      });
  orderProvider = context.read<OrderProvider>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          orderPagination.hasNextPage &&
          !orderPagination.isLoading) {
        orderPagination.loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
    
    

      orderPagination = PaginatedFetcher<Order>(
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
        }) async {
          final result = await orderProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult<Order>(
            result: result.result,
            count: result.count,
          );
        },
        pageSize: 12,
      );

      orderPagination.addListener(() {
        if (mounted) setState(() {});
      });
     
      await _refreshWithFilter();
      if(!mounted) return;
      setState(() {
        _isInitialized = true;
        _isLoading=false;
      });
    });
  }

 Future<void> _refreshWithFilter() async {


  setState(() => _isLoading = true);

  final filter = <String, dynamic>{
    'UserId': AuthProvider.user?.userId,
  };

  switch (_selectedSegment) {
    case "made":
      filter['IsShipped'] = false;
      filter['IsCancelled'] = false;
      break;
    case "shipped":
      filter['IsShipped'] = true;
      filter['IsCancelled'] = false;
      break;
    case "cancelled":
      filter['IsShipped'] = false;
      filter['IsCancelled'] = true;
      break;
  }

  await orderPagination.refresh(newFilter: filter);

  if (!mounted) return;
  setState(() => _isLoading = false);
}


  void _onSegmentChanged(String segment) {
  if (_isLoading) return; // skip if already refreshing
  setState(() => _selectedSegment = segment);
  _refreshWithFilter();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Moje narudžbe',
          style: TextStyle(
            color: Color.fromRGBO(27, 76, 125, 25),
            fontFamily: GoogleFonts.lobster().fontFamily,
          ),
        ),
        centerTitle: true,
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // SegmentedButton filter
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: "made", label: Text("Kreirane")),
                      ButtonSegment(value: "shipped", label: Text("Poslane")),
                      ButtonSegment(value: "cancelled", label: Text("Otkazane")),
                    ],
                    selected: {_selectedSegment},
                    onSelectionChanged: (newSelection) {
                      _onSegmentChanged(newSelection.first);
                    },
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshWithFilter,
                    child: _isLoading ?
                     const Center(child: CircularProgressIndicator()):
                     orderPagination.items.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 50),
                              Center(child: Text("Nema narudžbi.")),
                            ],
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: orderPagination.items.length + 1,
                            itemBuilder: (context, index) {
                              
                              if (index < orderPagination.items.length) {
                                final order = orderPagination.items[index];
                                final itemCount = order.orderItems?.length ?? 0;

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    tileColor: Color.fromRGBO(27, 76, 125, 25),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text(
                                      'Narudžba #${order.orderNumber ?? "-"}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      'Broj stavki: $itemCount \nTrgovina: ${order.orderItems?.first.store?.storeName}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    trailing: const Icon(Icons.chevron_right, color: Colors.white),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => OrderDetails(order: order),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }

                              if (orderPagination.hasNextPage) {
                                return const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
