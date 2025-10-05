import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:provider/provider.dart';

class UserCompanyApply extends StatefulWidget {

  final User? user;
  const UserCompanyApply({super.key, this.user});

  @override
  State<UserCompanyApply> createState() => _UserCompanyApplyState();
}

class _UserCompanyApplyState extends State<UserCompanyApply> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late CompanyProvider companyProvider;
  late ServiceProvider serviceProvider;
  late LocationProvider locationProvider;

  SearchResult<Location>? locationResult;


  SearchResult<Service>? serviceResult;
  String? _backendEmailError;
  File? _image;
  String? _base64Image;
  Uint8List? _decodedImage; File? _pdfFile;
String? _base64Pdf;



  @override
  void initState() {
    super.initState();
    companyProvider = context.read<CompanyProvider>();
    serviceProvider = context.read<ServiceProvider>();
    locationProvider = context.read<LocationProvider>();

    print(widget.user?.userId);

    _initialValue = {
      
    };
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    await _fetchData();
    });
  
  }
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
  Future<void> _fetchData() async {
    final services = await serviceProvider.get();
    final locations = await locationProvider.get();
    setState(() {
      serviceResult = services;
      locationResult = locations;
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

  void _onSave() async {
   final isValid = _formKey.currentState?.saveAndValidate() ?? false;

  if (!isValid) {
  
    return;
  }
    var formData = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});

    if (formData["startTime"] is DateTime) {
      formData["startTime"] = (formData["startTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    if (formData["endTime"] is DateTime) {
      formData["endTime"] = (formData["endTime"] as DateTime).toIso8601String().substring(11, 19);
    }
     if (_base64Pdf != null) {
    formData['businessCertificate'] = _base64Pdf;
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

    // Convert the localized working day strings to English using the map.
    formData['workingDays'] = (formData['workingDays'] as List<dynamic>)
        .map((localizedDay) {
          return dayOfWeekMapping[localizedDay.toString()];
        })
        .whereType<String>() // Filter out any nulls if a key wasn't found.
        .toList();
    if(_image!=null)
    {
      formData['image'] = _base64Image;
    }
    {
      formData['image']=null;
    }

    formData["isDeleted"] = false;
    formData["isApplicant"] = true;
    formData["rating"] = 0; 
    formData["employee"]=[widget.user?.userId];
    formData["isOwner"]=true;

    var selectedServices = formData["serviceId"];
    formData["serviceId"] = (selectedServices is List)
        ? selectedServices.map((id) => int.tryParse(id.toString()) ?? 0).toList()
        : (selectedServices != null
            ? [int.tryParse(selectedServices.toString()) ?? 0]
            : []);

    try {
     await companyProvider.insert(formData);
     if(mounted && context.mounted)
     {
      Navigator.of(context).pop(true);
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Prijava poslana!")));
     }
   } on UserException catch (e) {
_formKey.currentState?.invalidateField(
        name: "email",
        errorText: e.exMessage,
      );
}
  

     catch (e) {
      debugPrint(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title:  Text("Prijava firme",style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,letterSpacing: 1.2,color: const Color.fromRGBO(27, 76, 125, 25)),),centerTitle: true,scrolledUnderElevation: 0,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
           
           const Text(
                              'Informacije o firmi',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                      
                            FormBuilderTextField(
                              name: "companyName",
                              decoration: InputDecoration(
                                labelText: "Ime firme",
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(errorText: "Ime firme je obavezno."),
                                FormBuilderValidators.minLength(2, errorText: "Minimalno 2 znaka."),
                                FormBuilderValidators.maxLength(50, errorText: "Maksimalno 50 znakova."),
                                FormBuilderValidators.match(
                                  r'^[A-Z][A-Za-zĆČĐŠŽćčđšž. ]+$',
                                  errorText: 'Dozvoljena su samo slova sa prvim velikim',
                                ),
                              ]),
                            ),
                            const SizedBox(height: 12),
                      
                            FormBuilderTextField(
                              name: "bio",
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText: "Opis",
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[100],
                                helperText: "Maksimalno 250 znakova",
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(errorText: "Opis je obavezan."),
                                FormBuilderValidators.minLength(10, errorText: "Minimalno 10 znakova."),
                                FormBuilderValidators.maxLength(250, errorText: "Maksimalno 250 znakova."),
                              ]),
                            ),
                      
                            const SizedBox(height: 20),
                      
                                     
                            const Text(
                              'Kontakt informacije',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                      
                            FormBuilderTextField(
                              name: "email",
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(errorText: "Email je obavezan."),
                                FormBuilderValidators.email(errorText: "Unesite ispravan email."),
                              ]),
                            ),
                            const SizedBox(height: 12),
                      
                            FormBuilderTextField(
                              name: "experianceYears",
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Godine iskustva",
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(errorText: "Godine iskustva su obavezne."),
                                FormBuilderValidators.integer(errorText: "Mora biti broj."),
                                FormBuilderValidators.min(0, errorText: "Ne može biti negativno."),
                                FormBuilderValidators.max(100, errorText: "Maksimalno 100"),
                              ]),
                            ),
                            const SizedBox(height: 12),
                      
                            FormBuilderTextField(
                              name: "phoneNumber",
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Telefonski broj",
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(errorText: "Telefon je obavezan."),
                                FormBuilderValidators.match(
                                  r'^\+?\d{11}$',
                                  errorText: "Potrebno je 11 cifara sa početkom od +387",
                                ),
                              ]),
                            ),
                      
                            const SizedBox(height: 20),
                      
                                    
                            const Text(
                              'Radno vrijeme',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                      
                            Row(
                              children: [
                                Expanded(
                                  child: FormBuilderDateTimePicker(
                                    locale: const Locale('bs'),
                                    name: 'startTime',
                                    decoration: InputDecoration(
                                      labelText: 'Početak',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    inputType: InputType.time,
                                    validator: FormBuilderValidators.required(errorText: "Početak je obavezan."),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FormBuilderDateTimePicker(
                                    locale: const Locale('bs'),
                                    name: 'endTime',
                                    decoration: InputDecoration(
                                      labelText: 'Kraj',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    inputType: InputType.time,
                                   validator: (value) {
  final start = _formKey.currentState?.fields['startTime']?.value;

  if (value == null) return "Kraj smjene je obavezan.";
  if (start == null) return null;


  final now = DateTime.now();
  final startDt = DateTime(now.year, now.month, now.day, start.hour, start.minute);
  final endDt = DateTime(now.year, now.month, now.day, value.hour, value.minute);

  if (endDt.isBefore(startDt)) {
    return "Kraj mora biti nakon početka.";
  }
  if (endDt.difference(startDt).inHours < 3) {
    return "Smjena je 3 sata";
  }

  return null;
},
                                  ),
                                ),
                              ],
                            ),
                      
                            const SizedBox(height: 20),
                      
                                     
                            const Text(
                              'Usluge',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            serviceResult?.result.isNotEmpty == true
                                ? FormBuilderFilterChip<int>(
                                    name: "serviceId",
                                    options: serviceResult!.result
                                        .map((s) => FormBuilderChipOption(
                                              value: s.serviceId,
                                              child: Text(s.serviceName ?? ""),
                                            ))
                                        .toList(),
                                    spacing: 6,
                                    runSpacing: 4,
                                    validator: FormBuilderValidators.required(
                                        errorText: "Odaberite bar jednu uslugu."),
                                  )
                                : const Text("Nema dostupnih usluga"),
                      
                            const SizedBox(height: 16),
                      
                                         
                            const Text(
                              'Radni dani',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            FormBuilderCheckboxGroup<String>(
                              name: 'workingDays',
                              options: [
                                'Ponedjeljak',
                                'Utorak',
                                'Srijeda',
                                'Četvrtak',
                                'Petak',
                                'Subota',
                                'Nedjelja',
                              ].map((e) => FormBuilderFieldOption(value: e)).toList(),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.minLength(1, errorText: "Odaberite bar jedan dan."),
                              ]),
                            ),
                      
                            const SizedBox(height: 16),
                      
                         
                            FormBuilderDropdown<int>(
                              name: 'locationId',
                              decoration: InputDecoration(
                                labelText: "Lokacija*",
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              validator: FormBuilderValidators.required(errorText: 'Lokacija je obavezna.'),
                              items: locationResult?.result
                                      .map((loc) => DropdownMenuItem(
                                            value: loc.locationId,
                                            child: Text(loc.locationName ?? ''),
                                          ))
                                      .toList() ??
                                  [],
                            ),
                      
                            const SizedBox(height: 16),
                      
                                        
                              const SizedBox(
                                height: 20,
                              ),
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
              
                    : const Text("Odaberi logo"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image == null 
                  ? const Text("Odaberi", style: TextStyle(color: Colors.white))
                  : const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () => _pickImage(),
            ),
          ),
          const SizedBox(height: 10),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            )
          else if (_decodedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
const SizedBox(height: 12),
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
           
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Odustani")),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _onSave, style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),child: const Text("Sačuvaj", style: TextStyle(color: Colors.white))),
                ],
              ),
            ],
          ),
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
}