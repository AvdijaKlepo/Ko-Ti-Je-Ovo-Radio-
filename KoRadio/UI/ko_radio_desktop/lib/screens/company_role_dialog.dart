import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/providers/company_role_provider.dart';
import 'package:provider/provider.dart';

class CompanyRoleDialog extends StatefulWidget {
  CompanyRoleDialog({super.key, required this.companyId});
  final int companyId;

  @override
  State<CompanyRoleDialog> createState() => _CompanyRoleDialogState();
}

class _CompanyRoleDialogState extends State<CompanyRoleDialog> {
   final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CompanyRoleProvider companyRoleProvider;

  @override
  void initState() {
    super.initState();
    companyRoleProvider = context.read<CompanyRoleProvider>();
    _initialValue = {
 

  };
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  initialValue: _initialValue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Uloga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                     FormBuilderTextField(name: "roleName", decoration: const InputDecoration(labelText: "Naziv uloge:")),
                    const SizedBox(height: 20),

                 
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
   Future<void> _save() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
      request['companyId'] = widget.companyId;

      if(_initialValue['roleName']==null)
      {

      try {
        await companyRoleProvider.insert(request);
        print(request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Podaci uspješno uređeni!")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
      }
      else{
          try {
        await companyRoleProvider.update(widget.companyId, request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Podaci uspješno uređeni!")),
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
}