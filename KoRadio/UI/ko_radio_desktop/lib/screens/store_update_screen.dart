import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/store.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class StoreUpdateScreen extends StatefulWidget {
  const StoreUpdateScreen({required this.storeId, super.key});
  final int storeId;

  @override
  State<StoreUpdateScreen> createState() => _StoreUpdateScreenState();
}

class _StoreUpdateScreenState extends State<StoreUpdateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late StoreProvider storesProvider;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  SearchResult<Store>? storeResult;
  File? _image;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    storesProvider = context.read<StoreProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getStore();
      if (storeResult == null || storeResult!.result.isEmpty) return;

      final store = storeResult!.result.first;

      _initialValue = {
        "storeName":   store.storeName,
        "description": store.description,
        "address":     store.address,
        "image":       store.image,
        "locationId":  store.location?.locationId,
      };

      await _getLocations();
    });
  }

  Future<void> _getStore() async {
    var filter = {'StoreId': widget.storeId};
    try {
      var fetchedStores = await storesProvider.get(filter: filter);
      setState(() {
        storeResult = fetchedStores;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }

  Future<void> _getLocations() async {
    try {
      var fetchedLocations = await locationProvider.get();
      setState(() {
        locationResult = fetchedLocations;
      });
    } catch (e) {
      if (!mounted) return;
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
              child: storeResult == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: FormBuilder(
                        key: _formKey,
                        initialValue: _initialValue,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Podaci Trgovine",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),

                            FormBuilderTextField(
                              name: "storeName",
                              decoration: const InputDecoration(labelText: "Ime Trgovine:"),
                              validator: FormBuilderValidators.required(
                                  errorText: 'Obavezno polje'),
                            ),
                            const SizedBox(height: 20),

                            FormBuilderTextField(
                              name: "description",
                              decoration: const InputDecoration(labelText: "Opis"),
                              validator: FormBuilderValidators.required(
                                  errorText: 'Obavezno polje'),
                            ),
                            const SizedBox(height: 20),

                            FormBuilderTextField(
                              name: "address",
                              decoration: const InputDecoration(labelText: "Adresa"),
                              validator: FormBuilderValidators.required(
                                  errorText: 'Obavezno polje'),
                            ),
                            const SizedBox(height: 20),

                            FormBuilderDropdown<int>(
                              name: 'locationId',
                              decoration: const InputDecoration(labelText: "Lokacija*"),
                              validator: FormBuilderValidators.required(
                                  errorText: 'Obavezno polje'),
                              items: locationResult?.result
                                      .map((loc) => DropdownMenuItem(
                                            value: loc.locationId,
                                            child: Text(loc.locationName ?? ''),
                                          ))
                                      .toList() ??
                                  [],
                            ),
                            const SizedBox(height: 20),

                            _buildImageField(),

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

  Widget _buildImageField() {
    final store = storeResult?.result.first;
    return FormBuilderField(
      name: "image",
      builder: (field) {
        return InputDecorator(
          decoration: const InputDecoration(
            labelText: "Proslijedite sliku trgovine",
            border: OutlineInputBorder(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.image),
                title: _image != null
                    ? Text(_image!.path.split('/').last)
                    : store?.image != null
                        ? const Text('Proslijeđena slika')
                        : const Text("Nema proslijeđene slike"),
                trailing: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(27, 76, 125, 1)),
                  icon: const Icon(Icons.file_upload, color: Colors.white),
                  label: store?.image != null
                      ? const Text("Promijeni sliku",
                          style: TextStyle(color: Colors.white))
                      : _image == null
                          ? const Text("Odaberi",
                              style: TextStyle(color: Colors.white))
                          : const Text("Promijeni sliku",
                              style: TextStyle(color: Colors.white)),
                  onPressed: () => getImage(field),
                ),
              ),
              const SizedBox(height: 10),
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    )
                  : store?.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageFromString(store!.image ?? '',
                              fit: BoxFit.cover),
                        )
                      : const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  void getImage(FormFieldState field) async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _image = File(result.files.single.path!);
        _base64Image = base64Encode(_image!.readAsBytesSync());
      });
      field.didChange(_image);
    }
  }

  Future<void> _save() async {
    final store = storeResult?.result.first;
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
      request['isApplicant'] = false;
      request['isDeleted'] = false;
      request['roles'] = [10, 1011];
      request['userId'] = store?.user?.userId;

      if (_image != null) {
        request['image'] = _base64Image;
      } else {
        request['image'] = store?.image;
      }

      try {
        await storesProvider.update(store!.storeId, request);
        if (!mounted) return;
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
