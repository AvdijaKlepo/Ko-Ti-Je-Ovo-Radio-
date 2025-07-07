import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/models/store.dart';
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
          storePagination.hasNextPage &&
          !storePagination.isLoading) {
        storePagination.loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
      filter['Name'] = _searchQuery;
    }
    await storePagination.refresh(newFilter: filter);
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
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: _refreshWithFilter,
          child: storePagination.items.isEmpty
              ? ListView(
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
                          ? GestureDetector(
                              onTap: () => _openStore(store),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
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
                                      child: Text(
                                        store.storeName!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
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
