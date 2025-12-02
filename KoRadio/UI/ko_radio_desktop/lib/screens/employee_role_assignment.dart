import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_role.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_role_provider.dart';
import 'package:provider/provider.dart';

class CompanyRoleAssignmentDialog extends StatefulWidget {
  const CompanyRoleAssignmentDialog({super.key, required this.companyId, required this.companyEmployee});
  final int companyId;
  final CompanyEmployee companyEmployee;
  @override
  State<CompanyRoleAssignmentDialog> createState() => _CompanyRoleAssignmentDialogState();
}

class _CompanyRoleAssignmentDialogState extends State<CompanyRoleAssignmentDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  final Map<String, dynamic> _initialValue = {};
  late CompanyRoleProvider companyRoleProvider;
  SearchResult<CompanyRole>? companyRoleResult;
  late CompanyEmployeeProvider companyEmployeeProvider;

  @override
  void initState() {
    super.initState(); 
      companyRoleProvider = context.read<CompanyRoleProvider>();
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
     
      await _getCompanyRoles();
    });
  }
  Future<void> _getCompanyRoles() async {
    try {
      var filter = {'companyId': widget.companyId};
      var fetchedCompanyRoles = await companyRoleProvider.get(filter: filter);
      setState(() {
        companyRoleResult = fetchedCompanyRoles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return  Dialog(
      insetPadding: const EdgeInsets.all(24),
      surfaceTintColor: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
       
        child: 
             Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SingleChildScrollView(
                   child: FormBuilder(
                     key: _formKey,
                     initialValue: _initialValue,
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
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
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text("Dodaj ulogu za zaposlenika ${widget.companyEmployee.user?.firstName} ${widget.companyEmployee.user?.lastName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                             IconButton(
                               icon: const Icon(Icons.close, color: Colors.white),
                               onPressed: () => Navigator.of(context).pop(),
                               splashRadius: 20,
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              FormBuilderDropdown(
                               initialValue: widget.companyEmployee.companyRoleId,
                               name: 'companyRoleId', decoration: const InputDecoration(labelText: "Uloga:"),
                               items: companyRoleResult?.result.map((e) => DropdownMenuItem(value: e.companyRoleId, child: Text(e.roleName ?? ''))).toList() ?? []),
                                    
                                                  
                                                  const SizedBox(height: 30),
                               Align(
                                 alignment: Alignment.centerRight,
                                 child: ElevatedButton.icon(
                                   style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(27, 76, 125, 25),elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                   icon: const Icon(Icons.save, color: Colors.white),
                                   label: const Text("Sačuvaj",style: TextStyle(color: Colors.white),),
                                   onPressed: _save,
                                 ),
                               ),
                            ],
                          ),
                        ),
                              
                     ],
                   ),
                   ),
                 ),
              ],
                         ),
           
       
      ),
    );
    
  }

   Future<void> _save() async{
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      try {
         await companyEmployeeProvider.update(
                                              widget.companyEmployee.companyEmployeeId,
                                              {
                                               "userId": widget.companyEmployee.userId,
                                               "companyId": widget.companyEmployee.companyId,
                                               "isDeleted": widget.companyEmployee.isDeleted,
                                               "isApplicant": widget.companyEmployee.isApplicant,
                                             
                                               "companyRoleId": _formKey.currentState!.value["companyRoleId"],
                                               "dateJoined": widget.companyEmployee.dateJoined?.toUtc().toIso8601String(),
                                              },
                                            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Uloga uspješno dodana!")),
          
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
    }
  }
  }
