import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_role.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_role_provider.dart';
import 'package:provider/provider.dart';

class CompanyRoleDialog extends StatefulWidget {
  const CompanyRoleDialog({super.key, required this.companyId});
  final int companyId;

  @override
  State<CompanyRoleDialog> createState() => _CompanyRoleDialogState();
}

class _CompanyRoleDialogState extends State<CompanyRoleDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  final Map<String, dynamic> _initialValue = {};
  late CompanyRoleProvider companyRoleProvider;
  late CompanyEmployeeProvider companyEmployeeProvider;
  SearchResult<CompanyRole>? companyRoleResult;
  SearchResult<CompanyEmployee>? companyEmployeeResult;

  @override
  void initState() {
    super.initState();
    companyRoleProvider = context.read<CompanyRoleProvider>();
    companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
     
      await _getCompanyRoles();
      await _getCompanyEmployees();
    });
  }
  Future<void> _getCompanyEmployees() async {
    try {
      var filter = {'companyId': widget.companyId};
      var fetchedCompanyEmployees = await companyEmployeeProvider.get(filter: filter);
      setState(() {
        companyEmployeeResult = fetchedCompanyEmployees;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
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

  Future<void> _save() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
      request['companyId'] = widget.companyId;

      try {
        if (_initialValue['roleName'] == null) {
          await companyRoleProvider.insert(request);
        } else {
          await companyRoleProvider.update(widget.companyId, request);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Uloga uspješno sačuvana!")),
        );
        await _getCompanyRoles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 600,
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Trenutne uloge", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildRoleList(),
                    const Divider(height: 32),
                    const Text("Dodaj novu ulogu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormBuilder(
                      key: _formKey,
                      initialValue: _initialValue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FormBuilderTextField(
                            name: "roleName",
                            decoration: const InputDecoration(
                              labelText: "Naziv uloge",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(27, 76, 125, 25),elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              onPressed: _save,
                              icon: const Icon(Icons.save,color: Colors.white,),
                              label: const Text("Sačuvaj",style: TextStyle(color: Colors.white),),
                            ),
                          )
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

  Widget _buildRoleList() {
    if (companyRoleResult == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (companyRoleResult!.result.isEmpty) {
      return const Center(child: Text('Nema definisanih uloga.'));
    } else {
      return SizedBox(
        height: 200,
        child: ListView.separated(
          itemCount: companyRoleResult!.result.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final c = companyRoleResult!.result[index];
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(top: 5),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                title: Text(c.roleName ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(companyEmployeeResult?.result.where((element) => element.companyRoleId == c.companyRoleId).map((e) => e.user?.firstName ?? '').join(', ') ?? ''),
              ),

            );
          },
        ),
      );
    }
  }
}
