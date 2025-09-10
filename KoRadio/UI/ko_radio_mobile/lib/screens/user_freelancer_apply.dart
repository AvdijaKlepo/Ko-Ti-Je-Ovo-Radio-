import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';

class UserFreelancerApply extends StatefulWidget {
  final User? user;
  const UserFreelancerApply({super.key, this.user});

  @override
  State<UserFreelancerApply> createState() => _UserFreelancerApplyState();
}

class _UserFreelancerApplyState extends State<UserFreelancerApply> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late UserProvider userProvider;
  late ServiceProvider serviceProvider;
  late FreelancerProvider freelancerProvider;
  late LocationProvider locationProvider;

  SearchResult<Service>? serviceResult;
  SearchResult<Location>? locationResult;
    File? _pdfFile;
String? _base64Pdf;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    serviceProvider = context.read<ServiceProvider>();
    freelancerProvider = context.read<FreelancerProvider>();
    locationProvider = context.read<LocationProvider>();

    _initialValue = {
      'freelancerId': widget.user?.userId.toString(),
      'firstName': widget.user?.firstName,
      'lastName': widget.user?.lastName,
      'email': widget.user?.email,
      'locationId': widget.user?.location?.locationId,
    };

    _fetchData();
  }

  Future<void> _fetchData() async {
    final locations = await locationProvider.get();
    final services = await serviceProvider.get();
    setState(() {
      locationResult = locations;
      serviceResult = services;
    });
  }
  Future<void> _pickPdf() async {
  var result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf'],
  withData: true,
);
final message = ScaffoldMessenger.of(context);
if (result != null && result.files.single.path != null) {
  final filePath = result.files.single.path!;
  if (!filePath.toLowerCase().endsWith('.pdf')) {
    message.showSnackBar(
      const SnackBar(content: Text("Dozvoljen je samo PDF dokument")),
    );
    return;
  }

  setState(() {
    _pdfFile = File(filePath);
    _base64Pdf = base64Encode(_pdfFile!.readAsBytesSync());
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
    formData['cv'] = _base64Pdf; 
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

    formData['freelancerId'] = AuthProvider.user?.userId ?? 0;

 
    formData["isDeleted"] = false;
    formData["isApplicant"] = true;
    formData["rating"] = 0; 

    var selectedServices = formData["serviceId"];
    formData["serviceId"] = (selectedServices is List)
        ? selectedServices.map((id) => int.tryParse(id.toString()) ?? 0).toList()
        : (selectedServices != null
            ? [int.tryParse(selectedServices.toString()) ?? 0]
            : []);
  final message = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
    try {
      await freelancerProvider.insert(formData);
      navigator.pop(true);
      message.showSnackBar(const SnackBar(
          content: Text("Prijava poslana!")));
    } on UserException catch (e) {
      message.showSnackBar(SnackBar(content: Text(e.exMessage)));
      navigator.pop(false);
      
    }
    
    on Exception catch (e) {
      message.showSnackBar(const SnackBar(
          content: Text("Več ste poslali prijavu za radnika!")));
    

    }


  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title:  Text("Prijava za radnika" ,style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,letterSpacing: 1.2,color: const Color.fromRGBO(27, 76, 125, 25)),),centerTitle: true,scrolledUnderElevation: 0,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
             FormBuilderTextField(
  name: "bio",
  
  decoration: const InputDecoration(
    
    labelText: "Biografija",
    border: OutlineInputBorder(),
  ),
  maxLines: 5,
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Biografija je obavezna."),
    FormBuilderValidators.minLength(10,
        errorText: "Biografija mora imati barem 10 karaktera."),
    FormBuilderValidators.maxLength(500,
        errorText: "Biografija može imati najviše 500 karaktera."),
  ]),
),
const SizedBox(height: 12),

FormBuilderTextField(
  name: "experianceYears",
  decoration: const InputDecoration(
    labelText: "Godine Iskustva",
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Unesite godine iskustva."),
    FormBuilderValidators.integer(errorText: "Dozvoljeni su samo brojevi."),
    FormBuilderValidators.min(0, errorText: "Godine ne mogu biti negativne."),
    FormBuilderValidators.max(70, errorText: "Budimo realni."),
  ]),
),
const SizedBox(height: 12),

FormBuilderCheckboxGroup<String>(
  name: 'workingDays',
  decoration: const InputDecoration(
    labelText: "Radni Dani",
    border: InputBorder.none,
  ),
  options: [
    'Nedjelja',
    'Ponedjeljak',
    'Utorak',
    'Srijeda',
    'Četvrtak',
    'Petak',
    'Subota',
  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Odaberite bar jedan radni dan."),
    (value) {
      if (value != null && value.isEmpty) {
        return "Morate odabrati barem jedan dan.";
      }
      return null;
    }
  ]),
),
const SizedBox(height: 12),

FormBuilderDateTimePicker(
  name: 'startTime',
  inputType: InputType.time,
  decoration: const InputDecoration(
    labelText: "Početak Smjene",
    border: OutlineInputBorder(),
  ),
  validator: FormBuilderValidators.required(errorText: "Početak smjene je obavezan."),
),
const SizedBox(height: 12),

FormBuilderDateTimePicker(
  name: 'endTime',
  inputType: InputType.time,
  decoration: const InputDecoration(
    labelText: "Kraj Smjene",
    border: OutlineInputBorder(),

  ),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Kraj smjene je obavezan."),
    (value) {
      final start = FormBuilder.of(context)?.fields['startTime']?.value;

      if (start != null && value != null) {
        if (value.isBefore(start)) {
          return "Kraj smjene mora biti nakon početka.";
        }

        final diff = value.difference(start).inHours;
        if (diff < 3) {
          return "Smjena mora trajati najmanje 3 sata.";
        }
      }
      return null;
    }
  ]),
),

const SizedBox(height: 12),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
  child: serviceResult?.result != null
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Usluge",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            FormBuilderFilterChip<int>(
              name: "serviceId",
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              options: serviceResult!.result
                  .map((s) => FormBuilderChipOption(
                        value: s.serviceId,
                        child: Text(s.serviceName ?? ""),
                      ))
                  .toList(),
              spacing: 8,
              runSpacing: 6,
              validator: FormBuilderValidators.required(
                errorText: "Odaberite barem jednu uslugu.",
              ),
            ),
          ],
        )
      : const Text("Nema dostupnih usluga"),
),

              spacing,
     
FormBuilderField(
  
  name: "cv",
  validator: (val) {
    if (_pdfFile == null) {
      return "Obavezno je učitati PDF dokument";
    }
    return null;
  },
  builder: (field) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "CV (PDF)",
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
                  : const Text("Promijeni PDF", style: TextStyle(color: Colors.white)),
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
                  ElevatedButton(onPressed: _onSave,style: ElevatedButton.styleFrom(
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
}
