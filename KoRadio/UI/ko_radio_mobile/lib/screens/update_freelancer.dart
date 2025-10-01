import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/freelancer_dto.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class FreelancerUpdate extends StatefulWidget {
  const FreelancerUpdate({this.freelancer, super.key});
  final FreelancerDto? freelancer;



  @override
  State<FreelancerUpdate> createState() => _FreelancerUpdateState();
}

class _FreelancerUpdateState extends State<FreelancerUpdate> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late FreelancerProvider freelancerProvider;
  late ServiceProvider serviceProvider;
  late SearchResult<Freelancer>? freelancerResult;

  SearchResult<Service>? serviceResult;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isLoadingServices = true;
  @override
void initState() {
  super.initState();
  serviceProvider = context.read<ServiceProvider>();
  freelancerProvider = context.read<FreelancerProvider>();
  print(widget.freelancer?.freelancerId);
 
  


  _getFreelancer();
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
  Future<void> _getFreelancer() async {
    var filter = {'FreelancerId':AuthProvider.user?.userId};
    try {
      var fetchedFreelancer = await freelancerProvider.get(filter: filter);
      setState(() {
        freelancerResult = fetchedFreelancer;
         final freelancer = freelancerResult!.result.first;
      
         _startTime = _parseTime(freelancer.startTime);
          _endTime   = _parseTime(freelancer.endTime);

  final now = DateTime.now();
  _initialValue = {
    "freelancerId":   freelancer.freelancerId.toString(),
    "bio":             freelancer.bio,
    "experianceYears": freelancer.experianceYears.toString(),
    "workingDays": localizeWorkingDays(freelancer.workingDays?.map((d) => d.toString()).toList()),
    "startTime":       DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute),
    "endTime":         DateTime(now.year, now.month, now.day, _endTime.hour,   _endTime.minute),
    "serviceId": freelancer?.freelancerServices
    ?.map((e) => e.serviceId)
    .whereType<int>()

    .toList(),

  };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  
  Future<void> _getServices() async {
    try {
      var fetchedServices = await serviceProvider.get();
      setState(() {
        serviceResult = fetchedServices;
        _isLoadingServices=false;
       
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
      _isLoadingServices = false;
    }
  }
  @override
  Widget build(BuildContext context) {
     if (!mounted || _initialValue.isEmpty || _isLoadingServices || serviceResult == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
    return Scaffold(
      appBar: AppBar(title: const Text('Ažuriraj radničke podatke')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
                  child: FormBuilder(
                    key: _formKey,
                    initialValue: _initialValue,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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

                            
                      
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(27, 76, 125, 25)),
                            icon: const Icon(Icons.save,color: Colors.white,),
                            label: const Text("Sačuvaj",style: TextStyle(color: Colors.white),),
                            onPressed: _save,
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
    final meessage = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);

      request['isApplicant'] = false;
      request['isDeleted'] = false;
      request['rating'] = freelancerResult!.result.first.rating;
      request['freelancerId'] = freelancerResult!.result.first.freelancerId;

   
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
        await freelancerProvider.update(freelancerResult!.result.first.freelancerId, request);
        meessage.showSnackBar(
          const SnackBar(content: Text("Ažuriranje je uspješno završeno.")),
        );
        navigator.pop(true);
      } on UserException catch (e) {
        meessage.showSnackBar(
          SnackBar(content: Text(e.exMessage)),
        );
      }
      
      catch (e) {
        meessage.showSnackBar(
          const SnackBar(content: Text("Greška. Pokušajte ponovo.")),
        );
      }
    }
  }
}