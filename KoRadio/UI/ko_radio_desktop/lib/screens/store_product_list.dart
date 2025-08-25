import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/product.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/product_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/product_add_update_dialog.dart';
import 'package:provider/provider.dart';

class StoreProductList extends StatefulWidget {
  const StoreProductList({super.key});

  @override
  State<StoreProductList> createState() => _StoreProductListState();
}

class _StoreProductListState extends State<StoreProductList> {
  late ProductProvider productProvider;
  late ServiceProvider serviceProvider;
  late PaginatedFetcher<Product> productPagination;
  late ScrollController _scrollController;
  SearchResult<Product>? productResult;
  SearchResult<Service>? serviceResult;

  final TextEditingController _productNameController = TextEditingController();
  bool showDeleted = false;
  bool _isInitialized = false;
  bool isLoading = false;
  Timer? _debounce;
  int? selectedServiceId;

  @override
  void initState() {
    super.initState(); 
    setState(() {
      isLoading=true;
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
    productPagination = PaginatedFetcher<Product>(
      pageSize: 20,
      initialFilter: {},
      fetcher: ({
        required int page,
        required int pageSize,
        Map<String, dynamic>? filter,
        
      }) async {
        final result = await productProvider.get(filter: filter);
        return PaginatedResult(result: result.result, count: result.count);
      },
    );
      productProvider = context.read<ProductProvider>();
      serviceProvider = context.read<ServiceProvider>();
      productPagination = PaginatedFetcher<Product>(
        pageSize: 20,
        initialFilter: {},
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
          
        }) async {
          final result = await productProvider.get(filter: filter);
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await productPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'storeId': AuthProvider.selectedStoreId,
      });
      await _getServices();
      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
     
  
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _productNameController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _refreshWithFilter);
  }
  Future<void> _refreshWithFilter() async {
    setState(() => isLoading = true);
    final filter =<String, dynamic> {
      'isDeleted': showDeleted,
      'storeId': AuthProvider.selectedStoreId,
    };
    if(_productNameController.text.trim().isNotEmpty)
    {
      filter['Name'] = _productNameController.text.trim();
    }
    if(selectedServiceId!=null)
    {
      filter['ServiceId'] = selectedServiceId;
    }
    await productPagination.refresh(newFilter: filter);
    setState(() => isLoading = false);
  }

  final storeId = AuthProvider.selectedStoreId;

  Future<void> _getServices() async {
    try {
      final result = await serviceProvider.get();
      setState(() => serviceResult = result);
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  Future<void> _openProductDialog({Product? product}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ProductDetailsDialog(product: product),
    );
    if (result == true) {
      await productPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'storeId': AuthProvider.selectedStoreId,
      });
    }
  }

  Future<void> _getProducts() async {
    final filter = {
      'isDeleted': showDeleted,
      'storeId': storeId,
      if (selectedServiceId != null) 'serviceId': selectedServiceId,
      if (_productNameController.text.trim().isNotEmpty) 'productName': _productNameController.text.trim(),
    };

    try {
      final result = await productProvider.get(filter: filter);
      setState(() => productResult = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
    void _openUserDeleteDialog({required Product product}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izbriši?'),
        content: const Text('Jeste li sigurni da želite izbrisati ovaj proizvod?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              try{
                await productProvider.delete(product.productId);
                await productPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
                  'storeId': AuthProvider.selectedStoreId,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Proizvod je uspješno izbrisan.")),
                );
              }catch(e){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Greška tokom brisanja podataka. Pokušajte ponovo.")),
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

  void _openUserRestoreDialog({required Product product}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vrati?'),
        content: const Text('Jeste li sigurni da želite vratiti ovaj proizvod?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              try{
                await productProvider.delete(product.productId);
                await productPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
                  'storeId': AuthProvider.selectedStoreId,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Proizvod je uspješno reaktiviran.")),
                );
              }catch(e){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Greška tokom brisanja podataka. Pokušajte ponovo.")),
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Naziv proizvoda',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<int?>(
                value: selectedServiceId,
                hint: const Text("Filter po usluzi"),
                items: [
                  const DropdownMenuItem(value: null, child: Text("Sve usluge")),
                  ...?serviceResult?.result.map((s) => DropdownMenuItem(
                        value: s.serviceId,
                        child: Text(s.serviceName ?? ''),
                      )),
                ],
                onChanged: (value) {
                  setState(() => selectedServiceId = value);
                  _onSearchChanged();
                },
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Text("Prikaži izbrisane"),
                  Switch(
                    value: showDeleted,
                    onChanged: (val) {
                      setState(() => showDeleted = val);
                      _onSearchChanged();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
 Row(
  children: [
    const Expanded(flex: 2, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Naziv", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
    )),
    const Expanded(flex: 4, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Opis", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
    )),
    const Expanded(flex: 2, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Cijena", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
    )),
    const Expanded(flex: 3, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Tip", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
    )),
    const Expanded(flex: 3, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Slika", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    )),
    if(!showDeleted)
    const Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.edit, size: 18),
    )),
    if(!showDeleted)
    const Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.delete, size: 18),
    )),
    if(showDeleted)
     const Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.restore, size: 18),
    )),
  ],
),
const SizedBox(height: 8),
Expanded(
  child: productPagination.isLoading && productPagination.items.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : productPagination.items.isEmpty
          ? const Center(child: Text('Nema proizvoda.'))
          : ListView.separated(
              controller: _scrollController,
              itemCount: productPagination.items.length + 
              (productPagination.hasNextPage ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = productPagination.items[index];
                if(isLoading) return const Center(child: CircularProgressIndicator());
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(p.productName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
                      )),
                      Expanded(flex: 4, child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(p.productDescription ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
                      )),
                      Expanded(flex: 2, child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('${p.price?.toStringAsFixed(2)} KM' ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
                      )),
                      Expanded(flex: 3, child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(p.productsServices?.map((e) => e.service?.serviceName ?? '').join('\n') ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
                      )),
                       Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 40,
                              maxWidth: 40,
                            ),
                            child: ClipOval(
                              child: p.image != null
                                  ? imageFromString(p.image!)
                                  : const Image(
                                      image: AssetImage(
                                          'assets/images/Image_not_available.png'),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      if(!showDeleted)
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Uredi',
                          onPressed: () async {
                            _openProductDialog(product: p);
                          },
                        ),
                      ),
                      if(!showDeleted)
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Izbriši',
                          onPressed: () {
                            _openUserDeleteDialog(product: p);
                          },
                        ),
                      ),
                      if(showDeleted)
                       Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.restore),
                          tooltip: 'Izbriši',
                          onPressed: () {
                            _openUserRestoreDialog(product: p);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
),

          ElevatedButton(onPressed:  () async{
            await showDialog(context: context, builder: (_) => const ProductDetailsDialog());
          }, child: const Text("Dodaj proizvod")),
        ],
      ),
    );
  }
}
