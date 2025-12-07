import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ko_radio_desktop/models/freelancer.dart';
import 'package:ko_radio_desktop/models/freelancer_service.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';
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
  SearchResult<Freelancer>? result;
  int currentPage = 1;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
        pageSize: 0,
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

    
     provider = context.read<FreelancerProvider>();
     freelancerPagination = PaginatedFetcher<Freelancer>(
        pageSize: 18,
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
      freelancerPagination.addListener(() {
        if(!mounted) return;
        setState(() {});
      });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
     
      await freelancerPagination.refresh(newFilter: {
        'IsServiceIncluded': true,
        'IsApplicant': showApplicants,
        'isDeleted': showDeleted,
      });
      if(!mounted) return;
      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
   _firstNameController.removeListener(_onSearchChanged);

    _firstNameController.dispose();
       _emailController.removeListener(_onSearchChanged);
    _emailController.dispose();
    freelancerPagination.removeListener(_onSearchChanged);
    freelancerPagination.dispose();
    super.dispose();
  }
  

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1),
    _refreshWithFilter
    );
  }
  Future<void> _refreshWithFilter() async {
    if(isLoading) return;
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
    if(_emailController.text.trim().isNotEmpty)
    {
      filter['Email'] = _emailController.text.trim();
    }
   
    if(!mounted) return;
    await freelancerPagination.refresh(newFilter: filter);
    if(!mounted) return;
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
  final localized = localizeWorkingDays(workingDays);

  return localized.map((day) {
    return shortDayNamesMap[day] ?? 
           (day.length > 3 ? day.substring(0, 3) : day);
  }).toList();
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
               
              }on UserException catch(e)
              {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text("$e.exMessage")),
                );
              } 
              on Exception catch (e) {
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
  
  void _openUserApproveDialog({required Freelancer user}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Odobreno?'),
        content: const Text('Jeste li sigurni da želite odobriti ovog radnika?'),
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

              var workingDaysStringList = user.workingDays ?? [];

              final workingDaysIntList = workingDaysStringList
                  .map((day) => dayMap[day])
                  .whereType<int>()
                  .toList();
              try{
                await provider.update(user.freelancerId, {
                  "freelancerId": user.freelancerId,
                  "bio": user.bio,
                  "rating": user.rating,
                  "experianceYears": user.experianceYears,
                  "startTime": user.startTime,
                  "endTime": user.endTime,
                  "workingDays": workingDaysIntList,
                  "serviceId": user.freelancerServices.map((e) => e.serviceId).toList(),
                  "roles": [3],
                  "isApplicant": false,
                  "isDeleted": false,
                  'freelancerNavigation': user.freelancerNavigation,
                  'cv':null
                  
                  
                });
                await freelancerPagination.refresh(newFilter: {
                  'IsServiceIncluded': true,
                  'IsApplicant': showApplicants,
                  'isDeleted': showDeleted,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Radnik odobren!")),
                );
              } on Exception catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Greška tokom akcije. Pokušajte ponovo.")),
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
  void _openUserRejectDialog({required Freelancer user}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Odbijeno?'),
        content: const Text('Jeste li sigurni da želite odbiti ovog radnika?'),
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
                  const SnackBar(content: Text("Radnik je uspješno odbijen i uklonjen..")),
                );
              } on Exception catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Greška tokom akcije. Pokušajte ponovo.")),
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
      padding: const EdgeInsets.all(16),
      child: Column(
      
        children: [
          Wrap(
           
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 350,
                child: TextField(
                  controller: _firstNameController,
                  decoration:  InputDecoration(
                    labelText: 'Ime i prezime',
                    prefixIcon: const Icon(Icons.search_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                     suffixIcon: _firstNameController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _firstNameController.clear();
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
               SizedBox(
                width: 350,
                child: TextField(
                  controller: _emailController,
                  decoration:  InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),

                    ),
                     suffixIcon: _emailController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _firstNameController.clear();
                            _onSearchChanged();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
             
              const SizedBox(width: 12),
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
          const SizedBox(height: 20),
          
            Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    
            child:  Row(
              children: [
                const Expanded(flex: 2, child: Text("Ime", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const Expanded(flex: 2, child: Text("Prezime", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const Expanded(flex: 3, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const Expanded(flex: 3, child: Text("Lokacija", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const Expanded(flex: 3, child: Text("Radni Dani", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const Expanded(flex: 2, child: Text("Iskustvo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const Expanded(flex: 2, child: Text("Ocjena", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
               
                 const Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        "Slika",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                const Expanded(flex: 3, child: Text("Usluge", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      showApplicants ? const Expanded(flex: 1, child: Center(child: Text("CV", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))) : const SizedBox(width: 0),

               const Expanded(flex: 1, child: Center(child: Text("Akcije", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
               
              
              ],
            ),
          ),
          const SizedBox(height: 6,),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: freelancerPagination.items.isEmpty && !isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/usersNotFound.webp', width: 250, height: 250),
                        const SizedBox(height: 16),
                        const Text(
                          'Radnici nisu pronađeni.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  : ListView.separated(
              itemCount: freelancerPagination.items.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final f = freelancerPagination.items[index];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: index.isEven ? Colors.grey.shade50 : Colors.white,
                    child: _buildFreelancers(f),
                  ),
                );
              },
              ),
            )
            
           
          ),
            const SizedBox(height: 12),


        if (_firstNameController.text.isEmpty && freelancerPagination.hasNextPage == false)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            children: List.generate(
              (freelancerPagination.count / freelancerPagination.pageSize).ceil(),
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
                    await freelancerPagination.goToPage(
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

                if (_firstNameController.text.isEmpty && freelancerPagination.hasNextPage == false)

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Prikazano ${(currentPage - 1) * freelancerPagination.pageSize + 1}"
              " - ${(currentPage - 1) * freelancerPagination.pageSize + freelancerPagination.items.length}"
              " od ${freelancerPagination.count}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        ],
      ),
    );
  }
  Widget _buildFreelancers(Freelancer freelancer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(freelancer.freelancerNavigation?.firstName ?? '')),
          Expanded(flex: 2, child: Text(freelancer.freelancerNavigation?.lastName ?? '')),
          Expanded(flex: 3, child: Text(freelancer.freelancerNavigation?.email ?? '')),
          Expanded(flex: 3, child: Text(freelancer.freelancerNavigation?.location?.locationName ?? '')),
          Expanded(flex: 3, child: Text( getWorkingDaysShort(freelancer.workingDays).join(', '))),
          Expanded(flex: 2, child: Text('${freelancer.experianceYears.toString()} godina')),
          Expanded(flex: 2, child: Text(freelancer.rating>1? '${freelancer.rating.toStringAsFixed(1)}/5.0' : 'Nema ocjene')),
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
                  child: freelancer.freelancerNavigation?.image != null
                      ? imageFromString(freelancer.freelancerNavigation!.image!)
                      : const Image(
                          image: AssetImage(
                              'assets/images/Sample_User_Icon.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
          Expanded( flex: 3, child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: freelancer.freelancerServices.map((FreelancerService s) {
                return Text(s.service?.serviceName ?? '', style: const TextStyle(fontSize: 12));
              }).toList(),
            ),
          ),
          showApplicants ?
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              if (freelancer.cv != null) {
                showPdfDialog(context, freelancer.cv!, "CV");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nema učitanog dokumenta")),
                );
              }
            },
            child: const Icon(Icons.document_scanner_outlined, size: 18),
          ),
        ): const SizedBox(width: 0),

          
Expanded(
  flex:1,
  child: Center(
    child: Builder(
            builder: (context) {
        if (showApplicants) {
          // Accept / Reject buttons
          return PopupMenuButton<String>(
            tooltip: 'Akcije',
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onSelected: (value) async {
              if (value == 'approve') {
                _openUserApproveDialog(user: freelancer);
                await freelancerPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
                  'isApplicant': showApplicants,
                  'FirstNameGTE': _firstNameController.text,
                  'Email': _emailController.text,
                });
              } else if (value == 'reject') {
                _openUserRejectDialog(user: freelancer);
                await freelancerPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
                  'isApplicant': showApplicants,
                  'FirstNameGTE': _firstNameController.text,
                  'Email': _emailController.text,
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('Prihvati'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reject',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Odbij'),
                  ],
                ),
              ),
            ],
            
         
          );
        } else if (showDeleted) {
          // Restore
          return IconButton(
            color: Colors.black,
            tooltip: 'Reaktiviraj',
            onPressed: () => _openUserRestoreDialog(user: freelancer),
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
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Uredi')),
              PopupMenuItem(value: 'delete', child: Text('Izbriši')),
            ],
            onSelected: (value) async {
              if (value == 'edit') {
                await showDialog(
                  context: context,
                  builder: (_) => FreelancerUpdateDialog(freelancer: freelancer),
                );
                await freelancerPagination.refresh(newFilter: {
                  'isDeleted': showDeleted,
                  'isApplicant': showApplicants,
                  'FirstNameGTE': _firstNameController.text,
                  'Email': _emailController.text,
                });
              } else if (value == 'delete') {
                _openUserDeleteDialog(user: freelancer);
              }
            },
          );
        }
      },
    ),
  ),
)

        ],
      ),
    );
  }
}