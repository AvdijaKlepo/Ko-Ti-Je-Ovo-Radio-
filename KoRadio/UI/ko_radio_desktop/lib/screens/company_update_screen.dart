import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/layout/master_screen.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class CompanyUpdateScreen extends StatefulWidget {
  const CompanyUpdateScreen({super.key, required this.companyId ,required this.parentContext});
  final int companyId;
  final BuildContext parentContext;

  @override
  State<CompanyUpdateScreen> createState() => _CompanyUpdateScreenState();
}

class _CompanyUpdateScreenState extends State<CompanyUpdateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CompanyProvider companyProvider;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  late ServiceProvider serviceProvider;
  SearchResult<Service>? serviceResult;
  SearchResult<Company>? companyResult;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late List<bool> _selectedDays;
  Uint8List? _decodedImage;
  File? _image;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    serviceProvider = context.read<ServiceProvider>();
    companyProvider = context.read<CompanyProvider>();
    
   WidgetsBinding.instance.addPostFrameCallback((_) async {
  await _getCompany();
  if (companyResult == null || companyResult!.result.isEmpty) return;

  final company = companyResult!.result.first;

  _startTime = _parseTime(company.startTime);
  _endTime   = _parseTime(company.endTime);

  final now = DateTime.now();
  _initialValue = {
    "companyName":     company.companyName,
    "email":           company.email,
    "bio":             company.bio,
    "phoneNumber":     company.phoneNumber,
    "experianceYears": company.experianceYears.toString(),
    "workingDays":      localizeWorkingDays(company.workingDays?.map((d) => d.toString()).toList()),
    "startTime":       DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute),
    "endTime":         DateTime(now.year, now.month, now.day, _endTime.hour, _endTime.minute),
    "serviceId": company.companyServices
        .map((e) => e.serviceId)
        .whereType<int>() 
        .toList(),
    "locationId": company.location?.locationId,
    "image": company.image,
  };

  await _getLocations();
  await _getServices();
   if (company.image != null) {
    try {
      _decodedImage = base64Decode(company.image!);
    } catch (_) {
      _decodedImage = null;
    }
  }
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
  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }
  Future<void> _getCompany() async {
    var filter = {'CompanyId':AuthProvider.selectedCompanyId};
    try {
      var fetchedCompanies = await companyProvider.get(filter: filter);
      setState(() {
        companyResult = fetchedCompanies;
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
        
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
   Future<void> _getServices() async {
    try {
      var fetchedServices= await serviceProvider.get();
      setState(() {
        serviceResult = fetchedServices;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  @override
  void didChangeDependencies() {
  
    super.didChangeDependencies();
  }
 @override
Widget build(BuildContext context) {
  return Dialog(
    
    surfaceTintColor: Colors.white,
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 1,
      child: companyResult == null
          ? const Center(child: CircularProgressIndicator())
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
              
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            'Podaci firme',
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

                    const SizedBox(height: 16),

              
                    Padding(
                 padding: const EdgeInsets.all(16),
                      child: FormBuilder(
                        key: _formKey,
                        initialValue: _initialValue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                      final form = FormBuilder.of(context);
                                      final start = form?.fields['startTime']?.value;
                                      if (value == null) return "Kraj je obavezan.";
                                      if (start != null) {
                                        if (value.isBefore(start)) return "Kraj mora biti nakon početka.";
                                        if (value.difference(start).inHours < 3) return "Smjena mora trajati barem 3 sata.";
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
                : companyResult?.result.first.image != null
                    ? const Text('Proslijeđena slika')
                    : const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image == null && companyResult?.result.first.image == null
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
                      
                            const SizedBox(height: 24),
                      
                                         
                            SizedBox(
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
                          ],
                        ),
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
    final message = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
  if (_formKey.currentState?.saveAndValidate() ?? false) {
    final request = Map<String, dynamic>.from(_formKey.currentState!.value);
    final company = companyResult!.result.first;

    request['isApplicant'] = false;
    request['isDeleted'] = false;
    request['employee'] = company.companyEmployees.map((e) => e.userId).toList();
    request['rating'] = company.rating;
    request['companyId'] = company.companyId;
    if(_image!=null)
    {
      request['image'] = _base64Image;
    }
    else{
      request['image'] = company.image;
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

  
    request['workingDays'] = (request['workingDays'] as List<dynamic>)
        .map((localizedDay) {
          return dayOfWeekMapping[localizedDay.toString()];
        })
        .whereType<String>() 
        .toList();
    request['serviceId'] = (request['serviceId'] as List)
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .toList();
    var startTime = request["startTime"] as DateTime;
    var endTime = request["endTime"] as DateTime;
    if(endTime.isBefore(startTime))
    {
      _formKey.currentState?.invalidateField(name: 'endTime',errorText: 'Kraj mora biti nakon početka.');
      return;
    }
    var timeDifference = endTime.difference(startTime).inHours;
    if(timeDifference<3)
    {
      _formKey.currentState?.invalidateField(name: 'endTime',errorText: 'Smijena mora trajati barem 3 sati.');
      return;
    }

    if (request["startTime"] is DateTime) {
      request["startTime"] = (request["startTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    if (request["endTime"] is DateTime) {
      request["endTime"] = (request["endTime"] as DateTime).toIso8601String().substring(11, 19);
    }
 

    try {
      await companyProvider.update(company.companyId, request); 
 
      message.showSnackBar(
        const SnackBar(content: Text("Podaci uspješno uređeni!")),
      );
           navigator.pop(true);
     
    } catch (e) {
      message.showSnackBar(
        const SnackBar(content: Text("Greška tokom ažuriranja podataka. Molimo pokušajte ponovo.")),
      );
    }
  }
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