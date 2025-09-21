import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/models/company_role.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/company_role_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/add_employee_dialog.dart';
import 'package:ko_radio_desktop/screens/company_employee_details.dart';
import 'package:ko_radio_desktop/screens/company_role_dialog.dart';
import 'package:ko_radio_desktop/screens/employee_role_assignment.dart';
import 'package:provider/provider.dart';

class CompanyEmployeeList extends StatefulWidget {
  const CompanyEmployeeList({super.key});

  @override
  State<CompanyEmployeeList> createState() => _CompanyEmployeeListState();
}

class _CompanyEmployeeListState extends State<CompanyEmployeeList> {
  late CompanyProvider companyProvider;
  late CompanyEmployeeProvider companyEmployeeProvider;
  late CompanyJobAssignmentProvider companyJobAssignmentProvider;
  late CompanyRoleProvider companyRoleProvider;
  late PaginatedFetcher<CompanyEmployee> companyEmployeePagination;
  SearchResult<Company>? companyResult;
  SearchResult<CompanyEmployee>? companyEmployeeResult;
  SearchResult<CompanyJobAssignment>? companyJobAssignmentResult;
  SearchResult<CompanyRole>? companyRoleResult;

  final TextEditingController _companyNameController = TextEditingController();
  int? _selectedCompanyRoleId;
  bool showApplicants = false;
  bool showDeleted = false;
  bool _isInitialized = false;
  bool isLoading = false;
  int companyEmployeeId = 0;
  int currentPage=1;
  List<DropdownMenuItem<int>> roleDropdownItems = [];

  Timer? _debounce;
  final int _selectedCompanyId = AuthProvider.selectedCompanyId ?? 0;
  @override
void initState() {
  super.initState();


  companyEmployeePagination = PaginatedFetcher<CompanyEmployee>(
    pageSize: 0,
    initialFilter: {},
    fetcher: ({
      required int page,
      required int pageSize,
      Map<String, dynamic>? filter,
    }) async {
      return PaginatedResult(result: [], count: 0);
    },
  );

  
  companyProvider = context.read<CompanyProvider>();
  companyJobAssignmentProvider = context.read<CompanyJobAssignmentProvider>();
  companyRoleProvider = context.read<CompanyRoleProvider>();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    setState(() => isLoading = true);


    if (AuthProvider.selectedCompanyId == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (AuthProvider.selectedCompanyId != null) {
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();

      companyEmployeePagination = PaginatedFetcher<CompanyEmployee>(
        pageSize: 20,
        initialFilter: {
        },
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
          
        }) async {
          final result = await companyEmployeeProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));

      await companyEmployeePagination.refresh(newFilter: {
        'CompanyId': AuthProvider.selectedCompanyId,
        'IsDeleted': showDeleted,
        'IsApplicant': showApplicants,
      });
      await _getCompany();
      await _getJobAssignments();
      await _getCompanyRoles();

      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
    }
  });
}

    @override
  void dispose() {
    _debounce?.cancel();
    _companyNameController.dispose();
    super.dispose();
  }
  Future<void> _getJobAssignments() async {
    final filter = {
      'IsFinished':false,
      'IsCancelled':false,
    };

    final fetchedJobAssignments = await companyJobAssignmentProvider.get(filter: filter);
    if(!mounted) return;
    setState(() {
      companyJobAssignmentResult = fetchedJobAssignments;
    });
  }

  int getJobsPerEmployee(int companyEmployeeId) {
    if (companyJobAssignmentResult == null) return 0;
    return companyJobAssignmentResult!.result
        .where((element) => element.companyEmployeeId == companyEmployeeId)
        .length;
  }
  Future<void> _getEmployees() async {
    final filter = {
      'CompanyId':AuthProvider.selectedCompanyId,
    };

    final fetchedEmployees = await companyEmployeeProvider.get(filter: filter);
    if(!mounted) return;
    setState(() {
      companyEmployeeResult = fetchedEmployees;
    });
  }
  Future<void> _getCompany() async {
    final filter = {
 
     
      'CompanyId':AuthProvider.selectedCompanyId,
    };

    final fetchedCompanies = await companyProvider.get(filter: filter);
    setState(() {
      companyResult = fetchedCompanies;
    });
  }
  Future<void> _getCompanyRoles() async {
    final filter = {
      'CompanyId':AuthProvider.selectedCompanyId,
    };

    try {
  final fetchedCompanyRoles = await companyRoleProvider.get(filter: filter);
  if(!mounted) return;
  setState(() {
    companyRoleResult = fetchedCompanyRoles;
    roleDropdownItems = [
        const DropdownMenuItem(value: null, child: Text("Sve uloge")),
        ...fetchedCompanyRoles.result.map((e) => DropdownMenuItem(
              value: e.companyRoleId,
              child: Text(e.roleName ?? ''),
            ))
      ];
  });
} on Exception {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Greška u dohvaćanju uloga radnika'),
  ));
}
  }
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _getCompany);
    _refreshWithFilter();
  }
   Future<void> _refreshWithFilter() async {
    if(isLoading) return;
  setState(() => isLoading = true);

  final filter = <String, dynamic>{
    'CompanyId': AuthProvider.selectedCompanyId,
  };

  if (_companyNameController.text.trim().isNotEmpty) {
    filter['Name'] = _companyNameController.text.trim();
  }

  if (_selectedCompanyRoleId != null) {
    filter['EmployeeRole'] = _selectedCompanyRoleId;
  }

  if (showApplicants) {
    filter['IsApplicant'] = true;
  }
  if (showDeleted) {
    filter['IsDeleted'] = true;
  }
  if (!showApplicants && !showDeleted) {

    filter['IsApplicant'] = false;
    filter['IsDeleted'] = false;
  }

  await companyEmployeePagination.refresh(newFilter: filter);
  setState(() => isLoading = false);
}

   void _openUserDeleteDialog({required CompanyEmployee companyEmployee}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izbriši?'),
        content: const Text('Jeste li sigurni da želite izbrisatu ovog zaposlenika?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              final message = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              
              try{
              await companyEmployeeProvider.delete(companyEmployee.companyEmployeeId);
                await companyEmployeePagination.refresh(newFilter: {
                'CompanyId': AuthProvider.selectedCompanyId,
                'IsDeleted': showDeleted,
                'IsApplicant': showApplicants,
              });
              message.showSnackBar(const SnackBar(content: Text('Radnik je uspješno izbrisan.')));
              }catch(e){
                message.showSnackBar(const SnackBar(content: Text('Greška u brisanju radnika. Pokušajte ponovo.')));
              }
              await companyEmployeePagination.refresh(newFilter: {
                'CompanyId': AuthProvider.selectedCompanyId,
                'IsDeleted': showDeleted,
                'IsApplicant': showApplicants,
              });
              navigator.pop(true);
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }

  void _openUserRestoreDialog({required CompanyEmployee companyEmployee}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vrati?'),
        content: const Text('Jeste li sigurni da želite vratiti ovog zaposlenika?'),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              final message = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              try{
                await companyEmployeeProvider.delete(companyEmployee.companyEmployeeId);
                await companyEmployeePagination.refresh(newFilter: {
                  'CompanyId': AuthProvider.selectedCompanyId,
                  'IsDeleted': showDeleted,
                  'IsApplicant': showApplicants,
                });
                message.showSnackBar(const SnackBar(content: Text('Radnik je uspješno reaktiviran.')));
              }catch(e){
                message.showSnackBar(const SnackBar(content: Text('Greška u brisanju radnika. Pokušajte ponovo.')));
              }
              await companyEmployeeProvider.delete(companyEmployee.companyEmployeeId);
              
              navigator.pop(true);
            },
            child: const Text('Da'),
          ),
        ],
      ),
    );
  }
   void _openEmployeeRoleDialog({required int companyId}) async {
    await showDialog(
      context: context,
      builder: (_)  =>
          CompanyRoleDialog(companyId: companyId),
          

    );

    await companyEmployeePagination.refresh(newFilter: {
      'CompanyId': AuthProvider.selectedCompanyId,
      'IsDeleted': showDeleted,
      'IsApplicant': showApplicants,
    });
    await _getCompanyRoles();
    
  }
     Future<void> _openEmployeeRoleAddDialog({
  required int companyId,
  required CompanyEmployee companyEmployee,
}) async {
  final result = await showDialog(
    context: context,
    builder: (_) => CompanyRoleAssignmentDialog(
      companyId: companyId,
      companyEmployee: companyEmployee,
    ),
  );


  if (result == true) {
    await companyEmployeePagination.refresh(newFilter: {
      'CompanyId': AuthProvider.selectedCompanyId,
      'IsDeleted': showDeleted,
      'IsApplicant': showApplicants,
    });
  }
}

  void _openAddEmployeeDialog({required int companyId}) {
    showDialog(
      context: context,
      builder: (_) =>
          AddEmployeeDialog(companyId: companyId,),
    
    );
  }
  
  @override
  Widget build(BuildContext context) {
    var filterOutLoggedInUser = companyEmployeePagination.items.toList();
    if(!_isInitialized) return const Center(child: CircularProgressIndicator());
    

   return Padding(
  padding: const EdgeInsets.all(12),
  child: Column(
    children: [
      Wrap(
        spacing: 8, 
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 250, 
            child: TextField(
              controller: _companyNameController,
              decoration: InputDecoration(
                labelText: 'Ime Zaposlenika',
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
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<int>(
              value: _selectedCompanyRoleId,
              decoration: InputDecoration(
                labelText: 'Uloge',
                prefixIcon:
                    const Icon(Icons.content_paste_search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: roleDropdownItems,
              onChanged: (val) {
                setState(() => _selectedCompanyRoleId = val);
                _onSearchChanged();
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
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
            mainAxisSize: MainAxisSize.min,
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
          ElevatedButton(
            onPressed: () async {
              _openEmployeeRoleDialog(companyId: _selectedCompanyId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Uloge",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _openAddEmployeeDialog(companyId: _selectedCompanyId);
            },
            child: const Text(
              "Dodaj zaposlenika",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
  


          
          const SizedBox(height: 16),
    
    
         Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
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
           child: Row(
             children: [
               const Expanded(flex: 2, child: Text("Ime", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
               const Expanded(flex: 2, child: Text("Prezime", style: TextStyle(fontWeight: FontWeight.bold ,color: Colors.white))),
               const Expanded(flex: 2, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
               const Expanded(flex: 3, child: Text("Telefonski broj", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
               const Expanded(flex: 3, child: Text("Uloga", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
               const Expanded(flex: 3, child: Center(child: Text("Slika", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
               const Expanded(flex: 3, child: Center(child: Text("Broj Angažmana", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
           
              if (!showApplicants && !showDeleted)
                  const Expanded(flex: 2, child: Icon(Icons.switch_account, size: 18,color: Colors.white)),
                if (!showApplicants && !showDeleted)
                  const Expanded(flex: 2, child: Icon(Icons.delete, size: 18, color: Colors.white)),
                if (showDeleted)
                  const Expanded(flex: 2, child: Icon(Icons.restore, size: 18, color: Colors.white)),
                if (showApplicants)
                  const Expanded(flex: 2, child: Text("Akcije", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
             ],
           ),
         ),

      Expanded(
  child: companyEmployeePagination.isLoading && companyEmployeePagination.items.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : companyEmployeePagination.items.isEmpty
          ? const Center(child: Text('Nema zaposlenika.'))
          : ListView.separated(
              
              itemCount: filterOutLoggedInUser.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                

                final c = filterOutLoggedInUser[index];
               return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: index.isEven ? Colors.grey.shade50 : Colors.white,
                    child: _buildEmployee(c),
                  ),
                );
               
              },
            ),
),

if (_companyNameController.text.isEmpty && companyEmployeePagination.hasNextPage == false)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            children: List.generate(
              (companyEmployeePagination.count / companyEmployeePagination.pageSize).ceil(),
              (index) {
                final pageNum = index + 1;
                final totalPages = (companyEmployeePagination.count / companyEmployeePagination.pageSize).ceil();
                final isActive = currentPage == pageNum;

                final bool isSinglePage = totalPages <= 1;

                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isActive 
                        ? const Color.fromRGBO(27, 76, 125, 1) 
                        : isSinglePage ? Colors.grey : Colors.white, 
                    foregroundColor: isActive 
                        ? Colors.white 
                        : Colors.black87,
                    side: BorderSide(
                      color: isActive 
                        ? Colors.transparent 
                        : isSinglePage ? Colors.grey.shade400 : Colors.grey.shade300, 
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: isSinglePage 
                      ? null
                      : () async {
                          if (!mounted) return;
                          setState(() {
                            currentPage = pageNum;
                            isLoading = true;
                          });
                          await companyEmployeePagination.goToPage(
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
                  child: Text("$pageNum",style: TextStyle(color: isActive ? Colors.white : Colors.black87),),
                );
              },
            ),
          ),


        const SizedBox(height: 8),

                if (_companyNameController.text.isEmpty && companyEmployeePagination.hasNextPage == false)

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Prikazano ${(currentPage - 1) * companyEmployeePagination.pageSize + 1}"
              " - ${(currentPage - 1) * companyEmployeePagination.pageSize + companyEmployeePagination.items.length}"
              " od ${companyEmployeePagination.count}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
  


          
        
        ],
      ),
    );
  }
  Widget _buildEmployee(CompanyEmployee c) {
     return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(c.user?.firstName ?? 'Nema')),
                      Expanded(flex: 2, child: Text(c.user?.lastName ?? '')),
                      Expanded(flex: 2, child: Text(c.user?.email ?? '')),
                      Expanded(flex: 3, child: Text(c.user?.phoneNumber ?? '')),
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          child: Text(c.companyRoleName ?? 'Nema Ulogu'),
                          onTap: () async {
                            _openEmployeeRoleAddDialog(
                              companyId: _selectedCompanyId,
                              companyEmployee: c,
                            );
                          },
                        ),
                      ),
                       Expanded(
            flex: 3,
            child: Center(
              child: ClipOval(
                child: c.user?.image != null
                    ? imageFromString(c.user!.image!, width: 40, height: 40)
                    : const Image(
                        image: AssetImage(
                          'assets/images/Sample_User_Icon.png',
                        ),
                        fit: BoxFit.contain,
                        width: 40,
                        height: 40,
                      ),
              ),
            ),
            
          ),
                      Expanded(
                        flex: 3,
                        child: c.userId != AuthProvider.user?.userId
                            ? Center(child: Text('${getJobsPerEmployee(c.companyEmployeeId)}'))
                            : Center(child: const Text('Administrator')),
                      ),
                      if (!showApplicants && !showDeleted)
                        Expanded(
                          flex: 2,
                          child: IconButton(
                            color: c.userId != AuthProvider.user?.userId
                                ? Colors.black
                                : Colors.grey,
                            icon: const Icon(Icons.switch_account),
                            tooltip: 'Uredi',
                            onPressed: () async {
                              if (c.userId != AuthProvider.user?.userId) {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      CompanyEmployeeDetails(companyEmployee: c),
                                );
                              }
                            },
                          ),
                        ),
                      if (!showApplicants && !showDeleted)
                        Expanded(
                          flex: 2,
                          child: IconButton(
                            color: c.userId != AuthProvider.user?.userId
                                ? Colors.black
                                : Colors.grey,
                            icon: const Icon(Icons.delete),
                            tooltip: 'Izbriši',
                            onPressed: () async {
                              if (c.userId != AuthProvider.user?.userId) {
                                _openUserDeleteDialog(companyEmployee: c);
                              }
                            },
                          ),
                        ),
                      if (showDeleted)
                        Expanded(
                          flex: 2,
                          child: IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: 'Vrati',
                            onPressed: () async =>
                                _openUserRestoreDialog(companyEmployee: c),
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
                                onPressed: () async {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                tooltip: 'Odbaci',
                                onPressed: () async {},
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );

  }
}