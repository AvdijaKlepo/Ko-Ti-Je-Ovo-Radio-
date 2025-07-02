import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/store.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:provider/provider.dart';

class StoreUpdateDialog extends StatefulWidget {
  const StoreUpdateDialog({required this.store, super.key});
  final Store store;

  @override
  State<StoreUpdateDialog> createState() => _StoreUpdateDialogState();
}

class _StoreUpdateDialogState extends State<StoreUpdateDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late StoreProvider storesProvider;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;

  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    storesProvider = context.read<StoreProvider>();
    _initialValue = {
      "storeName": widget.store.storeName,
      "description": widget.store.description,

      "locationId": widget.store.location?.locationId,
    };
    _getLocations();
  }

  Future<void> _getLocations() async {
    try {
      var fetchedLocations = await locationProvider.get();
      setState(() {
        locationResult = fetchedLocations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                      const Text("Podaci Trgovine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: "storeName", decoration: const InputDecoration(labelText: "Ime Trgovine:")),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: "description", decoration: const InputDecoration(labelText: "Opis")),
                      const SizedBox(height: 20),
                     
                    

                       FormBuilderDropdown<int>(
                        name: 'locationId',
                        decoration: const InputDecoration(labelText: "Lokacija*"),
                        validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        items: locationResult?.result
                                .map((loc) => DropdownMenuItem(
                                      value: loc.locationId,
                                      child: Text(loc.locationName ?? ''),
                                    ))
                                .toList() ??
                            [],
                      ),
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
      request['isApplicant'] = false;
      request['isDeleted'] = false;
      request['roles']=[10,1011];
      request['userId']=widget.store.user?.userId;
    

      try {
        await storesProvider.update(widget.store.storeId, request);
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