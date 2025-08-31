import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/product.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/models/store.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/product_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';

import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/product_details.dart';
import 'package:provider/provider.dart';

class ProductTypeList extends StatefulWidget {
  const ProductTypeList({this.store, super.key});
  final Store? store;

  @override
  State<ProductTypeList> createState() => _ProductTypeListState();
}

class _ProductTypeListState extends State<ProductTypeList> {
  int? _selectedServiceId;

  late ProductProvider productProvider;
  late ServiceProvider serviceProvider;
  SearchResult<Service>? serviceResult;
  late PaginatedFetcher<Product> productPagination;
  late final ScrollController _scrollController;

  bool _isInitialized = false;
  String _searchQuery = "";
  List<DropdownMenuItem<int>> serviceDropdownItems = [];
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading=true;
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          productPagination.hasNextPage &&
          !productPagination.isLoading) {
        productPagination.loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      productProvider = context.read<ProductProvider>();
      serviceProvider = context.read<ServiceProvider>();
     await _getServices();
      productPagination = PaginatedFetcher<Product>(
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
        }) async {
          final result = await productProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult<Product>(
            result: result.result,
            count: result.count,
          );
        },
        pageSize: 6,
      );

      productPagination.addListener(() {
        if (mounted) setState(() {});
      });

      Map<String, dynamic>? filter;
      if (widget.store != null) {
        filter = {'storeId': widget.store?.storeId};
      }
      

      await productPagination.refresh(newFilter: filter);
      setState(() {
        _isInitialized = true;
        _isLoading=false;
      });
    });
  }
  Future<void> _getServices() async {
  try {
    var fetchedServices = await serviceProvider.get();
    setState(() {
      serviceResult = fetchedServices;
      serviceDropdownItems = [
        const DropdownMenuItem(value: null, child: Text("Svi tipovi")),
        ...fetchedServices.result
            .map((s) => DropdownMenuItem(value: s.serviceId, child: Text(s.serviceName)))
            
      ];
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query.trim();
      _refreshWithFilter();
    });
  }

  Future<void> _refreshWithFilter() async {
    setState(() {
      _isLoading=true;
    });
    final filter = <String, dynamic>{};
    if (_searchQuery.isNotEmpty) {
      filter['Name'] = _searchQuery;
    }
    if (_selectedServiceId != null) {
    filter['ServiceId'] = _selectedServiceId;
  }


    filter["storeId"] = widget.store?.storeId;
    await productPagination.refresh(newFilter: filter);
    setState(() {
      _isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
       if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
 

    return Scaffold(
      appBar: AppBar(title:  Text("${widget.store?.storeName}",style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: const Color.fromRGBO(27, 76, 125, 25),letterSpacing: 1.2),),
      centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshWithFilter,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Pretraži proizvode...",
                          prefixIcon: const Icon(Icons.search,color: Color.fromRGBO(27, 76, 125, 25),),
                          
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: 12),
                      
                     if (serviceDropdownItems.isNotEmpty)
  DropdownButtonFormField<int?>(
    iconDisabledColor: Colors.grey,
    iconEnabledColor: const Color.fromRGBO(27, 76, 125, 25),
    value: _selectedServiceId,
    decoration: InputDecoration(
      
   
      labelText: "Tip proizvoda",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    items: serviceDropdownItems,
    onChanged: (value) {
      setState(() => _selectedServiceId = value);
      _refreshWithFilter();
    },
  ),

                    ],
                  ),
                ),
              ),



              _isLoading ? const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())) :
            productPagination.items.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          "Nema pronađenih proizvoda.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  :
                 
                   SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3 / 4,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < productPagination.items.length) {
                              final product = productPagination.items[index];
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetails(product: product, store: widget.store),
                                  ));
                                },
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: product.image != null
                                            ? imageFromString(
                                                product.image!,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset('assets/images/productPlaceholder.jpg',fit: BoxFit.cover,),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration:  BoxDecoration(
                                            backgroundBlendMode: BlendMode.screen,
                                            color: Colors.white,
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(16),
                                            ),
                                          ),
                                          child:
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                               Text(
                                            product.productName ?? "",
                                            style: const TextStyle(
                                              color: Colors.black,
                                             
                                              fontSize: 16,
                                         
                                            ),


                                            maxLines:1,
                                            overflow: TextOverflow.ellipsis,
                                          

                                          ),
                                           Text(
                                            '${product.price?.toString()} KM' ?? "",
                                            style: const TextStyle(
                                              color: Colors.black,
                                             
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            
                                          ),
                                              
                                            ],
                                          )
                                          
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Material(
                                          color: Colors.white,
                                          shape: const CircleBorder(),
                                          elevation: 2,
                                          child: IconButton(
                                            icon: const Icon(Icons.add_shopping_cart),
                                            onPressed: () {
                                              context.read<CartProvider>().add(product);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        '${product.productName} dodan u korpu.')),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (productPagination.hasNextPage) {
                              return const Padding(
                                padding: EdgeInsets.all(8),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                          childCount:
                              productPagination.items.length + (productPagination.hasNextPage ? 1 : 0),
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
