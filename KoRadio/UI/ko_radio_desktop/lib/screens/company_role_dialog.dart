import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ko_radio_desktop/models/company_role.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
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
  late CompanyRoleProvider companyRoleProvider;
  SearchResult<CompanyRole>? companyRoleResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      companyRoleProvider = context.read<CompanyRoleProvider>();
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
        Navigator.pop(context, true);
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
                              onPressed: _save,
                              icon: const Icon(Icons.save),
                              label: const Text("Sačuvaj"),
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
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(c.roleName ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                
              ),
            );
          },
        ),
      );
    }
  }
}
