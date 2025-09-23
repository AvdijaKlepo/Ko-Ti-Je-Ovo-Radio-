import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  Uint8List? _decodedImage;

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
        "workingDays":  localizeWorkingDays(store.workingDays?.map((d) => d.toString()).toList())  ,
        "startTime": parseTime(store.startTime!),
        "endTime": parseTime(store.endTime!),
      };
      if (store.image != null) {
    try {
      _decodedImage = base64Decode(store.image!);
    } catch (_) {
      _decodedImage = null;
    }
  }

      await _getLocations();
    });
  }
  Future<void> _pickImage() async {
  var result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.single.path != null) {
    setState(() {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
      _decodedImage = null; 
    });
  }
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
  surfaceTintColor: Colors.white,
  insetPadding: const EdgeInsets.all(24),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: SizedBox(
    width: MediaQuery.of(context).size.width * 0.35,
    child: storeResult == null
        ? const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ))
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                      'Podaci trgovine',
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

              // 🔹 Form (scrollable area)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: FormBuilder(
                    key: _formKey,
                    initialValue: _initialValue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("Informacije o trgovini",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),

                        FormBuilderTextField(
                          name: "storeName",
                          decoration: InputDecoration(
                            labelText: "Ime firme",
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'Obavezno polje'),
                            FormBuilderValidators.maxLength(20,
                                errorText: 'Maksimalno 20 znakova'),
                            FormBuilderValidators.minLength(2,
                                errorText: 'Minimalno 2 znaka'),
                            FormBuilderValidators.match(
                                r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž .]+$',
                                errorText:
                                    'Dozvoljena su samo slova sa prvim velikim.'),
                          ]),
                        ),
                        const SizedBox(height: 16),

                        FormBuilderTextField(
                          name: "description",
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: "Opis",
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'Obavezno polje'),
                            FormBuilderValidators.maxLength(230,
                                errorText: 'Maksimalno 230 znakova'),
                            FormBuilderValidators.minLength(10,
                                errorText: 'Minimalno 10 znakova'),
                            FormBuilderValidators.match(
                                r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž0-9\s.,\-\/!]+$',
                                errorText:
                                    'Dozvoljena su samo slova sa prvim velikim, brojevi i osnovni znakovi.'),
                          ]),
                        ),
                        const SizedBox(height: 16),

                        FormBuilderTextField(
                          name: "address",
                          decoration: InputDecoration(
                            labelText: "Adresa",
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'Obavezno polje'),
                            FormBuilderValidators.match(
                                r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž0-9\s.,\-\/!]+$',
                                errorText:
                                    'Dozvoljena su samo slova sa prvim velikim, brojevi i osnovni znakovi.'),
                          ]),
                        ),

                        const SizedBox(height: 24),
                        const Text("Radno vrijeme",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),

                        FormBuilderCheckboxGroup<String>(
                          name: 'workingDays',
                          decoration: const InputDecoration(
                            labelText: "Radni Dani",
                            border: InputBorder.none,
                            
                          ),
                          options: const [
                            'Nedjelja',
                            'Ponedjeljak',
                            'Utorak',
                            'Srijeda',
                            'Četvrtak',
                            'Petak',
                            'Subota',
                          ].map((e) => FormBuilderFieldOption(value: e)).toList(),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: "Odaberite bar jedan radni dan."),
                          ]),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: FormBuilderDateTimePicker(
                                name: 'startTime',
                                inputType: InputType.time,
                                decoration:  InputDecoration(
                                  labelText: "Početak smjene",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                validator: FormBuilderValidators.required(
                                    errorText: "Početak smjene je obavezan."),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FormBuilderDateTimePicker(
                                name: 'endTime',
                                inputType: InputType.time,
                                decoration:  InputDecoration(
                                  labelText: "Kraj smjene",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                      errorText: "Kraj smjene je obavezan."),
                                  (value) {
                                    final start = FormBuilder.of(context)
                                        ?.fields['startTime']
                                        ?.value;
                                    if (start != null && value != null) {
                                      if (value.isBefore(start)) {
                                        return "Kraj smjene mora biti nakon početka.";
                                      }
                                      if (value.difference(start).inHours < 3) {
                                        return "Smjena mora trajati najmanje 3 sata.";
                                      }
                                    }
                                    return null;
                                  }
                                ]),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Text("Lokacija",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),

                        FormBuilderDropdown<int>(
                          name: 'locationId',
                          decoration:  InputDecoration(
                            labelText: "Lokacija*",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
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

                        const SizedBox(height: 24),
                       FormBuilderField(
                              name: "image",
                              builder: (field) {
                                return InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: "Logo",
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.image),
                                        title: _image != null
                                            ? Text(_image!.path.split('/').last)
                                            : storeResult?.result.first.image !=
                                                    null
                                                ? const Text(
                                                    'Proslijeđena slika')
                                                : const Text(
                                                    "Nema proslijeđene slike"),
                                        trailing: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    27, 76, 125, 1),
                                          ),
                                          icon: const Icon(Icons.file_upload,
                                              color: Colors.white),
                                          label: _image == null &&
                                                  storeResult?.result.first
                                                          .image ==
                                                      null
                                              ? const Text("Odaberi",
                                                  style: TextStyle(
                                                      color: Colors.white))
                                              : const Text("Promijeni sliku",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                          onPressed: () => _pickImage(),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (_image != null)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            _image!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else if (_decodedImage != null)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.memory(
                                            _decodedImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else
                                        const SizedBox.shrink(),
                                    ],
                                  ),
                                );
                              },
                            ),
                        const SizedBox(height: 100), 
                      ],
                    ),
                  ),
                ),
              ),

          
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                 
                                  icon: const Icon(Icons.save, color: Colors.white),
                                  label: const Text("Sačuvaj", style: TextStyle(color: Colors.white)),
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
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
    request['userId'] = store?.user?.userId;

   
    const Map<String, String> dayOfWeekMapping = {
      'Ponedjeljak': 'Monday',
      'Utorak': 'Tuesday',
      'Srijeda': 'Wednesday',
      'Četvrtak': 'Thursday',
      'Petak': 'Friday',
      'Subota': 'Saturday',
      'Nedjelja': 'Sunday',
    };

    request['workingDays'] = (request['workingDays'] as List<dynamic>)
        .map((localizedDay) {
          return dayOfWeekMapping[localizedDay.toString()];
        })
        .whereType<String>() 
        .toList();

    request['startTime'] = (request['startTime'] as DateTime).toIso8601String().substring(11, 19);
    request['endTime'] = (request['endTime'] as DateTime).toIso8601String().substring(11, 19);

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
