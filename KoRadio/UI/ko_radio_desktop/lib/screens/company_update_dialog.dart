import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:provider/provider.dart';

class CompanyUpdateDialog extends StatefulWidget {
  const CompanyUpdateDialog({super.key, required this.company});
  final Company company;

  @override
  State<CompanyUpdateDialog> createState() => _CompanyUpdateDialogState();
}

class _CompanyUpdateDialogState extends State<CompanyUpdateDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CompanyProvider companyProvider;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  late ServiceProvider serviceProvider;
  SearchResult<Service>? serviceResult;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late List<bool> _selectedDays;

  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    serviceProvider = context.read<ServiceProvider>();
    companyProvider = context.read<CompanyProvider>();
    _startTime = _parseTime(widget.company.startTime);
    _endTime   = _parseTime(widget.company.endTime);

    final now = DateTime.now();
    _initialValue = {
    "companyName":     widget.company.companyName,
    "email":           widget.company.email,
    "bio":             widget.company.bio,
    "phoneNumber":     widget.company.phoneNumber,
    "experianceYears": widget.company.experianceYears.toString(),
    "workingDays":     widget.company.workingDays?.map((d) => d.toString()).toList(),
    "startTime":       DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute),
    "endTime":         DateTime(now.year, now.month, now.day, _endTime.hour,   _endTime.minute),
    "serviceId": widget.company.companyServices
    .map((e) => e.serviceId)
    .whereType<int>() 
    .toList(),
    "locationId": widget.company.location?.locationId,

  };
    _getLocations();
    _getServices();

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
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  initialValue: _initialValue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Podaci Firme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                     FormBuilderTextField(name: "companyName", decoration: const InputDecoration(labelText: "Ime Firme:")),
                    const SizedBox(height: 20),

                    FormBuilderTextField(name: "bio", decoration: const InputDecoration(labelText: "Opis")),
                    const SizedBox(height: 20),

                    FormBuilderTextField(name: "email", decoration: const InputDecoration(labelText: "Email")),
                    const SizedBox(height: 20),
                    
                    FormBuilderTextField(
                        name: "experianceYears", decoration: const InputDecoration(labelText: "Godine iskustva")),
                    const SizedBox(height: 20),

                          FormBuilderTextField(
                        name: "phoneNumber", decoration: const InputDecoration(labelText: "Telefonski broj")),
                
                    const SizedBox(height: 20),
                  
                    FormBuilderDateTimePicker(
                      name: 'startTime',
                      decoration: const InputDecoration(labelText: "Početak radnog vremena"),
                      inputType: InputType.time,
                    ),
                    const SizedBox(height: 20),
                
                    FormBuilderDateTimePicker(
                      name: 'endTime',
                      decoration: const InputDecoration(labelText: "Kraj radnog vremena"),
                      inputType: InputType.time,
                    ),
                    const SizedBox(height: 20),

                     Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: serviceResult?.result.length != null
                          ? FormBuilderFilterChip(
                              name: "serviceId",
                              decoration: const InputDecoration(border: InputBorder.none),
                              options: serviceResult!.result
                                  .map((s) => FormBuilderChipOption(
                                      value: s.serviceId, child: Text(s.serviceName ?? "")))
                                  .toList(),
                              spacing: 6,
                              runSpacing: 4,
                            )
                          : const Text("Nema dostupnih usluga"),
                    ),
                    const SizedBox(height: 20),
                    
                       FormBuilderCheckboxGroup<String>(
                      name: 'workingDays',
                      decoration: InputDecoration(labelText: "Radni dani"),
                      options: [
                      
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday',
                          'Saturday',  'Sunday',
                      ].map((e) => FormBuilderFieldOption(value: e)).toList(),
                    ),
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
      request['employee'] = widget.company.companyEmployees.map((e) => e.userId).toList();
      request['rating'] = widget.company.rating;
      request['companyId'] = widget.company.companyId;

   
      request['workingDays'] = (request['workingDays'] as List).map((e) => e.toString()).toList();


      request['serviceId'] = (request['serviceId'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();

       if (request["startTime"] is DateTime) {
      request["startTime"] = (request["startTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    if (request["endTime"] is DateTime) {
      request["endTime"] = (request["endTime"] as DateTime).toIso8601String().substring(11, 19);
    }

      try {
        await companyProvider.update(widget.company.companyId, request);
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