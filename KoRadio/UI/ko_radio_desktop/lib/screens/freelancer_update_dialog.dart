import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ko_radio_desktop/models/freelancer.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:provider/provider.dart';



class FreelancerUpdateDialog extends StatefulWidget {
  final Freelancer freelancer;

  const FreelancerUpdateDialog({super.key, required this.freelancer});

  @override
  State<FreelancerUpdateDialog> createState() => _FreelancerUpdateDialogState();
}

class _FreelancerUpdateDialogState extends State<FreelancerUpdateDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late FreelancerProvider freelancerProvider;
  late ServiceProvider serviceProvider;
  SearchResult<Service>? serviceResult;


  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late List<bool> _selectedDays;

  @override
void initState() {
  super.initState();
  serviceProvider = context.read<ServiceProvider>();
  freelancerProvider = context.read<FreelancerProvider>();

  _startTime = _parseTime(widget.freelancer.startTime);
  _endTime   = _parseTime(widget.freelancer.endTime);

  final now = DateTime.now();
  _initialValue = {
    "freelancerId":    widget.freelancer.freelancerId.toString(),
    "bio":             widget.freelancer.bio,
    "experianceYears": widget.freelancer.experianceYears.toString(),
    "workingDays":     widget.freelancer.workingDays?.map((d) => d.toString()).toList(),
    "startTime":       DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute),
    "endTime":         DateTime(now.year, now.month, now.day, _endTime.hour,   _endTime.minute),
   "serviceId": widget.freelancer.freelancerServices
    .map((e) => e.serviceId)
    .whereType<int>() 
    .toList(),

  };



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

  Future<void> _getServices() async {
    try {
      var fetchedServices = await serviceProvider.get();
      setState(() {
        serviceResult = fetchedServices;
       
      });
    } catch (e) {
      print(e);
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
                      const Text("Radnički Podaci", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                       
                      FormBuilderTextField(
                        name: "bio",
                        decoration: const InputDecoration(
                          labelText: "Biografija",
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.required(),
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
                          FormBuilderValidators.required(),
                          FormBuilderValidators.integer(),
                          FormBuilderValidators.min(0),
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
                          'Sunday',
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday',
                          'Saturday',
                        ].map((e) => FormBuilderFieldOption(value: e)).toList(),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 12),
                      FormBuilderDateTimePicker(
                        name: 'startTime',
                        inputType: InputType.time,
                        decoration: const InputDecoration(
                          labelText: "Početak Smjene",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FormBuilderDateTimePicker(
                        name: 'endTime',
                        inputType: InputType.time,
                        decoration: const InputDecoration(
                          labelText: "Kraj Smjene",
                          border: OutlineInputBorder(),
                        ),
                      ),
                     
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: serviceResult?.result != null
                                ? FormBuilderFilterChip(
                                    name: "serviceId",
                                    decoration: const InputDecoration(border: InputBorder.none),
                                    options: serviceResult!.result
                                        .map((s) => FormBuilderChipOption(
                                            value: s.serviceId, 
                                             child: Text(s.serviceName ?? "")))
                                        .toList(),
                                    spacing: 6,
                                    runSpacing: 4,
                                  )
                                : const Text("Nema dostupnih usluga"),
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
      request['roles'] = [10, 11];
      request['rating'] = widget.freelancer.rating;
      request['freelancerId'] = widget.freelancer.freelancerId;

   
      request['workingDays'] = (request['workingDays'] as List).map((e) => e.toString()).toList();


      request['serviceId'] = (request['serviceId'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();

       if (request["startTime"] is DateTime) {
      request["startTime"] = (request["startTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    if (request["endTime"] is DateTime) {
      request["endTime"] = (request["endTime"] as DateTime).toIso8601String().substring(11, 19);
    }

      try {
        await freelancerProvider.update(widget.freelancer.freelancerId, request);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
    }
  }
}
