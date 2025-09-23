
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:provider/provider.dart';

class LocationFormDialog extends StatefulWidget {
  final Location? location;

  const LocationFormDialog({super.key, this.location});

  @override
  State<LocationFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<LocationFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late LocationProvider locationProvider;


  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    _initialValue = {
      'locationId': widget.location?.locationId,
      'locationName': widget.location?.locationName,

    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 500,
        child: 
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
                         Text(widget.location!=null ?
                          'Uredi lokaciju': 'Dodaj lokaciju',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          FormBuilderTextField(
                            name: "locationName",
                            decoration: const InputDecoration(
                              labelText: "Naziv Lokacije*",
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Obavezno polje'),
                              FormBuilderValidators.maxLength(50, errorText: 'Maksimalno 30 znakova'),
                              FormBuilderValidators.minLength(2, errorText: 'Minimalno 2 znaka'),
                              FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim.'),
                            
                            ]),
                          ),
                        ],
                      ),
                    ),
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
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
 

      try {
        if (widget.location == null) {
          await locationProvider.insert(request);
        } else {
          await locationProvider.update(widget.location!.locationId!, request);
        }

        Navigator.of(context).pop(true); // Return success
      } on UserException catch (e) {
        _formKey.currentState?.invalidateField(
        name: "locationName",
        errorText: e.exMessage,
      );
      }
      
      catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
    }
  }


}
