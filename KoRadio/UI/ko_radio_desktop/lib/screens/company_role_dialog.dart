import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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
  Map<String, dynamic> _initialValue = {};
  CompanyRole? _editingRole;

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
      final filter = {'companyId': widget.companyId};
      final fetchedCompanyEmployees = await companyEmployeeProvider.get(filter: filter);
      setState(() => companyEmployeeResult = fetchedCompanyEmployees);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _getCompanyRoles() async {
    try {
      final filter = {'companyId': widget.companyId};
      final fetchedCompanyRoles = await companyRoleProvider.get(filter: filter);
      setState(() => companyRoleResult = fetchedCompanyRoles);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $msg")));
  }

  void _editRole(CompanyRole role) {
    setState(() {
      _editingRole = role;
      _initialValue = {'roleName': role.roleName};
      _formKey.currentState?.reset();
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final request = Map<String, dynamic>.from(_formKey.currentState!.value);
    request['companyId'] = widget.companyId;

    try {
      if (_editingRole == null) {
        await companyRoleProvider.insert(request);
      } else {
        await companyRoleProvider.update(_editingRole!.companyRoleId!, request);
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uloga uspješno sačuvana!")));
      await _getCompanyRoles();
      setState(() {
        _editingRole = null;
        _initialValue = {};
        _formKey.currentState?.reset();
      });
    } catch (e) {
      _showError(e.toString());
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
                child: SvgPicture.asset('assets/images/undraw_data-input_whqw.svg', fit: BoxFit.cover),
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
                    Text(_editingRole != null ? "Uredi ulogu" : "Dodaj novu ulogu",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormBuilder(
                      key: _formKey,
                      initialValue: _initialValue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FormBuilderTextField(
                            name: "roleName",
                            decoration: const InputDecoration(labelText: "Naziv uloge", border: OutlineInputBorder()),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Obavezno polje'),
                              FormBuilderValidators.maxLength(15, errorText: 'Maksimalno 15 znakova'),
                              FormBuilderValidators.minLength(2, errorText: 'Minimalno 2 znaka'),
                              FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž ]+$',
                                  errorText: 'Dozvoljena su samo slova sa prvim velikim.'),
                            ]),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              onPressed: _save,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text("Sačuvaj", style: TextStyle(color: Colors.white)),
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
    if (companyRoleResult == null) return const Center(child: CircularProgressIndicator());
    if (companyRoleResult!.result.isEmpty) return const Center(child: Text('Nema definisanih uloga.'));

    return SizedBox(
      height: 200,
      child: ListView.separated(
        itemCount: companyRoleResult!.result.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final role = companyRoleResult!.result[index];
          final assignedUsers = companyEmployeeResult?.result
                  .where((e) => e.companyRoleId == role.companyRoleId)
                  .map((e) => e.user?.firstName ?? '')
                  .join(', ') ??
              '';

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(top: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(role.roleName ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(assignedUsers),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () => _editRole(role),
              ),
            ),
          );
        },
      ),
    );
  }
}
