import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_role.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';
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
      _formKey.currentState?.patchValue({
        'roleName': role.roleName,
      });

    });
  }
  Future<void> _deleteRole(CompanyRole role) async {
    final message = ScaffoldMessenger.of(context);
    try {
      await companyRoleProvider.delete(role.companyRoleId!);
      message.showSnackBar(const SnackBar(content: Text("Uloga uspješno izbrisana!")));
      await _getCompanyRoles();
      setState(() {
        _editingRole = null;
        _initialValue = {};
        _formKey.currentState?.reset();
      });
    } on UserException catch (e) {
      message.showSnackBar( SnackBar(content: Text(e.exMessage)));
    }
     catch (e) {
      message.showSnackBar(const SnackBar(content: Text("Greška tokom brisanja uloge. Molimo pokušajte ponovo.")));
    }
  }

  Future<void> _save() async {
    final message = ScaffoldMessenger.of(context);

    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final request = Map<String, dynamic>.from(_formKey.currentState!.value);
    request['companyId'] = widget.companyId;
    String roleNameRequest = request['roleName'];
    List<CompanyRole> roleNameRequestList = companyRoleResult?.result.where((element) => element.roleName==roleNameRequest).toList() ?? [];
    if(roleNameRequestList.isNotEmpty){
      message.showSnackBar(const SnackBar(content: Text("Uloga već postoji u firmi.")));
      return;
    }

    try {
      if (_editingRole == null) {
        await companyRoleProvider.insert(request);
      } else {
        await companyRoleProvider.update(_editingRole!.companyRoleId!, request);
      }

      message.showSnackBar(const SnackBar(content: Text("Uloga uspješno sačuvana!")));
      await _getCompanyRoles();
      setState(() {
        _editingRole = null;
        _initialValue = {};
        _formKey.currentState?.patchValue({
          'roleName': null,
        });
      });
    } catch (e) {
      message.showSnackBar(const SnackBar(content: Text("Greška tokom slanja zahtjeva. Molimo pokušajte ponovo.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 600,
        height: MediaQuery.of(context).size.height * 0.65,
        child: 
            SingleChildScrollView(
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
                        const Text(
            'Uloge firme',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
                        ),
                        IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRoleList(),
                 
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
                        
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(_editingRole != null ? "Uredi ulogu" : "Dodaj novu ulogu",
                      style: const TextStyle(    fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
                      if(_editingRole!=null)
                      ElevatedButton.icon(onPressed: (){
                        setState(() {
                          _editingRole = null;
                          
                           _formKey.currentState?.patchValue({
                             'roleName': null,
                           });
                         
                        });
                      }, icon: const Icon(Icons.close,color:Colors.white), label: const Text('Završi uređivanje'))
                      ],
                      ),
                    ),
                 
                  const SizedBox(height: 16),
                  FormBuilder(
                    key: _formKey,
                    initialValue: _initialValue,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                  ),
                ],
              ),
            ),
          
        
      ),
    );
  }

  Widget _buildRoleList() {
    if (companyRoleResult == null) return const Center(child: CircularProgressIndicator());
    if (companyRoleResult!.result.isEmpty) return const Center(child: Text('Nema definisanih uloga.'));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
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
              surfaceTintColor: Colors.white,
          
              elevation: 1,
              margin: const EdgeInsets.only(top: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                title: Text(role.roleName ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(assignedUsers),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:<Widget> [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _editRole(role),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteRole(role),
                    ),
                  ],
                ),
              ),
            );
            
          },
        ),
      ),
    );
  }
}
