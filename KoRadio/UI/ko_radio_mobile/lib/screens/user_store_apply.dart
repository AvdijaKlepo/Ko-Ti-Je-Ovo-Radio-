import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/store_provider.dart';
import 'package:provider/provider.dart';

class UserStoreApply extends StatefulWidget {
  const UserStoreApply({this.user,super.key});
  final User? user;

  @override
  State<UserStoreApply> createState() => _UserStoreApplyState();
}

class _UserStoreApplyState extends State<UserStoreApply> {
  final _formKey = GlobalKey<FormBuilderState>();
  File? _image;
  Uint8List? _decodedImage;
  String? _base64Image;
  File? _pdfFile;
String? _base64Pdf;

Future<void> _pickPdf() async {
  var result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  if (result != null && result.files.single.path != null) {
    setState(() {
      _pdfFile = File(result.files.single.path!);
      _base64Pdf = base64Encode(_pdfFile!.readAsBytesSync());
    });
  }
}

  late StoreProvider storeProvider;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  @override
  void initState() {
    super.initState();
    storeProvider = context.read<StoreProvider>();
    locationProvider = context.read<LocationProvider>();
  
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
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
  _getLocations() async {
    var filter = {'isDeleted:':false};
    var fetchedLocations = await locationProvider.get(filter: filter);
    setState(() {
      locationResult = fetchedLocations;
      });
  }   
  var _userId = AuthProvider.user?.userId ?? 0;
  @override
  Widget build(BuildContext context) {
 
   return Scaffold(
  appBar: AppBar(
    automaticallyImplyLeading: true,
    
    scrolledUnderElevation: 0,
    centerTitle: true,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(
        
        ),
      ),
    ),
    title: const Text(
      "Prijava trgovine",
      style: TextStyle(fontSize: 16, color: Colors.white),
    ),
  ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
                
         const Text("Informacije o trgovini",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),

                        FormBuilderTextField(
                          name: "storeName",
                          decoration: InputDecoration(
                            labelText: "Ime trgovine",
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.image),
            title: _image != null
                ? Text(_image!.path.split('/').last)
                : const Text("Nema odabrane slike"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image == null
                  ? const Text("Odaberi", style: TextStyle(color: Colors.white))
                  : const Text("Promijeni", style: TextStyle(color: Colors.white)),
              onPressed: () => _pickImage(),
            ),
          ),
          const SizedBox(height: 10),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_image!, fit: BoxFit.cover),
            )
          else if (_decodedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(_decodedImage!, fit: BoxFit.cover),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  },
),
const SizedBox(height: 20),

FormBuilderField(
  name: "businessCertificate",
  validator: (val) {
    if (_pdfFile == null) {
      return "Obavezno je učitati obrtni list.";
    }
    return null;
  },
  builder: (field) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Obrtni list (PDF)",
        border: OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: _pdfFile != null
                ? Text(_pdfFile!.path.split('/').last)
                : const Text("Nema učitanog PDF dokumenta"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _pdfFile == null
                  ? const Text("Odaberi", style: TextStyle(color: Colors.white))
                  : const Text("Promijeni", style: TextStyle(color: Colors.white)),
              onPressed: () => _pickPdf(),
            ),
          ),
        ],
      ),
    );
  },
),
const SizedBox(height: 20),

SizedBox(height: 20,),
Align(
  alignment: Alignment.bottomRight,
  child: ElevatedButton(onPressed: _onSave,style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  child: const Text("Sačuvaj", style: TextStyle(color: Colors.white))),
),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;

  if (!isValid) {
  
    return;
  }
    var formData = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});
    formData['userId'] = _userId;
    formData['isApplicant'] = true;
    formData['isDeleted'] = false;
      if (formData["startTime"] is DateTime) {
      formData["startTime"] = (formData["startTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    if (formData["endTime"] is DateTime) {
      formData["endTime"] = (formData["endTime"] as DateTime).toIso8601String().substring(11, 19);
    }

    const Map<String, String> dayOfWeekMapping = {
      'Ponedjeljak': 'Monday',
      'Utorak': 'Tuesday',
      'Srijeda': 'Wednesday',
      'Četvrtak': 'Thursday',
      'Petak': 'Friday',
      'Subota': 'Saturday',
      'Nedjelja': 'Sunday',
    };

    
    formData['workingDays'] = (formData['workingDays'] as List<dynamic>)
        .map((localizedDay) {
          return dayOfWeekMapping[localizedDay.toString()];
        })
        .whereType<String>()
        .toList();

    if (_base64Pdf != null) {
    formData['businessCertificate'] = _base64Pdf; 
  }
   if (_base64Image != null) {
    formData['image'] = _base64Image;
  }
 

    try {
      storeProvider.insert(formData);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Trgovina uspješno dodana!")));
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
}