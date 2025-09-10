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
  SearchResult<Store>? storeResult;
  int currentPage=1;

  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeOwnerNameController = TextEditingController();
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
  void _onSearchChanged() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1),  _refreshWithFilter);
  }
  Future<void> _refreshWithFilter() async {
    if(isLoading) return;
    setState(() => isLoading = true);
    final filter =<String, dynamic> {
      'isDeleted': showDeleted,
      'IsApplicant': showApplicants,
      'Name': _storeNameController.text.trim(),
      'OwnerName': _storeOwnerNameController.text.trim(),
    };
    if(_storeNameController.text.trim().isNotEmpty)
    {
      filter['Name'] = _storeNameController.text.trim();
    }
     if(_storeOwnerNameController.text.trim().isNotEmpty)
    {
      filter['OwnerName'] = _storeOwnerNameController.text.trim();
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
      pageSize: 0,
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

    
     storesProvider = context.read<StoreProvider>();
     storesPagination = PaginatedFetcher<Store>(
        pageSize: 18,
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
      storesPagination.addListener(() {
        if(!mounted) return;
        setState(() {});
      });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)  async{
      setState(() {
        isLoading = true;
      });
      if(mounted) {
      await storesPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'IsApplicant': showApplicants,
         'Name': _storeNameController.text.trim(),
      'OwnerName': _storeOwnerNameController.text.trim(),
      });
      }
      if(!mounted) return;
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
  void _openUserApproveDialog({required Store s}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Odobreno?'),
        content: const Text('Jeste li sigurni da želite odobriti ovu trgovinu?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
               final dayMap = {
                'Sunday': 0, 'Monday': 1, 'Tuesday': 2, 'Wednesday': 3,
                'Thursday': 4, 'Friday': 5, 'Saturday': 6
              };

              var workingDaysStringList = s.workingDays ?? [];

              final workingDaysIntList = workingDaysStringList
                  .map((day) => dayMap[day])
                  .whereType<int>()
                  .toList();
           try {
                await storesProvider.update(s.storeId, {
                  "storeName": s.storeName,
                  "userId": s.user?.userId,
                  "description": s.description,
                  "isApplicant": false,
                  "isDeleted": false,
                  "roles": [6],
                  'locationId': s.location?.locationId,
                  'address': s.address,
                  'workingDays': workingDaysIntList,
                  'startTime': s.startTime,
                  'endTime': s.endTime,
                  'businessCertificate': null,
                  'image':s.image,
                  'rating': s.rating,

                });
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Trgovina odobrena!")));
                     await storesPagination.refresh(newFilter: {
                'isDeleted': showDeleted,
                'IsApplicant': showApplicants,
              });
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Greška tokom akcije. Pokušajte ponovo.')));
                     await storesPagination.refresh(newFilter: {
                'isDeleted': showDeleted,
                'IsApplicant': showApplicants,
              });
              }
             Navigator.pop(context);
                                                 
                                                
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }
  void _openUserRejectDialog({required Store s}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Odbaci?'),
        content: const Text('Jeste li sigurni da želite odbaciti ovu trgovinu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
             try {
  await storesProvider.delete(s.storeId);
   await storesPagination.refresh(newFilter: {
     'isDeleted': showDeleted,
     'IsApplicant': showApplicants,
   });
   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text("Trgovina je uspješno odbačena.")),
   );
} on Exception catch (e) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Greška tokom akcije. Pokušajte ponovo.")),
  );
}
Navigator.of(context).pop();
              
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _storeNameController,
                  decoration:  InputDecoration(
                    labelText: 'Ime Trgovine',
                    prefixIcon: const Icon(Icons.search_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _storeNameController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _storeNameController.clear();
                            _onSearchChanged();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  ),
                  
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 8),

               Expanded(
                child: TextField(
                  controller: _storeOwnerNameController,
                  decoration:  InputDecoration(
                    labelText: 'Ime i prezime vlasnika',
                    prefixIcon: const Icon(Icons.search_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _storeOwnerNameController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _storeOwnerNameController.clear();
                            _onSearchChanged();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                
                  Switch(
                    value: showApplicants,
                    onChanged: (val) {
                      setState(() => showApplicants = val);
                      _onSearchChanged();
                    },
                  ),
                    const Text("Prikaži aplikante"),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                children: [
              
                  Switch(
                    value: showDeleted,
                    onChanged: (val) {
                      setState(() => showDeleted = val);
                      _onSearchChanged();
                    },
                  ),
                      const Text("Prikaži izbrisane"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        Container(
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(8),
  ),
  child:  Row(
    children: [
      const Expanded(flex: 2, child: Text("Naziv", style: TextStyle(fontWeight: FontWeight.bold))),
      const Expanded(flex: 3, child: Text("Vlasnik", style: TextStyle(fontWeight: FontWeight.bold))),
      const Expanded(flex: 2, child: Text("Lokacija", style: TextStyle(fontWeight: FontWeight.bold))),
      const Expanded(flex: 3, child: Text("Adresa", style: TextStyle(fontWeight: FontWeight.bold))),
      const Expanded(flex: 3, child: Text("Radni Dani", style: TextStyle(fontWeight: FontWeight.bold))),
      const Expanded(flex: 3, child: Text("Ocjena", style: TextStyle(fontWeight: FontWeight.bold))),
      const Expanded(
        flex: 3,
        child: Center(
          child: Text("Slika", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      showApplicants ? const Expanded(flex: 1, child: Text("Obrtni list", style: TextStyle(fontWeight: FontWeight.bold))) : const SizedBox(width: 0),

      const Expanded(flex: 2, child: Text("Akcije", style: TextStyle(fontWeight: FontWeight.bold))),
    ],
  ),
),
         const SizedBox(height: 6,),

         Expanded(child: Container(
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(8),
             border: Border.all(color: Colors.grey.shade200),
           ),
           child: storesPagination.items.isEmpty && !isLoading
               ? Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Image.asset('assets/images/usersNotFound.webp', width: 250, height: 250),
                     const SizedBox(height: 16),
                     const Text(
                       'Trgovine nisu pronađene.',
                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                     ),
                   ],
                 )
               : ListView.separated(
           itemCount: storesPagination.items.length,
           separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
           itemBuilder: (context, index) {
             final s = storesPagination.items[index];
             return MouseRegion(
               cursor: SystemMouseCursors.click,
               child: Container(
                 color: index.isEven ? Colors.grey.shade50 : Colors.white,
                 child: _buildStores(s),
               ),
             );
           },
         ),
         )
         ),
         const SizedBox(height: 12),

         if(_storeNameController.text.isEmpty && storesPagination.hasNextPage == false)

      Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            children: List.generate(
              (storesPagination.count / storesPagination.pageSize).ceil(),
              (index) {
                final pageNum = index + 1;
                final isActive = currentPage == pageNum;
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isActive ? const Color.fromRGBO(27, 76, 125, 1) : Colors.white,
                    foregroundColor: isActive ? Colors.white : Colors.black87,
                    side: BorderSide(color: isActive ? Colors.transparent : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () async {
                    if (!mounted) return;
                    setState(() {
                      currentPage = pageNum;
                      isLoading = true;
                    });
                    await storesPagination.goToPage(
                      pageNum,
                      filter: {
                        'isDeleted': showDeleted,
                        'isApplicant': showApplicants,
                      },
                    );
                    if (!mounted) return;
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Text("$pageNum"),
                );
              },
            ),
          ),

        const SizedBox(height: 8),

                if (_storeNameController.text.isEmpty && storesPagination.hasNextPage == false)

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Prikazano ${(currentPage - 1) * storesPagination.pageSize + 1}"
              " - ${(currentPage - 1) * storesPagination.pageSize + storesPagination.items.length}"
              " od ${storesPagination.count}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        
    
    
  



        
        ],
      ),
    );
  }
Widget _buildStores(Store store) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text(store.storeName ?? '')),
        Expanded(flex: 3, child: Text('${store.user?.firstName} ${store.user?.lastName}')),
        Expanded(flex: 2, child: Text(store.location?.locationName ?? '')),
        Expanded(flex: 3, child: Text(store.address ?? '')),
        Expanded(flex: 3, child: Text(getWorkingDaysShort(store.workingDays).join(', '))),
        Expanded(flex: 3, child: Text(store.rating!>1 ? '${store.rating?.toStringAsFixed(1)}/5.0' : 'Nema ocjene')),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
              child: ClipOval(
                child: store.image != null
                    ? imageFromString(store.image!)
                    : const Image(
                        image: AssetImage('assets/images/Sample_User_Icon.png'),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        showApplicants ?
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              if (store.businessCertificate != null) {
                showPdfDialog(context, store.businessCertificate!,"Obrtni list");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nema učitanog dokumenta")),
                );
              }
            },
            child: const Icon(Icons.document_scanner_outlined, size: 18),
          ),
        ): const SizedBox(width: 0),

        // 👇 All actions under single header "Akcije"
        Expanded(
          flex: 2,
          child: Center(
            child: Builder(
              builder: (context) {
                if (showApplicants) {
                  // Accept / Reject buttons
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Prihvati',
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          _openUserApproveDialog(s: store);
                          await storesPagination.refresh(newFilter: {
                            'isDeleted': showDeleted,
                            'isApplicant': showApplicants,
                          });
                        },
                      ),
                      IconButton(
                        tooltip: 'Odbij',
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          _openUserRejectDialog(s: store);
                          await storesPagination.refresh(newFilter: {
                            'isDeleted': showDeleted,
                            'isApplicant': showApplicants,
                          });
                        },
                      ),
                    ],
                  );
                } else if (showDeleted) {
                  // Restore
                  return IconButton(
                    color: Colors.black,
                    tooltip: 'Reaktiviraj',
                    onPressed: () => _openUserRestoreDialog(store: store),
                    icon: const Icon(Icons.restore_outlined),
                  );
                } else {
                  // Edit/Delete menu
                  return PopupMenuButton<String>(
                    tooltip: 'Uredi/Izbriši',
                    icon: const Icon(Icons.more_vert),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Uredi')),
                      const PopupMenuItem(value: 'delete', child: Text('Izbriši')),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await showDialog(
                          context: context,
                          builder: (_) => StoreUpdateDialog(store: store),
                        );
                        await storesPagination.refresh(newFilter: {
                          'isDeleted': showDeleted,
                          'isApplicant': showApplicants,
                          'NameGTE': _storeNameController.text,
                        });
                      } else if (value == 'delete') {
                        _openUserDeleteDialog(store: store);
                      }
                    },
                  );
                }
              },
            ),
          ),
        ),
      ],
    ),
  );
}
}
