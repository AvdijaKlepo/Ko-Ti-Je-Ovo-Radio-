import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/product.dart';
import 'package:ko_radio_desktop/models/products_services.dart';
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
  SearchResult<Product>? productResult;
  SearchResult<Service>? serviceResult;

  final TextEditingController _productNameController = TextEditingController();
  bool showDeleted = false;
  Timer? _debounce;
  int? selectedServiceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productProvider = context.read<ProductProvider>();
      serviceProvider = context.read<ServiceProvider>();
      _getServices();
      _getProducts();
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
    _debounce = Timer(const Duration(milliseconds: 300), _getProducts);
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

  @override
  Widget build(BuildContext context) {
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
                  _getProducts();
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
                      _getProducts();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
const Row(
  children: [
    Expanded(flex: 2, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Naziv", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
    )),
    Expanded(flex: 4, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Opis", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
    )),
    Expanded(flex: 2, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Cijena", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
    )),
    Expanded(flex: 3, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Tip", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
    )),
    Expanded(flex: 3, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("Slika", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    )),
    Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.edit, size: 18),
    )),
    Expanded(flex: 1, child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.delete, size: 18),
    )),
  ],
),
const SizedBox(height: 8),
Expanded(
  child: productResult == null
      ? const Center(child: CircularProgressIndicator())
      : productResult!.result.isEmpty
          ? const Center(child: Text('Nema proizvoda.'))
          : ListView.separated(
              itemCount: productResult!.result.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = productResult!.result[index];
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
                        child: Text(p.price?.toStringAsFixed(2) ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
                      )),
                      Expanded(flex: 3, child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(p.productsServices?.map((e) => e.service?.serviceName ?? '').join('\n') ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
                      )),
                      Expanded(flex: 3, child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final height = width * 0.15;
                            return SizedBox(
                              width: width,
                              height: height,
                              child: p.image != null
                                  ? imageFromString(p.image!)
                                  : Image.asset("assets/images/Image_not_available.png"),
                            );
                          },
                        ),
                      )),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Uredi',
                          onPressed: () {
                            // TODO: Open product edit dialog
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
              },
            ),
),

          ElevatedButton(onPressed:  () async{
            await showDialog(context: context, builder: (_) => ProductDetailsDialog());
          }, child: Text("Dodaj proizvod")),
        ],
      ),
    );
  }
}
