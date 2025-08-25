import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/store.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/store_update_dialog.dart';
import 'package:provider/provider.dart';

class StoresList extends StatefulWidget {
  const StoresList({super.key});

  @override
  State<StoresList> createState() => _StoresListState();
}

class _StoresListState extends State<StoresList> {
  late StoreProvider storesProvider;
  late PaginatedFetcher<Store> storesPagination;
  late ScrollController _scrollController;
  SearchResult<Store>? storeResult;

  final TextEditingController _storeNameController = TextEditingController();
  bool showApplicants=false;
  bool showDeleted=false;
  bool _isInitialized = false;
  bool isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _storeNameController.dispose();
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
      'IsApplicant': showApplicants,
    };
    if(_storeNameController.text.trim().isNotEmpty)
    {
      filter['Name'] = _storeNameController.text.trim();
    }
    await storesPagination.refresh(newFilter: filter);
    setState(() => isLoading = false);
  }
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading=true;
    });
    storesPagination = PaginatedFetcher<Store>(
      pageSize: 20,
      initialFilter: {},
      fetcher: ({
        required int page,
        required int pageSize,
        Map<String, dynamic>? filter,
        
      }) async {
        final result = await storesProvider.get(filter: filter);
        return PaginatedResult(result: result.result, count: result.count);
      },
    );

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          storesPagination.hasNextPage &&
          !storesPagination.isLoading) {
        storesPagination.loadMore();
      }
    });
     storesProvider = context.read<StoreProvider>();
     storesPagination = PaginatedFetcher<Store>(
        pageSize: 20,
        initialFilter: {},
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
          
        }) async {
          final result = await storesProvider.get(filter: filter);
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)  async{
      setState(() {
        isLoading = true;
      });
      await storesPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'IsApplicant': showApplicants,
      });
      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
      
  

    });
  }
  Future<void> _getStores() async {
    final filter = {
      'isApplicant': showApplicants,
      'isDeleted': showDeleted,
    };
    try {
      final fetchedStores = await storesProvider.get(filter: filter);
      setState(() {
        storeResult = fetchedStores;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  
  void _openUserDeleteDialog({required Store store}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izbriši?'),
        content: const Text('Jeste li sigurni da želite izbrisatu ovu trgovinu?'),
        actions: [
         
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
           TextButton(
            onPressed: () async {
              try{
                await storesProvider.delete(store.storeId);
                await storesPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
        'IsApplicant': showApplicants,
              });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trgovina je uspješno izbrisana.")),
                );
              } on Exception catch (e) {
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

  void _openUserRestoreDialog({required Store store}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vrati?'),
        content: const Text('Jeste li sigurni da želite vratiti ovu trgovinu?'),
        actions: [
         
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
           TextButton(
            onPressed: () async {
              try{
                await storesProvider.delete(store.storeId);
                await storesPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
        'IsApplicant': showApplicants,
              });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trgovina je uspješno reaktivirana.")),
                );
              } on Exception catch (e) {
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
                  controller: _storeNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ime Trgovine',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Text("Prikaži aplikante"),
                  Switch(
                    value: showApplicants,
                    onChanged: (val) {
                      setState(() => showApplicants = val);
                      _onSearchChanged();
                    },
                  ),
                ],
              ),
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
    const Expanded(flex: 2, child: Text("Naziv", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 2, child: Text("Lokacija", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Vlasnik", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Adresa", style: TextStyle(fontWeight: FontWeight.bold))),
   const Expanded(
  flex: 3,
  child: Center(
    child: Text(
      "Slika",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
),
   
   if (!showApplicants && !showDeleted)
                const Expanded(flex: 2, child: Icon(Icons.edit, size: 18)),
              if (!showApplicants && !showDeleted)
                const Expanded(flex: 2, child: Icon(Icons.delete, size: 18)),
              if (showDeleted)
                const Expanded(flex: 2, child: Icon(Icons.restore, size: 18)),
              if (showApplicants)
                const Expanded(flex: 2, child: Text("Akcije", style: TextStyle(fontWeight: FontWeight.bold))),
  ],
),

          Expanded(
            child: storesPagination.isLoading && storesPagination.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : storesPagination.items.isEmpty
                    ? const Center(child: Text('Nisu pronađene trgovine.'))
                    : ListView.separated(
                        controller: _scrollController,
                        itemCount: storesPagination.items.length + 
                        (storesPagination.hasNextPage ? 1 : 0),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final s = storesPagination.items[index];
                     

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(s.storeName ?? '')),
                                Expanded(flex: 2, child: Text(s.location?.locationName ?? '')),
                                Expanded(flex: 3, child: Text('${s.user?.firstName} ${s.user?.lastName}' )), 
                                Expanded(flex: 3, child: Text('${s.address}' )), 
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
                              child: s.image != null
                                  ? imageFromString(s.image!)
                                  : const Image(
                                      image: AssetImage(
                                          'assets/images/Sample_User_Icon.png'),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                               
                                if (!showApplicants && !showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Uredi',
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (_) => StoreUpdateDialog(store: s),
                                        );
                                        await storesPagination.refresh(newFilter: {
                                          'isDeleted': showDeleted,
      'IsApplicant': showApplicants,
                                    });
                                        
                                      },
                                    ),
                                  ),
                                if (!showApplicants && !showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Izbriši',
                                      onPressed: () => _openUserDeleteDialog(store: s),
                                    ),
                                  ),
                                if (showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.restore),
                                      tooltip: 'Vrati',
                                      onPressed: () => _openUserRestoreDialog(store: s),
                                    ),
                                  ),
                                if (showApplicants)
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          tooltip: 'Odobri',
                                          onPressed: () async {
                                           try{
                                            await storesProvider.update(s.storeId, {
                                                "storeName": s.storeName,
                                                "userId": s.user?.userId,
                                                "description": s.description,
                                                "isApplicant": false,
                                                "isDeleted": false,
                                                "roles":[6],
                                                'locationId': s.location?.locationId,
                                                'address': s.address,
                                              });
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Trgovina odobrena!")));
                                            
                                           }catch(e){
                                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                           }
                                          await storesPagination.refresh(newFilter: {
                                            'isDeleted': showDeleted,
      'IsApplicant': showApplicants,
                                          });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          tooltip: 'Odbaci',
                                          onPressed: () async {
                                            await  storesProvider.delete(s.storeId);
                                            await storesPagination.refresh(newFilter: {
                                              'isDeleted': showDeleted,
      'IsApplicant': showApplicants,
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
  

}
