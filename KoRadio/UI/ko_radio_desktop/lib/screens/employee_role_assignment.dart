import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';

class CompanyRoleAssignmentDialog extends StatefulWidget {
  const CompanyRoleAssignmentDialog({super.key});

  @override
  State<CompanyRoleAssignmentDialog> createState() => _CompanyRoleAssignmentDialogState();
}

class _CompanyRoleAssignmentDialogState extends State<CompanyRoleAssignmentDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
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

  void _save() {
  }
}