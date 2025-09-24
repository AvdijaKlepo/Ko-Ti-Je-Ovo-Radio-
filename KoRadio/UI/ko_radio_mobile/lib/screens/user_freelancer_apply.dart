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
              
            const SizedBox(height: 20),
                         
                    const Text(
                            "Biografija",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          FormBuilderTextField(
                            name: "bio",
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: "Biografija",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: "Biografija je obavezna."),
                              FormBuilderValidators.minLength(10, errorText: "Minimalno 10 znakova."),
                              FormBuilderValidators.maxLength(500, errorText: "Maksimalno 500 znakova."),
                            ]),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Iskustvo",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
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
                              FormBuilderValidators.max(70, errorText: "Budimo realni."),
                            ]),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Radni dani",
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

                          const SizedBox(height: 20),

                          const Text(
                            "Radno vrijeme",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: FormBuilderDateTimePicker(
                                  name: 'startTime',
                                  inputType: InputType.time,
                                  decoration: InputDecoration(
                                    labelText: "Početak smjene",
                                    border: const OutlineInputBorder(),
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
                                  decoration: InputDecoration(
                                    labelText: "Kraj smjene",
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  validator: (value) {
                                    final start = FormBuilder.of(context)?.fields['startTime']?.value;
                                    if (value == null) return "Kraj smjene je obavezan.";
                                    if (start != null) {
                                      if (value.isBefore(start)) return "Kraj mora biti nakon početka.";
                                      if (value.difference(start).inHours < 3) {
                                        return "Smjena mora trajati najmanje 3 sata.";
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Usluge",
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
