import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
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
  const CompanyUpdateScreen({super.key, required this.companyId});
  final int companyId;

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
              child: companyResult == null
                ? const Center(child: CircularProgressIndicator()) 
                : SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  initialValue: _initialValue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Podaci Firme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    FormBuilderTextField(
  name: "companyName",
  decoration: const InputDecoration(labelText: "Ime Firme:"),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Ime firme je obavezno."),
    FormBuilderValidators.minLength(2, errorText: "Minimalno 2 znaka."),
    FormBuilderValidators.maxLength(50, errorText: "Maksimalno 50 znakova."),
    FormBuilderValidators.match(r'^[A-Z][A-Za-zĆČĐŠŽćčđšž. ]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim'),
  ]),
),
const SizedBox(height: 20),

FormBuilderTextField(
  name: "bio",
  maxLines: 5,
  decoration: const InputDecoration(labelText: "Opis",border: OutlineInputBorder()),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Opis je obavezan."),
    FormBuilderValidators.minLength(10, errorText: "Minimalno 10 znakova."),
    FormBuilderValidators.maxLength(300, errorText: "Maksimalno 300 znakova."),
    FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž0-9\s.,\-\/!]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim i brojevi'),
  ]),
),
const SizedBox(height: 20),

FormBuilderTextField(
  name: "email",
  decoration: const InputDecoration(labelText: "Email",border: OutlineInputBorder()),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Email je obavezan."),
    FormBuilderValidators.email(errorText: "Unesite ispravan email."),
  ]),
),
const SizedBox(height: 20),

FormBuilderTextField(
  name: "experianceYears",
  decoration: const InputDecoration(labelText: "Godine iskustva",border: OutlineInputBorder()),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Godine iskustva su obavezne."),
    FormBuilderValidators.integer(errorText: "Mora biti broj."),
    FormBuilderValidators.min(0, errorText: "Ne može biti negativno."),
    FormBuilderValidators.max(100, errorText: "Unesite realan broj godina. Max 100"),
  ]),
),
const SizedBox(height: 20),

FormBuilderTextField(
  name: "phoneNumber",
  decoration: const InputDecoration(labelText: "Telefonski broj",border: OutlineInputBorder()),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Telefon je obavezan."),
    FormBuilderValidators.match(
      r'^\+?\d{11}$',
      errorText: "Potrebno je 11 cifara sa početkom od +387",
    ),
  ]),
),
const SizedBox(height: 20),

FormBuilderDateTimePicker(
  name: 'startTime',
  decoration: const InputDecoration(labelText: "Početak radnog vremena",border: OutlineInputBorder()),
  inputType: InputType.time,
  validator: FormBuilderValidators.required(errorText: "Početak je obavezan."),
),
const SizedBox(height: 20),

FormBuilderDateTimePicker(
  name: 'endTime',
  decoration: const InputDecoration(labelText: "Kraj radnog vremena",border: OutlineInputBorder()),
  inputType: InputType.time,
  validator: (value) {
    final form = FormBuilder.of(context);
    final start = form?.fields['startTime']?.value;
    if (value == null) return "Kraj je obavezan.";
    if (start != null) {
      if (value.isBefore(start)) {
        return "Kraj mora biti nakon početka.";
      }
      if (value.difference(start).inHours < 3) {
        return "Smjena mora trajati barem 3 sata.";
      }
    }
    return null;
  },
),
const SizedBox(height: 20),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 0),
  child: serviceResult?.result.isNotEmpty == true
      ? FormBuilderFilterChip<int>(
          name: "serviceId",
          decoration: const InputDecoration(border: OutlineInputBorder()),
          options: serviceResult!.result
              .map((s) => FormBuilderChipOption(
                  value: s.serviceId, child: Text(s.serviceName ?? "")))
              .toList(),
          spacing: 6,
          runSpacing: 4,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: "Odaberite bar jednu uslugu."),
          ]),
        )
      : const Text("Nema dostupnih usluga"),
),
const SizedBox(height: 20),

FormBuilderCheckboxGroup<String>(
  name: 'workingDays',
  decoration: const InputDecoration(labelText: "Radni dani",border: OutlineInputBorder()),
  options: [
    'Ponedjeljak','Utorak','Srijeda','Četvrtak','Petak','Subota','Nedjelja',
  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.minLength(1, errorText: "Odaberite bar jedan dan."),
  ]),
),
const SizedBox(height: 20),

FormBuilderDropdown<int>(
  name: 'locationId',
  decoration: const InputDecoration(labelText: "Lokacija*",border: OutlineInputBorder()),
  validator: FormBuilderValidators.required(errorText: 'Lokacija je obavezna.'),
  items: locationResult?.result
          .map((loc) => DropdownMenuItem(
                value: loc.locationId,
                child: Text(loc.locationName ?? ''),
              ))
          .toList() ??
      [],
),

                    const SizedBox(height: 20,),
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
    final company = companyResult!.result.first;

    request['isApplicant'] = false;
    request['isDeleted'] = false;
    request['employee'] = company.companyEmployees.map((e) => e.userId).toList();
    request['rating'] = company.rating;
    request['companyId'] = company.companyId;

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
    request['serviceId'] = (request['serviceId'] as List)
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .toList();

    if (request["startTime"] is DateTime) {
      request["startTime"] = (request["startTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    if (request["endTime"] is DateTime) {
      request["endTime"] = (request["endTime"] as DateTime).toIso8601String().substring(11, 19);
    }

    try {
      await companyProvider.update(company.companyId, request);
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