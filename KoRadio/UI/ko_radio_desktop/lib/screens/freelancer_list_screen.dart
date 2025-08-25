import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/freelancer.dart';
import 'package:ko_radio_desktop/models/freelancer_service.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/freelancer_update_dialog.dart';
import 'package:provider/provider.dart';

class FreelancerListScreen extends StatefulWidget {
  const FreelancerListScreen({super.key});

  @override
  State<FreelancerListScreen> createState() => _FreelancerListScreenState();
}

class _FreelancerListScreenState extends State<FreelancerListScreen> {
  late FreelancerProvider provider;
  late PaginatedFetcher<Freelancer> freelancerPagination;
  late ScrollController _scrollController;
  SearchResult<Freelancer>? result;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
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
      freelancerPagination = PaginatedFetcher<Freelancer>(
        pageSize: 20,
        initialFilter: {},
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
          
        }) async {
          final result = await provider.get(filter: filter);
          return PaginatedResult(result: result.result, count: result.count);
        },
      );

      _scrollController = ScrollController();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 100 &&
            freelancerPagination.hasNextPage &&
            !freelancerPagination.isLoading) {
          freelancerPagination.loadMore();
        }
      });
     provider = context.read<FreelancerProvider>();
     freelancerPagination = PaginatedFetcher<Freelancer>(
        pageSize: 20,
        initialFilter: {},
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
          
        }) async {
          final result = await provider.get(filter: filter);
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
     
      await freelancerPagination.refresh(newFilter: {
        'IsServiceIncluded': true,
        'IsApplicant': showApplicants,
        'isDeleted': showDeleted,
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300),
    _refreshWithFilter
    );
  }
  Future<void> _refreshWithFilter() async {
    setState(() => isLoading = true);
    final filter =<String, dynamic> {
      'IsServiceIncluded': true,
      'IsApplicant': showApplicants,
      'isDeleted': showDeleted,
    };
    if(_firstNameController.text.trim().isNotEmpty)
    {
      filter['FirstNameGTE'] = _firstNameController.text.trim();
    }
    if(_lastNameController.text.trim().isNotEmpty)
    {
      filter['LastNameGTE'] = _lastNameController.text.trim();
    }
    await freelancerPagination.refresh(newFilter: filter);
    setState(() => isLoading = false);
  }

  Future<void> _getFreelancers() async {
    final filter = {
      'IsServiceIncluded': true,
      'IsApplicant': showApplicants,
      'isDeleted': showDeleted,
    };

    final fetchedUsers = await provider.get(filter: filter);
    setState(() {
      result = fetchedUsers;
    });
  }

  final dayNamesMap = {
    0: 'Nedjelja',
    1: 'Ponedjeljak',
    2: 'Utorak',
    3: 'Srijeda',
    4: 'Četvrtak',
    5: 'Petak',
    6: 'Subota',
  };

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

  void _openUserDeleteDialog({required Freelancer user}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izbriši?'),
        content: const Text('Jeste li sigurni da želite izbrisati ovog radnika?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              try{
                await provider.delete(user.freelancerId);
                await freelancerPagination.refresh(newFilter: {
                  'IsServiceIncluded': true,
                  'IsApplicant': showApplicants,
                  'isDeleted': showDeleted,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Radnik je uspješno izbrisan.")),
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

  void _openUserRestoreDialog({required Freelancer user}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vrati?'),
        content: const Text('Jeste li sigurni da želite reaktivirati ovog radnika?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              try{
                await provider.delete(user.freelancerId);
                await freelancerPagination.refresh(newFilter: {
                  'IsServiceIncluded': true,
                  'IsApplicant': showApplicants,
                  'isDeleted': showDeleted,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Radnik je uspješno reaktiviran.")),
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
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 12),
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
              const Expanded(flex: 2, child: Text("Prezime", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 3, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 3, child: Text("Lokacija", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 3, child: Text("Radni Dani", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 2, child: Text("Iskustvo", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 2, child: Text("Rating", style: TextStyle(fontWeight: FontWeight.bold))),
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
            child: freelancerPagination.isLoading && freelancerPagination.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : freelancerPagination.items.isEmpty
                    ? const Center(child: Text('Radnici nisu pronađeni.'))
                    : ListView.separated(
                        controller: _scrollController,
                        itemCount: freelancerPagination.items.length + 
                        (freelancerPagination.hasNextPage ? 1 : 0),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final f = freelancerPagination.items[index];
                          final days = getWorkingDaysShort(f.workingDays);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(f.freelancerNavigation?.firstName ?? '')),
                                Expanded(flex: 2, child: Text(f.freelancerNavigation?.lastName ?? '')),
                                Expanded(flex: 3, child: Text(f.freelancerNavigation?.email ?? '')),
                                Expanded(flex: 3, child: Text(f.freelancerNavigation?.location?.locationName ?? '')),
                                Expanded(flex: 3, child: Text(days.join(', '))),
                                Expanded(flex: 2, child: Text(f.experianceYears.toString())),
                                Expanded(flex: 2, child: Text(f.rating.toStringAsFixed(1))),
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
                              child: f.freelancerNavigation?.image != null
                                  ? imageFromString(f.freelancerNavigation!.image!)
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
                                    children: f.freelancerServices.map((FreelancerService s) {
                                      return Text(s.service?.serviceName ?? '', style: const TextStyle(fontSize: 12));
                                    }).toList(),
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
                                          builder: (_) => FreelancerUpdateDialog(freelancer: f),
                                        );
                                         await freelancerPagination.refresh(newFilter: {
                                              'IsServiceIncluded': true,
                                              'IsApplicant': showApplicants,
                                              'isDeleted': showDeleted,
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
                                      onPressed: () => _openUserDeleteDialog(user: f),
                                    ),
                                  ),
                                if (showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.restore),
                                      tooltip: 'Vrati',
                                      onPressed: () => _openUserRestoreDialog(user: f),
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

    await showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Odobreno"),
        content: const Text("Jeste li sigurni da želite odobriti ovog radnika?"),
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

              var workingDaysStringList = f.workingDays ?? [];

              final workingDaysIntList = workingDaysStringList
                  .map((day) => dayMap[day])
                  .whereType<int>()
                  .toList();

              try {
  await provider.update(
    f.freelancerId,
    {
      "freelancerId": f.freelancerId,
      "bio": f.bio,
      "rating": f.rating,
      "experianceYears": f.experianceYears,
      "startTime": f.startTime,
      "endTime": f.endTime,
      "workingDays": workingDaysIntList,
      "serviceId": f.freelancerServices.map((e) => e.serviceId).toList(),
      "roles": [3],
      "isApplicant": false,
      "isDeleted": false,
      'freelancerNavigation': f.freelancerNavigation,
    },
  );   
  
  if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(content: Text("Radnik odobren!")),
                );
              }
              await freelancerPagination.refresh(newFilter: {
                'IsServiceIncluded': true,
                'IsApplicant': showApplicants,
                'isDeleted': showDeleted,
              });
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Greška tokom akcije. Pokušajte ponovo.")),
  );
  await freelancerPagination.refresh(newFilter: {
                'IsServiceIncluded': true,
                'IsApplicant': showApplicants,
                'isDeleted': showDeleted,
              });
}

             

            

            
            },
            child: const Text("Da"),
          )
        ],
      ),
    );
  },
),

                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            tooltip: 'Odbaci',
                                            onPressed: () async {
                                                  final parentContext = context;
                                              await showDialog(
                                                context: parentContext,
                                                builder: (dialogContext) => AlertDialog(
                                                  title: const Text('Odbaci?'),
                                                  content: const Text('Jeste li sigurni da želite odbiti ovog korisnika?'),
                                                  actions: [
                                                    
                                                    TextButton(
                                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                                      child: const Text('Ne'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        try {
  await provider.delete(f.freelancerId);
  await freelancerPagination.refresh(newFilter: {
    'IsServiceIncluded': true,
    'IsApplicant': showApplicants,
    'isDeleted': showDeleted,
  });
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Greška tokom akcije. Pokušajte ponovo.")),
  );
}
                                                        if(parentContext.mounted)
                                                        {
                                                          Navigator.of(context).pop();

                                                        }
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Radnik je uspješno odbijen i uklonjen..")),
                                                        );
                                                      },
                                                      child: const Text('Da'),
                                                    ),
                                                  ],
                                                ),
                                              );
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