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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

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
      orderProvider = context.read<OrderProvider>();

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
        pageSize: 6,
      );

      orderPagination.addListener(() {
        if (mounted) setState(() {});
      });

      await _refreshWithFilter();
      setState(() {
        _isInitialized = true;
      });
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _refreshWithFilter();
    });
  }

  Future<void> _refreshWithFilter() async {
    final filter = <String, dynamic>{
      'UserId': AuthProvider.user?.userId,
    };

    await orderPagination.refresh(newFilter: filter);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text('Moje narudžbe',style: TextStyle(color:Color.fromRGBO(27, 76, 125, 25),fontFamily: GoogleFonts.lobster().fontFamily),),centerTitle: true,),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshWithFilter,
                    child: orderPagination.items.isEmpty
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
                                    title: Text('Narudžba #${order.orderNumber ?? "-"}',style: TextStyle(color: Colors.white),),
                                    subtitle: Text('Broj stavki: $itemCount \nTrgovina: ${order.orderItems?.map((e) => e.store?.storeName ?? "Nije dostupno").join(', ')}\nStanje: ${order.isShipped==null ? "Poslana" : "Nije poslana"}',style: TextStyle(color: Colors.white),),
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
