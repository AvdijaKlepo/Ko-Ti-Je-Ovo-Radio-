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
  padding: const EdgeInsets.symmetric(horizontal: 0),
  child: serviceResult?.result != null
      ? FormBuilderFilterChip<int>(
          name: "serviceId",
          decoration: const InputDecoration(
            labelText: "Usluge",
            border: InputBorder.none,
          ),
          options: serviceResult!.result
              .map((s) => FormBuilderChipOption(
                  value: s.serviceId,
                  child: Text(s.serviceName ?? "")))
              .toList(),
          spacing: 6,
          runSpacing: 4,
          validator: FormBuilderValidators.required(
              errorText: "Odaberite barem jednu uslugu."),
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
