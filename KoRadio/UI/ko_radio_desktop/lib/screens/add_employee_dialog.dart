import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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
    final message = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
      request['companyId'] = widget.companyId;

      try {
      
          await companyEmployeeProvider.insert(request);
       
    
      
 message.showSnackBar(
          const SnackBar(content: Text("Poslan zahtjev korisniku!")),
        );
        navigator.pop(true);
        
      } catch (e) {
        message.showSnackBar(
          const SnackBar(content: Text("Greška tokom slanja zahtjeva. Molimo pokušajte ponovo.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 600,
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
              'Dodaj radnika',
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
                  
                  const SizedBox(height: 15,),
                  FormBuilder(key: _formKey,child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                                
                           FormBuilderTextField(name: 'email',decoration: const InputDecoration(
                              labelText: "Email korisnika",
                              border: OutlineInputBorder(),
                            ),validator: FormBuilderValidators.required(errorText: "Obavezno polje"),
                            ),
                            
                        ]),
                  )),
                 
                  const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(27, 76, 125, 25),elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              onPressed: _save,
                              icon: const Icon(Icons.save,color: Colors.white,),
                              label: const Text("Pošalji", style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        )
                  
                ],
              ),
            ),
       
      ),
    );
  }
}