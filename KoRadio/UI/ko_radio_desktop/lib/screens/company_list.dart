import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_services.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/company_update_dialog.dart';
import 'package:provider/provider.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({super.key});

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  late CompanyProvider companyProvider;
  late PaginatedFetcher<Company> companyPagination;
  late ScrollController _scrollController;
  SearchResult<Company>? companyResult;

  final TextEditingController _companyNameController = TextEditingController();
  bool showApplicants = false;
  bool showDeleted = false;
  bool _isInitialized = false;
  bool isLoading = false;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading=true;
    });
    companyPagination = PaginatedFetcher<Company>(
      pageSize: 20,
      initialFilter: {},
      fetcher: ({
        required int page,
        required int pageSize,
        Map<String, dynamic>? filter,
        
      }) async {
        final result = await companyProvider.get(filter: filter);
        return PaginatedResult(result: result.result, count: result.count);
      },
    );

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          companyPagination.hasNextPage &&
          !companyPagination.isLoading) {
        companyPagination.loadMore();
      }
    });
    
    companyProvider = context.read<CompanyProvider>();
    companyPagination = PaginatedFetcher<Company>(
      pageSize: 20,
      initialFilter: {},
      fetcher: ({
        required int page,
        required int pageSize,
        Map<String, dynamic>? filter,
        
      }) async {
        final result = await companyProvider.get(filter: filter);
        return PaginatedResult(result: result.result, count: result.count);
      },
    )..addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
        
      });
      await companyPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'IsApplicant': showApplicants,
      });
      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
      
      
    });

  }
  @override
  void dispose() {
    _debounce?.cancel();
    _companyNameController.dispose();
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
    if(_companyNameController.text.trim().isNotEmpty)
    {
      filter['CompanyNameGTE'] = _companyNameController.text.trim();
    }
    await companyPagination.refresh(newFilter: filter);
    setState(() => isLoading = false);
  }
    
  

  Future<void> _getCompanies() async {
    final filter = {
 
      'IsApplicant': showApplicants,
      'isDeleted': showDeleted,
    };

    final fetchedCompanies = await companyProvider.get(filter: filter);
    setState(() {
      companyResult = fetchedCompanies;
    });
  }
  final shortDayNamesMap = {
    0: 'Ned',
    1: 'Pon',
    2: 'Uto',
    3: 'Sri',
    4: 'Čet',
    5: 'Pet',
    6: 'Sub',
  };

  List<String> getWorkingDaysShort(List<dynamic>? workingDays) {
    if (workingDays == null) return [];
    return workingDays.map((day) {
      if (day is int) {
        return shortDayNamesMap[day] ?? '';
      } else if (day is String) {
        return day.length > 3 ? day.substring(0, 3) : day;
      }
      return '';
    }).where((e) => e.isNotEmpty).toList();
  }

  void _openUserDeleteDialog({required Company company}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izbriši?'),
        content: const Text('Jeste li sigurni da želite izbrisatu ovu firmu?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              await companyProvider.delete(company.companyId);
              await companyPagination.refresh(newFilter: {
                'isDeleted': showDeleted,
                'IsApplicant': showApplicants,
              });
              Navigator.of(context).pop(true);
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }

  void _openUserRestoreDialog({required Company company}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vrati?'),
        content: const Text('Jeste li sigurni da želite vratiti ovu firmu?'),
        actions: [
         
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
           TextButton(
            onPressed: () async {
              await companyProvider.delete(company.companyId);
              await companyPagination.refresh(newFilter: {
                'isDeleted': showDeleted,
                'IsApplicant': showApplicants,
              });
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
    if(isLoading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ime Firme',
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
    const Expanded(flex: 2, child: Text("Ime", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Telefonski broj", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Lokacija", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Radni Dani", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Iskustvo", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Rating", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Broj Zaposlenika", style: TextStyle(fontWeight: FontWeight.bold))),
   const Expanded(
  flex: 3,
  child: Center(
    child: Text(
      "Slika",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
),
    const Expanded(flex: 6, child: Text("Usluge", style: TextStyle(fontWeight: FontWeight.bold))),
        
       if (!showApplicants && !showDeleted)
                const Expanded(flex: 2, child: Icon(Icons.edit, size: 18)),
              if (!showApplicants && !showDeleted)
                const Expanded(flex: 2, child: Icon(Icons.delete, size: 18)),
              if (showDeleted)
                const Expanded(flex: 2, child: Icon(Icons.restore, size: 18)),
              if (showApplicants)
                const Expanded(flex: 2, child: Center(child: Text("Akcije", style: TextStyle(fontWeight: FontWeight.bold)))),
  ],
),

          Expanded(
            child: companyPagination.isLoading && companyPagination.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : companyPagination.items.isEmpty
                    ? const Center(child: Text('No companies found.'))
                    : ListView.separated(
                        controller: _scrollController,
                        itemCount: companyPagination.items.length + 
                        (companyPagination.hasNextPage ? 1 : 0),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = companyPagination.items[index];
                          final days = getWorkingDaysShort(c.workingDays);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(c.companyName ?? '')),
                                Expanded(flex: 3, child: Text(c.email ?? '')),
                                Expanded(flex: 3, child: Text(c.phoneNumber ?? '')),
                                Expanded(flex: 3, child: Text(c.location?.locationName ?? '')),
                                Expanded(flex: 3, child: Text(days.join(', '))),
                                Expanded(flex: 3, child: Text(c.experianceYears.toString())),
                                Expanded(flex: 3, child: Text(c.rating.toStringAsFixed(1) ?? '')),
                                Expanded(flex: 3, child: Text(c.companyEmployees.length.toString())),
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
                              child: c.image != null
                                  ? imageFromString(c.image!)
                                  : const Image(
                                      image: AssetImage(
                                          'assets/images/Sample_User_Icon.png'),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                             
                                Expanded(
                                  flex: 6,
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: c.companyServices.map((CompanyServices s) {
                                      return Text(s.service?.serviceName ?? '', style: const TextStyle(fontSize: 12));
                                    }).toList() ?? [],
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
                                          builder: (_) => CompanyUpdateDialog(company: c),
                                        );
                                        await companyPagination.refresh(newFilter: {
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
                                      onPressed: () => _openUserDeleteDialog(company: c),
                                    ),
                                  ),
                                if (showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.restore),
                                      tooltip: 'Vrati',
                                      onPressed: () => _openUserRestoreDialog(company: c),
                                    ),
                                  ),
                                if (showApplicants)
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check, color: Colors.green),
                                            tooltip: 'Odobri',
                                            onPressed: () async {
                                              final parentContext = context;
                                            await showDialog(context: parentContext, builder: (dialogContext) =>  AlertDialog(
                                              title: const Text("Odobreno"),
                                              content: const Text("Jeste li sigurni da želite odobriti ovu firmu?"), 
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                                  child: const Text("Ne"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                  final dayMap = {
                                                  'Sunday': 0, 'Monday': 1, 'Tuesday': 2, 'Wednesday': 3,
                                                'Thursday': 4, 'Friday': 5, 'Saturday': 6
                                                };

                                                var workingDaysStringList = c.workingDays ?? [];

                                                final workingDaysIntList = workingDaysStringList
                                                    .map((day) => dayMap[day])
                                                    .whereType<int>()
                                                    .toList();

                                                await companyProvider.update(
                                                  c.companyId,
                                                  {
                                                    "companyName": c.companyName,
                                                    "bio": c.bio,
                                                    "email": c.email,
                                                    "rating": c.rating,
                                                    "phoneNumber": c.phoneNumber,
                                                    "experianceYears": c.experianceYears,
                                                    "image": c.image,
                                                    "startTime": c.startTime,
                                                    "endTime": c.endTime,
                                                    "workingDays": workingDaysIntList,
                                                    "serviceId": c.companyServices.map((e) => e.serviceId).toList(),
                                                    "locationId": c.location?.locationId,
                                                    "roles":[4],
                                                    "isApplicant": false,
                                                    "isDeleted": false,
                                                    "employee": c.companyEmployees.map((e) => e.userId).toList(),
                                                    'isOwner': true,
                                                  },
                                                );
                                               if (parentContext.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Firma odobrena!")),
                                                  );
                                               }
                                                  await companyPagination.refresh(newFilter: {
                                                    'isDeleted': showDeleted,
                                                    'IsApplicant': showApplicants,
                                                  }); 
                                                  if(parentContext.mounted)
                                                  {
                                                    Navigator.of(context).pop();
                                                  }
                                                 
                                                
                                                
                                                 
                                                  
                                                },
                                                child: const Text("Da"),
                                              )
                                            ]
                                          ));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            tooltip: 'Odbaci',
                                            onPressed: () async {
                                              final parentContext = context;
                                              await showDialog(context: parentContext, builder: (dialogContext) => AlertDialog(
                                                title: const Text('Odbaci?'),
                                                content: const Text('Jeste li sigurni da želite odbaciti ovu firmu?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                                    child: const Text('Ne'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await companyProvider.delete(c.companyId);
                                                      await companyPagination.refresh(newFilter: {
                                                        'isDeleted': showDeleted,
                                                        'IsApplicant': showApplicants,
                                                      });
                                                    if(parentContext.mounted)
                                                    {
                                                      Navigator.of(context).pop();
                                                    }
                                                    },
                                                    child: const Text('Da'),
                                                  ),
                                                ],
                                              ));
                                            },
                                          ),
                                        ],
                                      ),
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