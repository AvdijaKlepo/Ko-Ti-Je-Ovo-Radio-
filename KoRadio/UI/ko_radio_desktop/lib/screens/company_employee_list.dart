import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/screens/add_employee_dialog.dart';
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
  SearchResult<Company>? companyResult;
  SearchResult<CompanyEmployee>? companyEmployeeResult;

  final TextEditingController _companyNameController = TextEditingController();
  bool showApplicants = false;
  bool showDeleted = false;

  Timer? _debounce;
  int _selectedCompanyId = AuthProvider.selectedCompanyId ?? 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      companyProvider = context.read<CompanyProvider>();
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();

       if (AuthProvider.selectedCompanyId == null) {

      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (AuthProvider.selectedCompanyId != null) {
      await _getCompany();
      await _getEmployees();
    } else {
      debugPrint("selectedCompanyId is still null, aborting fetch.");
    }
     
    });
  }
    @override
  void dispose() {
    _debounce?.cancel();
    _companyNameController.dispose();
    super.dispose();
  }
  Future<void> _getEmployees() async {
    final filter = {
      'CompanyId':AuthProvider.selectedCompanyId,
    };

    final fetchedEmployees = await companyEmployeeProvider.get(filter: filter);
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
  
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _getCompany);
  }

   void _openUserDeleteDialog({required CompanyEmployee companyEmployee}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izbriši?'),
        content: Text('Jeste li sigurni da želite izbrisatu ovu firmu?'),
        actions: [
          TextButton(
            onPressed: () async {
              await companyProvider.delete(companyEmployee.companyEmployeeId);
              _getCompany();
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

  void _openUserRestoreDialog({required CompanyEmployee companyEmployee}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vrati?'),
        content: Text('Jeste li sigurni da želite vratiti ovu firmu?'),
        actions: [
          TextButton(
            onPressed: () async {
              await companyProvider.delete(companyEmployee.companyEmployeeId);
              _getCompany();
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
   void _openEmployeeRoleDialog({required int companyId}) {
    showDialog(
      context: context,
      builder: (_) =>
          CompanyRoleDialog(companyId: companyId),
    
    );
  }
     void _openEmployeeRoleAddDialog({required int companyId, required CompanyEmployee companyEmployee}) {
    showDialog(
      context: context,
      builder: (_) =>
          CompanyRoleAssignmentDialog(companyId: companyId,companyEmployee: companyEmployee,),
    
    );
    _getEmployees();
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
                      _getCompany();
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
                      _getCompany();
                    },
                  ),
                ],
              ),
               Row(
                children: [
                  
                  ElevatedButton(onPressed: ()=> _openEmployeeRoleDialog(companyId: _selectedCompanyId,),child: const Text("Uloge"),)
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
    
    
         Row(
  children: [
    const Expanded(flex: 2, child: Text("Ime", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 2, child: Text("Prezime", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 2, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Telefonski broj", style: TextStyle(fontWeight: FontWeight.bold))),
    const Expanded(flex: 3, child: Text("Uloga", style: TextStyle(fontWeight: FontWeight.bold))),

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
            child: companyEmployeeResult == null
                ? const Center(child: CircularProgressIndicator())
                : companyEmployeeResult!.result.isEmpty
                    ? const Center(child: Text('No companies found.'))
                    : ListView.separated(
                        itemCount: companyEmployeeResult!.result.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = companyEmployeeResult!.result[index];
             

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(c.user?.firstName ?? 'Nema')),
                                Expanded(flex: 2, child: Text(c.user?.lastName ?? '')),
                                Expanded(flex: 2, child: Text(c.user?.email ?? '')),
                                Expanded(flex: 3, child: Text(c.user?.phoneNumber ?? '')),
                                Expanded(flex:3,child: InkWell(child:Text(c.companyRoleName ?? 'Nema Ulogu'),onTap: ()=>
                              _openEmployeeRoleAddDialog(companyId: _selectedCompanyId,companyEmployee: c))),
                                if (!showApplicants && !showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Uredi',
                                      onPressed: () async {
                                       
                                      },
                                    ),
                                  ),
                                if (!showApplicants && !showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Izbriši',
                                      onPressed: () => _openUserDeleteDialog(companyEmployee: c),
                                    ),
                                  ),
                                if (showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.restore),
                                      tooltip: 'Vrati',
                                      onPressed: () => _openUserRestoreDialog(companyEmployee: c),
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
                                          }
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
          
          ElevatedButton(onPressed: (){
            _openAddEmployeeDialog(companyId: _selectedCompanyId);

          }, child: Text("Dodaj zaposlenika")),
        ],
      ),
    );
  }
}