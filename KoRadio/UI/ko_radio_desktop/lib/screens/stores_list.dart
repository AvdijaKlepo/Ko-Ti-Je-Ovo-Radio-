import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/store.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:ko_radio_desktop/screens/company_update_dialog.dart';
import 'package:ko_radio_desktop/screens/store_update_dialog.dart';
import 'package:provider/provider.dart';

class StoresList extends StatefulWidget {
  const StoresList({super.key});

  @override
  State<StoresList> createState() => _StoresListState();
}

class _StoresListState extends State<StoresList> {
  late StoreProvider storesProvider;
  SearchResult<Store>? storeResult;

  final TextEditingController _storeNameController = TextEditingController();
  bool showApplicants=false;
  bool showDeleted=false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _storeNameController.dispose();
    super.dispose();
  }
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _getStores);
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
       storesProvider = context.read<StoreProvider>();
      _getStores();

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
        content: Text('Jeste li sigurni da želite izbrisatu ovu trgovinu?'),
        actions: [
          TextButton(
            onPressed: () async {
              await storesProvider.delete(store.storeId);
              _getStores();
              Navigator.of(context).pop(true);
            },
            child: const Text('Da'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
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
        content: Text('Jeste li sigurni da želite vratiti ovu trgovinu?'),
        actions: [
          TextButton(
            onPressed: () async {
              await storesProvider.delete(store.storeId);
              _getStores();
              Navigator.of(context).pop(true);
            },
            child: const Text('Da'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
        ],
      ),
    );
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
                      _getStores();
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
                      _getStores();
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
            child: storeResult == null
                ? const Center(child: CircularProgressIndicator())
                : storeResult!.result.isEmpty
                    ? const Center(child: Text('Nisu pronađene trgovine.'))
                    : ListView.separated(
                        itemCount: storeResult!.result.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final s = storeResult!.result[index];
                     

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(s.storeName ?? '')),
                                Expanded(flex: 2, child: Text(s.location?.locationName ?? '')),
                                Expanded(flex: 3, child: Text('${s.user?.firstName} ${s.user?.lastName}' )), 
                               
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
                                        _getStores();
                                        
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
                                                "roles":[10,1011],
                                                'locationId': s.location?.locationId,
                                              });
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Trgovina odobrena!")));
                                            
                                           }catch(e){
                                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                           }
                                           _getStores();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          tooltip: 'Odbaci',
                                          onPressed: () async {
                                            // Add rejection logic here
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
