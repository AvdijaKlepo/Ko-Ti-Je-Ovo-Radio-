import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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

  void _onSave() {
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

    Map<String, int> dayMap = {
      'Nedjelja': 0, 'Ponedjeljak': 1, 'Utorak': 2, 'Srijeda': 3,
      'Četvrtak': 4, 'Petak': 5, 'Subota': 6,
    };

    if (formData["workingDays"] != null) {
      formData["workingDays"] = (formData["workingDays"] as List<String>)
          .map((day) => dayMap[day])
          .whereType<int>()
          .toList();
    }

    formData['userId'] = AuthProvider.user?.userId ?? 0;

    formData["roles"] = [10];
    formData["isDeleted"] = false;
    formData["isApplicant"] = true;
    formData["rating"] = 0; 

    var selectedServices = formData["serviceId"];
    formData["serviceId"] = (selectedServices is List)
        ? selectedServices.map((id) => int.tryParse(id.toString()) ?? 0).toList()
        : (selectedServices != null
            ? [int.tryParse(selectedServices.toString()) ?? 0]
            : []);

    try {
      freelancerProvider.insert(formData);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Prijava poslana!")));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: const Text("Promovi korisnika")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Promoviši korisnika: ${widget.user?.firstName} ${widget.user?.lastName}",
                  style: Theme.of(context).textTheme.titleLarge),
              spacing,
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                  
                    spacing,
                    FormBuilderTextField(name: "firstName", decoration: const InputDecoration(labelText: "First Name"),validator: FormBuilderValidators.required(errorText: "Obavezno polje")),
                    spacing,
                    FormBuilderTextField(name: "lastName", decoration: const InputDecoration(labelText: "Last Name"),validator: FormBuilderValidators.required(errorText: "Obavezno polje")),
                    spacing,
                    FormBuilderTextField(name: "email", decoration: const InputDecoration(labelText: "Email"),validator: FormBuilderValidators.required(errorText: "Obavezno polje")),
                  ]),
                ),
              ),
              spacing,
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                    FormBuilderTextField(name: "bio", decoration: const InputDecoration(labelText: "Biografija"),validator: FormBuilderValidators.required(errorText: "Obavezno polje"),maxLines: 3,),
                    spacing,
                    FormBuilderTextField(
                        name: "experianceYears", decoration: const InputDecoration(labelText: "Years of Experience"),validator: FormBuilderValidators.required(errorText: "Obavezno polje")),
                    spacing,
                  
                    spacing,
                    FormBuilderDateTimePicker(
                      name: 'startTime',
                      decoration: const InputDecoration(labelText: "Početak radnog vremena"),
                      inputType: InputType.time,
                      validator: FormBuilderValidators.required(errorText: "Obavezno polje")
                    ),
                    spacing,
                    FormBuilderDateTimePicker(
                      name: 'endTime',
                      decoration: const InputDecoration(labelText: "Kraj radnog vremena"),
                      inputType: InputType.time,
                      validator: FormBuilderValidators.required(errorText: "Obavezno polje")
                    ),
                  ]),
                ),
              ),
              spacing,
                ExpansionTile(
                  title: const Text("Odaberi usluge"),
                  initiallyExpanded: false,
                  children: [
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
                               validator: (value) {
    if (value == null || value.isEmpty) {
      return "Odaberite barem jednu uslugu";
    }
    return null;
  },
                              
                            )
                          : const Text("Nema dostupnih usluga"),
                    ),
                  ],
                ),
              spacing,
             FormBuilderCheckboxGroup<String>(
              validator: FormBuilderValidators.required(errorText: "Obavezno polje"),
                      name: 'workingDays',
                      decoration: InputDecoration(labelText: "Radni dani"),
                      options: [
                        'Ponedjeljak',
                        'Utorak',
                        'Srijeda',
                        'Četvrtak',
                        'Petak',
                        'Subota',
                        'Nedjelja'
                      ].map((e) => FormBuilderFieldOption(value: e)).toList(),
                    ),
              spacing,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Odustani")),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _onSave, child: const Text("Sačuvaj")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
