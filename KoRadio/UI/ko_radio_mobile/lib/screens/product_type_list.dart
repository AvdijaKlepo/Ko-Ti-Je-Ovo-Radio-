import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  bool _showOutOfStock=false;
  bool _showSale=false;
  


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
          !productPagination.isLoading &&
          !_isLoading) {
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
        filter = {'storeId': widget.store?.storeId,
        'OutOfStock': _showOutOfStock,
        'OnSale': _showSale};
      }
      

      await productPagination.refresh(newFilter: filter);
       final now = DateTime.now();
  final expiredSales = productPagination.items
      .where((p) => p.saleExpires != null && p.saleExpires!.isBefore(now) && p.isOnSale==true)
      .toList();
      try {
  if (expiredSales.isNotEmpty) {
    for (var p in expiredSales) {
      await productProvider.update(p.productId, {
        'productName': p.productName,
        'productDescription': p.productDescription,
        'price': p.price,
        'stockQuantity': p.stockQuantity,
        'isOnSale': false,
        'salePrice': null,
        'saleExpires': null,
        'isDeleted': false,
        'image': p.image,
        'serviceId': p.productsServices?.map((ps) => ps.serviceId).toList(),
      });
    }
    
  
    // Refresh after updates
    await productPagination.refresh(newFilter: filter);
    
    
  }
} on Exception catch (e) {
  if(!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Došlo je do greške tokom ažuriranja akcije. Pokušajte ponovo.")),
  );
}
      if(!mounted) return;
      setState(() {
        _isInitialized = true;
        _isLoading=false;
      });
    });
  }

  Future<void> _getServices() async {
  try {
    var fetchedServices = await serviceProvider.get();
    if(!mounted) return;
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

  void _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      _searchQuery = query.trim();
      await _refreshWithFilter();
    });
  }

  Future<void> _refreshWithFilter() async {
    if(_isLoading) return;
    setState(() {
      _isLoading=true;
    });
    final filter = <String, dynamic>{
      'OutOfStock': _showOutOfStock,
      'OnSale': _showSale,
    };
    if (_searchQuery.isNotEmpty) {
      filter['Name'] = _searchQuery;
    }
    if (_selectedServiceId != null) {
    filter['ServiceId'] = _selectedServiceId;
  }
 
 
  


    filter["storeId"] = widget.store?.storeId;
    if(!mounted) return;
    await productPagination.refresh(newFilter: filter);
    if(!mounted) return;
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
      scrolledUnderElevation: 0,
      ),
      body: PageView(
        children:[ SafeArea(
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
          SizedBox(
                            width: double.maxFinite,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                DropdownButtonFormField<int?>(
                                  isExpanded: true,
                                  iconDisabledColor: Colors.grey,
                                  iconEnabledColor:
                                      const Color.fromRGBO(27, 76, 125, 25),
                                  value: _selectedServiceId,
                                  decoration: InputDecoration(
                                    labelText: "Tip proizvoda",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  items: serviceDropdownItems,
                                  onChanged: (value) {
                                    setState(() => _selectedServiceId = value);
                                    _refreshWithFilter();
                                  },
                                ),
                               
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
  spacing: 8,
  children: [
    FilterChip(
      label: const Text("Van lagera"),
      selected: _showOutOfStock,
      onSelected: (val) {
        setState(() => _showOutOfStock = val);
        _refreshWithFilter();
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    ),
    FilterChip(
      label: const Text("Na akciji"),
      selected: _showSale,
      onSelected: (val) {
        setState(() => _showSale = val);
        _refreshWithFilter();
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    ),
  ],
)

                              ],
                            ),
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
final cart = context.watch<CartProvider>();


final cartQuantity = cart.items
    .where((item) => item.product.productId == product.productId)
    .fold<int>(0, (sum, item) => sum + item.quantity);

final remainingQty = (product.stockQuantity ?? 0) - cartQuantity;



                               
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
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset('assets/images/productPlaceholder.jpg',fit: BoxFit.cover,),
                                        ),
                                       
                                        if (product.isOnSale == true)
        const Positioned(
          top: 0,
          left: 0,
          child: Banner(
            message: "Akcija",
            location: BannerLocation.topStart,
            color: Colors.redAccent, 
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        
                                      ),
                                       
                                    
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
        
                                          child: Container(
        
                                            padding: const EdgeInsets.all(12),
                                            decoration:   BoxDecoration(
                                              
                                              color: product.isOnSale==false ? Colors.white : Colors.yellow,
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
                                            product.isOnSale==false ?
                                             Text(
                                              '${product.price?.toString()} KM' ?? "",
                                              style: const TextStyle(
                                                color: Colors.black,
                                               
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              
                                            ):
                                       
                   
                    Text('Akcijska cijena: ${product.salePrice} KM',
                   ),
                  
              
                                                
                                              ],
                                            )
                                            
                                          ),
                                        ),
                                       if (product.isOutOfStock == false)
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
  final cart = context.read<CartProvider>();

  if (remainingQty > 0) {
    cart.add(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.productName} dodan u korpu.')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.productName} nije na lageru.')),
    );
  }
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
        _buildStoreDetails(widget.store!)
        ]
      ),
    );
  }

  Widget _buildStoreDetails(Store store) {
    if (store == null) {
      return const Center(child: Text("Prodavnica nije pronađena."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: store!.image != null
                ? imageFromString(
                    store!.image!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/productPlaceholder.jpg',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 16),

          // Store name
          if (store!.storeName != null)
            Text(
              store!.storeName!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          const SizedBox(height: 12),

          // Rating
          if (store!.rating != null)
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  store!.rating!.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          if (store!.rating != null) const SizedBox(height: 12),

          // Address
          if (store!.address != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                    '${store!.location!.locationName!}, ',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(width: 6),
                
                Expanded(
                  child: Text(
                    store!.address!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          if (store!.address != null) const SizedBox(height: 12),

          // Description
          if (store!.description != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Opis prodavnice:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  store!.description!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          if (store!.description != null) const SizedBox(height: 12),

          // Working hours
          if (store!.startTime != null && store!.endTime != null)
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  "Radno vrijeme: ${store!.startTime} - ${store!.endTime}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          if ((store!.startTime != null && store!.endTime != null))
            const SizedBox(height: 12),

          // Working days
          if (store!.workingDays != null && store!.workingDays!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Radni dani: ${store!.workingDays!.join(', ')}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
