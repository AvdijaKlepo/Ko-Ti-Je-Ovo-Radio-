import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/freelancer_dto.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
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
  late Freelancer freelancer;
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
    try {
      var fetchedFreelancer = await freelancerProvider.getById(AuthProvider.user!.userId);
      setState(() {
        freelancer = fetchedFreelancer;
         _startTime = _parseTime(freelancer.startTime);
  _endTime   = _parseTime(freelancer.endTime);

  final now = DateTime.now();
  _initialValue = {
    "freelancerId":   freelancer.freelancerId.toString(),
    "bio":             freelancer.bio,
    "experianceYears": freelancer.experianceYears.toString(),
    "workingDays":     freelancer.workingDays?.map((d) => d.toString()).toList(),
    "startTime":       DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute),
    "endTime":         DateTime(now.year, now.month, now.day, _endTime.hour,   _endTime.minute),
    "serviceId": widget.freelancer?.freelancerServices
    ?.map((e) => e.serviceId)
    .whereType<int>()
    .toSet()
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
                       _isLoadingServices
                    ? const Center(child: CircularProgressIndicator()) :
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: serviceResult?.result != null
                                  ? FormBuilderFilterChip<int>(

                               
                                    
                                    
                                    
                                    
  name: "serviceId",
  options: serviceResult!.result.map((s) {
   
    return FormBuilderChipOption(
      
      value: s.serviceId,
      child: Text(s.serviceName),
    );
  }).toList(),
)

                                  : const Text("Nema dostupnih usluga"),
                            ),
                      
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(27, 76, 125, 25)),
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
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);

      request['isApplicant'] = false;
      request['isDeleted'] = false;
      request['rating'] = freelancer.rating;
      request['freelancerId'] = freelancer.freelancerId;

   
      request['workingDays'] = (request['workingDays'] as List).map((e) => e.toString()).toList();


      request['serviceId'] = (request['serviceId'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();

       if (request["startTime"] is DateTime) {
      request["startTime"] = (request["startTime"] as DateTime).toIso8601String().substring(11, 19);
    }
    if (request["endTime"] is DateTime) {
      request["endTime"] = (request["endTime"] as DateTime).toIso8601String().substring(11, 19);
    }

      try {
        await freelancerProvider.update(freelancer.freelancerId, request);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
    }
  }
}