import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/product.dart';

import 'package:ko_radio_mobile/models/store.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/product_provider.dart';


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
  late ProductProvider productProvider;
  late PaginatedFetcher<Product> productPagination;
  late final ScrollController _scrollController;

  bool _isInitialized = false;
  String _searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

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
          return PaginatedResult<Product>(result: result.result, count: result.count);
        },
        pageSize: 6,
      );

      productPagination.addListener(() {
        if (mounted) setState(() {});
      });

      await productPagination.refresh();
      setState(() {
        _isInitialized = true;
      });
    });
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
    final filter = <String, dynamic>{};
    if (_searchQuery.isNotEmpty) {
      filter['ServiceName'] = _searchQuery;
    }
    filter["storeId"]=widget.store?.storeId; 
    await productPagination.refresh(newFilter: filter);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tipovi proizvoda"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshWithFilter,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                automaticallyImplyLeading: false,
                toolbarHeight: 70,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Pretražite tipove...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),
              productPagination.items.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text("Nema dostupnih tipova proizvoda.", style: TextStyle(fontSize: 16))),
                    )
                  : SliverPadding(
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
                              return product.productName != null
                                  ? GestureDetector(
                                      onTap: () async{
                                       await Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => ProductDetails(product: product),
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
                                                  : Container(color: Colors.grey.shade300),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.6),
                                                  borderRadius: const BorderRadius.only(
                                                    bottomLeft: Radius.circular(16),
                                                    bottomRight: Radius.circular(16),
                                                  ),
                                                ),
                                                child: Text(
                                                  product.productName!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                             IconButton(
  icon: const Icon(Icons.add_shopping_cart),
  onPressed: () {
    context.read<CartProvider>().add(product!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product?.productName} dodan u košaricu.')),
    );
  },
)
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }

                            if (productPagination.hasNextPage) {
                              return const Padding(
                                padding: EdgeInsets.all(8),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                          childCount: productPagination.items.length + (productPagination.hasNextPage ? 1 : 0),
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
