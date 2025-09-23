import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:ko_radio_desktop/models/freelancer.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
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
    "workingDays":      localizeWorkingDays(widget.freelancer.workingDays?.map((d) => d.toString()).toList()),
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
  surfaceTintColor: Colors.white,
  child: SizedBox(
    width: MediaQuery.of(context).size.width * 0.25,
    height: MediaQuery.of(context).size.height * 1,
    child:ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 Header
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
                          'Radnički podaci',
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

                  // 🔹 Form
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FormBuilder(
                      key: _formKey,
                      initialValue: _initialValue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);

      request['isApplicant'] = false;
      request['isDeleted'] = false;

      request['rating'] = widget.freelancer.rating;
      request['freelancerId'] = widget.freelancer.freelancerId;

   
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


      request['serviceId'] = (request['serviceId'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();

       if (request["startTime"] is DateTime) {
      request["startTime"] = (request["startTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    if (request["endTime"] is DateTime) {
      request["endTime"] = (request["endTime"] as DateTime).toIso8601String().substring(11, 19);
    }

      try {
        await freelancerProvider.update(widget.freelancer.freelancerId, request);
        if(mounted && context.mounted)
        {
        Navigator.pop(context, true);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Podaci su uspješno ažurirani.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Greška tokom ažuriranja podataka. Pokušajte ponovo.")),
        );
      }
    }
  }
}
