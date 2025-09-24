import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';

import 'package:ko_radio_mobile/models/store.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/store_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/product_type_list.dart';
import 'package:provider/provider.dart';

class StoreList extends StatefulWidget {
  const StoreList({super.key});

  @override
  State<StoreList> createState() => _StoreListState();
}

class _StoreListState extends State<StoreList> {
  late StoreProvider storeProvider;
  late PaginatedFetcher<Store> storePagination;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  late final ScrollController _scrollController;
  List<DropdownMenuItem<int>> locationDropdownItems = [];
  bool _isLoading = false;

  bool _isInitialized = false;
  String _searchQuery = "";
  Timer? _debounce;
  int? _selectedLocationId;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          storePagination.hasNextPage &&
          !storePagination.isLoading) {
        storePagination.loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(!mounted || _isLoading) return;
      setState(() {
        _isLoading=true;
      });
  
      locationProvider = context.read<LocationProvider>();
      await _getLocations();
      if(!mounted) return;
      storeProvider = context.read<StoreProvider>();
      storePagination = PaginatedFetcher<Store>(
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
        }) async {
          final result = await storeProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult<Store>(
            result: result.result,
            count: result.count,
          );
        },
        pageSize: 6,
      );

      storePagination.addListener(() {
        if (mounted) setState(() {});
      });
      await storePagination.refresh();
      if(!mounted) return;
      setState(() {
        _isInitialized = true;
        _isLoading=false;
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
  Future<void> _getLocations() async {
    try{
        final fetched = await locationProvider.get();
      locationResult = fetched;
    locationDropdownItems = [
        const DropdownMenuItem(value: null, child: Text("Sve lokacije")),
        ...fetched.result
            .map((l) => DropdownMenuItem(value: l.locationId, child: Text(l.locationName)))
      ];
    } catch(e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Greška pri dohvatu lokacija: ${e.toString()}")));
    }
  }
  Future<void> _refreshWithFilter() async {
    if(_isLoading) return;
    setState(() {
      _isLoading=true;
    });
    final filter = <String, dynamic>{};
    
    if (_searchQuery.isNotEmpty) {
      filter['Name'] = _searchQuery;
    }
    if (_selectedLocationId != null) {
      filter['LocationId'] = _selectedLocationId;
    }

    await storePagination.refresh(newFilter: filter);
    if(!mounted) return;
    setState(() {
      _isLoading=false;
    });
  }

  Future<void> _openStore(Store store) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductTypeList(store: store),
      ),
    );
  }


 



 @override
Widget build(BuildContext context) {
  if (!_isInitialized) {
    return const Center(child: CircularProgressIndicator());
  }

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Pretraži trgovine...",
            prefixIcon: const Icon(Icons.search,color: Color.fromRGBO(27, 76, 125, 25),),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
          
            ),
            
          
          ),
          onChanged: _onSearchChanged,
        ),
      ),
   Padding(
     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
     child: DropdownButtonFormField<int>(
      isExpanded: true,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        hint: const Text(
          'Odaberi lokaciju',
          style: TextStyle(color: Colors.black),
        ),
        icon: const Icon(Icons.location_on,color: Color.fromRGBO(27, 76, 125, 25),),
        dropdownColor: Colors.white,
        items: locationDropdownItems,
        onChanged: (value) {
          setState(() {
            _selectedLocationId = value;
          });
          _refreshWithFilter();
        },
      ),
   ),
   
      Expanded(
        child: RefreshIndicator(
          onRefresh: _refreshWithFilter,
          child: storePagination.items.isEmpty
              ? _isLoading ? const Center(child: CircularProgressIndicator()) : ListView(
                  children: const [
                    SizedBox(height: 50),
                    Center(child: Text("Nema pronađenih trgovina.")),
                  ],
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: storePagination.items.length + 1,
                  itemBuilder: (context, index) {
                    if (index < storePagination.items.length) {
                      final store = storePagination.items[index];
                      return store.storeName != null
                          ? InkWell(

                              onTap: () => _openStore(store),
                              
                              child: Card(

                                color: Colors.white,
                                surfaceTintColor: Colors.transparent,
                                elevation: 4,
                               
                                
                                margin: const EdgeInsets.symmetric(vertical: 8),
                            
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(

                                      aspectRatio: 16 / 9,
                                      child: store.image != null
                                          ? imageFromString(
                                              store.image!,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/images/intro-1660762097.jpg',
                                              fit: BoxFit.cover,
                                              
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: double.maxFinite,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          alignment: WrapAlignment.spaceBetween,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                           Text(
                                          store.storeName ?? '',
                                          style:const TextStyle(color: Colors.black),
                                        ),
                                        Text(store.location?.locationName ?? "",style:const  TextStyle(color: Colors.black),),
                                        ],),
                                      )
                                      
                                     
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    }

                    if (storePagination.hasNextPage) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
        ),
      ),
    ],
  );
}

}
