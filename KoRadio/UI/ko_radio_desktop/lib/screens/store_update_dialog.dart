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

class StoreUpdateDialog extends StatefulWidget {
  const StoreUpdateDialog({required this.store, super.key});
  final Store store;

  @override
  State<StoreUpdateDialog> createState() => _StoreUpdateDialogState();
}

class _StoreUpdateDialogState extends State<StoreUpdateDialog> {
  Uint8List? _decodedImage;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late StoreProvider storesProvider;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  File? _image;
  String? _base64Image;

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    storesProvider = context.read<StoreProvider>();

      _startTime = _parseTime(widget.store.startTime!);
      _endTime   = _parseTime(widget.store.endTime!);
      final now = DateTime.now();
    _initialValue = {
      "storeName": widget.store.storeName,
      "description": widget.store.description,  
      "address": widget.store.address,
      "image": widget.store.image,
      "locationId": widget.store.location?.locationId,
      "workingDays":    localizeWorkingDays( widget.store.workingDays?.map((d) => d.toString()).toList()),
    "startTime":       DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute),
    "endTime":         DateTime(now.year, now.month, now.day, _endTime.hour,   _endTime.minute),
    };
    if (widget.store.image != null) {
    try {
      _decodedImage = base64Decode(widget.store.image!);
    } catch (_) {
      _decodedImage = null;
    }
  }
  WidgetsBinding.instance.addPostFrameCallback((_) async {
   await _getLocations();
   
  });
  
  }
  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
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

  Future<void> _getLocations() async {
    try {
      var fetchedLocations = await locationProvider.get();
      setState(() {
        locationResult = fetchedLocations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška tokom dohvaćanja lokacija. Pokušajte ponovo.")),
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
    child:  Column(
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
                                  validator: (value) {
  final start = _formKey.currentState?.fields['startTime']?.value;

  if (value == null) return "Kraj smjene je obavezan.";
  if (start == null) return null;

  // Convert TimeOfDay -> DateTime for comparison
  final now = DateTime.now();
  final startDt = DateTime(now.year, now.month, now.day, start.hour, start.minute);
  final endDt = DateTime(now.year, now.month, now.day, value.hour, value.minute);

  if (endDt.isBefore(startDt)) {
    return "Kraj mora biti nakon početka.";
  }
  if (endDt.difference(startDt).inHours < 3) {
    return "Smjena mora trajati najmanje 3 sata.";
  }

  return null;
},
                             
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _image != null
                      ? _image!.path.split('/').last
                      : widget.store?.image != null
                          ? "Proslijeđena slika"
                          : "Nema slike",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                  minimumSize: const Size(90, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: _pickImage,
                child: Text(
                  _image == null && widget.store?.image == null
                      ? "Odaberi"
                      : "Promijeni",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          if (_image != null || _decodedImage != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _image != null
                  ? Image.file(_image!, fit: BoxFit.cover, height: 120)
                  : Image.memory(_decodedImage!,
                      fit: BoxFit.cover, height: 120),
            ),
          ]
        ],
      ),
    );
  },
),
                   
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
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
      request['isApplicant'] = false;
      request['isDeleted'] = false;
      request['roles']=[10,1011];
      request['userId']=widget.store.user?.userId;
      const Map<String, String> dayOfWeekMapping = {
      'Ponedjeljak': 'Monday',
      'Utorak': 'Tuesday',
      'Srijeda': 'Wednesday',
      'Četvrtak': 'Thursday',
      'Petak': 'Friday',
      'Subota': 'Saturday',
      'Nedjelja': 'Sunday',
    };

    // Convert the localized working day strings to English using the map.
    request['workingDays'] = (request['workingDays'] as List<dynamic>)
        .map((localizedDay) {
          return dayOfWeekMapping[localizedDay.toString()];
        })
        .whereType<String>() // Filter out any nulls if a key wasn't found.
        .toList();
   if (request["startTime"] is DateTime) {
      request["startTime"] = (request["startTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    if (request["endTime"] is DateTime) {
      request["endTime"] = (request["endTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    request['rating'] = widget.store.rating;
      if(_image!=null)
      {
        request['image'] = _base64Image;
      }
      else{
        request['image'] = widget.store.image;
      }
    

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