import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:provider/provider.dart';

class AddEmployeeDialog extends StatefulWidget {
  const AddEmployeeDialog({super.key, required this.companyId});
  final int companyId;

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  late CompanyEmployeeProvider companyEmployeeProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
    });
  }
  
  Future<void> _save() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
      request['companyId'] = widget.companyId;

      try {
      
          await companyEmployeeProvider.insert(request);
       
    
      
 ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Poslan zahtjev korisniku!")),
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
                    Text("Zahtjev će biti poslan korisniku sa navedenom email adresom.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                    SizedBox(height: 15,),
                    FormBuilder(key: _formKey,child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                           FormBuilderTextField(name: 'email',decoration: const InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                            ),),
                        ])),
                   
                    SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(27, 76, 125, 25),elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              onPressed: _save,
                              icon: const Icon(Icons.save,color: Colors.white,),
                              label: const Text("Sačuvaj", style: TextStyle(color: Colors.white),),
                            ),
                          )
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}