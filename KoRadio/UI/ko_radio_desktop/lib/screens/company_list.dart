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

  SearchResult<Company>? companyResult;
  int currentPage = 1;

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
      pageSize: 0,
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

    
    companyProvider = context.read<CompanyProvider>();
    companyPagination = PaginatedFetcher<Company>(
      pageSize: 18,
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
      if(mounted) {
        await companyPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'IsApplicant': showApplicants,
      });
      }
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
    _debounce = Timer(const Duration(milliseconds: 1), _refreshWithFilter);
  }
  Future<void> _refreshWithFilter() async {
    
    final filter =<String, dynamic> {
      'isDeleted': showDeleted,
      'IsApplicant': showApplicants,
    };
    if(_companyNameController.text.trim().isNotEmpty)
    {
      filter['CompanyName'] = _companyNameController.text.trim();
    }
    await companyPagination.refresh(newFilter: filter);

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
              try{
                await companyProvider.delete(company.companyId);
                await companyPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
                  'IsApplicant': showApplicants,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Firma je uspješno izbrisana.")),
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
              try{
                await companyProvider.delete(company.companyId);
                await companyPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
                  'IsApplicant': showApplicants,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Firma je uspješno reaktivirana.")),
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
  void _openUserApproveDialog({required Company c}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Odobreno?'),
        content: const Text('Jeste li sigurni da želite odobriti ovu ?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              try {
  final dayMap = {
    'Sunday': 0,
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6
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
      "serviceId":
          c.companyServices.map((e) => e.serviceId).toList(),
      "locationId": c.location?.locationId,
      "roles": [4],
      "isApplicant": false,
      "isDeleted": false,
      "employee": c.companyEmployees.map((e) => e.userId).toList(),
      'isOwner': true,
    },
  );
  
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Firma odobrena!")),
    );
  
  await companyPagination.refresh(newFilter: {
    'isDeleted': showDeleted,
    'IsApplicant': showApplicants,
  });
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
  void _openUserRejectDialog({required Company c}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Odbaci?'),
        content: const Text('Jeste li sigurni da želite odbaciti ovu firmu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              try {
  await companyProvider.delete(c.companyId);
  await companyPagination.refresh(newFilter: {
    'isDeleted': showDeleted,
    'IsApplicant': showApplicants,
  });
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Firma je uspješno odbačena.")),
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
    if(isLoading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _companyNameController,
                  decoration:  InputDecoration(
                    labelText: 'Ime Firme',
                    prefixIcon: const Icon(Icons.search_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _companyNameController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _companyNameController.clear();
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
              const SizedBox(width: 12),
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
           child: const Row(
             children: [
               Expanded(flex: 5, child: Text("Ime", style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(flex: 4, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(flex: 3, child: Text("Telefonski broj", style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(flex: 3, child: Text("Lokacija", style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(flex: 5, child: Text("Radni Dani", style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(flex: 2, child: Text("Iskustvo", style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(flex: 2, child: Text("Rating", style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(flex: 2, child: Text("Broj Zaposlenika", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
             flex: 3,
             child: Center(
               child: Text(
                 "Slika",
                 style: TextStyle(fontWeight: FontWeight.bold),
               ),
             ),
           ),
               Expanded(flex: 6, child: Text("Usluge", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Center(child: Text("Akcije", style: TextStyle(fontWeight: FontWeight.bold)))),
                   
                
             ],
           ),
         ),
         const SizedBox(height: 6),

          Expanded(child:
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: companyPagination.items.isEmpty && !isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/usersNotFound.webp', width: 250, height: 250),
                      const SizedBox(height: 16),
                      const Text(
                        'Korisnici nisu pronađeni.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                : ListView.separated(
            itemCount: companyPagination.items.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final c = companyPagination.items[index];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  color: index.isEven ? Colors.grey.shade50 : Colors.white,
                  child: _buildCompanies(c),
                ),
              );
            },
          ),
          ),
          ),

          const SizedBox(height: 12),

           if (_companyNameController.text.isEmpty &&
           
            companyPagination.hasNextPage == false)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            children: List.generate(
              (companyPagination.count / companyPagination.pageSize).ceil(),
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
                    await companyPagination.goToPage(
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

        // 📊 Counter
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Prikazano ${(currentPage - 1) * companyPagination.pageSize + 1}"
              " - ${(currentPage - 1) * companyPagination.pageSize + companyPagination.items.length}"
              " od ${companyPagination.count}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
          
          
          
          
       

     
        ],
      ),
    );
  }
  Widget _buildCompanies(Company company) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(company.companyName ?? '')),
          Expanded(flex: 4, child: Text(company.email ?? '')),
          Expanded(flex: 3, child: Text(formatPhoneNumber(company.phoneNumber ?? ''))),
          Expanded(flex: 3, child: Text(company.location?.locationName ?? '')),
          Expanded(flex: 5, child: Text(getWorkingDaysShort(company.workingDays).join(', '))),
          Expanded(flex: 2, child: Text('${company.experianceYears.toString()} godina')),
          Expanded(flex: 2, child: Text(company.rating>1 ? '${company.rating.toStringAsFixed(1)}/5.0' : 'Nema ocjene')),
          Expanded(flex: 2, child: Text('${company.companyEmployees.length.toString()} zaposlenih')),
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
                  child: company.image != null
                      ? imageFromString(company.image!)
                      : const Image(
                          image: AssetImage(
                              'assets/images/Sample_User_Icon.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
          Expanded( flex: 6, child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: company.companyServices.map((CompanyServices s) {
                return Text(s.service?.serviceName ?? '', style: const TextStyle(fontSize: 12));
              }).toList(),
            ),
          ),
          
!showDeleted?
         Expanded(child: 
         Center(
          child: PopupMenuButton<String>(
            tooltip: 'Uredi/Izbriši',
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Uredi'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Izbriši'),
              ),
            ],
            onSelected: (value) async {
              if (value == 'edit') {
                await showDialog(context: context, builder: (_) => CompanyUpdateDialog(company: company));
                await companyPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
                  'isApplicant': showApplicants,
            
                });
              } else if (value == 'delete') {
                _openUserDeleteDialog(company: company);
              }
            },
          ),
         )) : Expanded(
  flex: 1,
  child: Center(
    child: IconButton(
      color: Colors.black,
         
      tooltip: 'Reaktiviraj',
      onPressed: () {
      
          _openUserRestoreDialog(company: company);
        
      },
      icon: const Icon(Icons.restore_outlined),
    ),
  ),
),
        ],
      ),
    );
  }
}