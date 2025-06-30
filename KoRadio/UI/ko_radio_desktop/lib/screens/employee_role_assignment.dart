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
  Map<String, dynamic> _initialValue = {};
  late CompanyRoleProvider companyRoleProvider;
  SearchResult<CompanyRole>? companyRoleResult;
  late CompanyEmployeeProvider companyEmployeeProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      companyRoleProvider = context.read<CompanyRoleProvider>();
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
      _getCompanyRoles();
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
      child: SizedBox(
        width: 500,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: SvgPicture.asset(
                  'assets/images/undraw_data-input_whqw.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(24.0), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
              ],
            )),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  initialValue: _initialValue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Text("Dodaj ulogu za zaposlenika ${widget.companyEmployee.user?.firstName} ${widget.companyEmployee.user?.lastName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                     FormBuilderDropdown(name: 'companyRoleId', decoration: const InputDecoration(labelText: "Uloga:"),
                      items: companyRoleResult?.result.map((e) => DropdownMenuItem(value: e.companyRoleId, child: Text(e.roleName ?? ''))).toList() ?? []),

                 
                 const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text("Sačuvaj"),
                          onPressed: _save,
                        ),
                      ),

                  ],
                ),
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
