import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:provider/provider.dart';

class UserCompanyApply extends StatefulWidget {

  final User? user;
  const UserCompanyApply({super.key, this.user});

  @override
  State<UserCompanyApply> createState() => _UserCompanyApplyState();
}

class _UserCompanyApplyState extends State<UserCompanyApply> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late CompanyProvider companyProvider;
  late ServiceProvider serviceProvider;
  late LocationProvider locationProvider;

  SearchResult<Location>? locationResult;


  SearchResult<Service>? serviceResult;

  @override
  void initState() {
    super.initState();
    companyProvider = context.read<CompanyProvider>();
    serviceProvider = context.read<ServiceProvider>();
    locationProvider = context.read<LocationProvider>();

    print(widget.user?.userId);

    _initialValue = {
      
    };

    _fetchData();
  }

  Future<void> _fetchData() async {
    final services = await serviceProvider.get();
    final locations = await locationProvider.get();
    setState(() {
      serviceResult = services;
      locationResult = locations;
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

    formData["isDeleted"] = false;
    formData["isApplicant"] = true;
    formData["rating"] = 0; 
    formData["employee"]=[widget.user?.userId];
    formData["roles"]=[10,1009 ];

    var selectedServices = formData["serviceId"];
    formData["serviceId"] = (selectedServices is List)
        ? selectedServices.map((id) => int.tryParse(id.toString()) ?? 0).toList()
        : (selectedServices != null
            ? [int.tryParse(selectedServices.toString()) ?? 0]
            : []);

    try {
      companyProvider.insert(formData);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Prijava poslana!")));
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title: const Text("Prijava firme")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Prijava firme za korisnika: ${widget.user?.firstName} ${widget.user?.lastName}",
                  style: Theme.of(context).textTheme.titleLarge),
             
             
          
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                    FormBuilderTextField(name: "companyName", decoration: const InputDecoration(labelText: "Ime Firme:"),validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.required(errorText: "Obavezno polje"),
                        (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ\s]+$'); 
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova';
      }
      return null;
    },
                      ]
                    )),

                    FormBuilderTextField(name: "bio", decoration: const InputDecoration(labelText: "Opis"),validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Obavezno polje'),
                      (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ0-9\s]+$');
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova i brojevi';
      }
      return null;
    },
                    ])),
                    FormBuilderTextField(name: "email", decoration: const InputDecoration(labelText: "Email firme"),validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Obavezno polje'),
                      FormBuilderValidators.email(errorText: "Email nije valjan"),
                    ])),
                    
                    FormBuilderTextField(
                        name: "experianceYears", decoration: const InputDecoration(labelText: "Godine iskustva"),validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Obavezno polje'),
                          FormBuilderValidators.numeric(errorText: "Dozvoljeni si u samo brojevi."),
                        ])),

                          FormBuilderTextField(
                        name: "phoneNumber", decoration: const InputDecoration(labelText: "Telefonski broj"),validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Obavezno polje'),
                          FormBuilderValidators.match(r'^\+\d{7,15}$',
                    errorText:
                        "Telefon mora imati od 7 do 15 cifara \ni počinjati znakom +."),
                        ])),
                
                  
                    FormBuilderDateTimePicker(
                      name: 'startTime',
                      decoration: const InputDecoration(labelText: "Početak radnog vremena"),
                      inputType: InputType.time,
                      validator: FormBuilderValidators.required(errorText: "Obavezno polje")
                    ),
                
                    FormBuilderDateTimePicker(
                      name: 'endTime',
                      decoration: const InputDecoration(labelText: "Kraj radnog vremena"),
                      inputType: InputType.time,
                      validator: FormBuilderValidators.required(errorText: "Obavezno polje")
                    ),
                  ]),
                ),
              ),
              
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
       
             FormBuilderCheckboxGroup<String>(
                      name: 'workingDays',
                      validator: FormBuilderValidators.required(errorText: "Obavezno polje"),
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
                    FormBuilderDropdown<int>(
                      name: 'locationId',
                      
                      decoration: const InputDecoration(labelText: "Lokacija*"),
                      validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                      items: locationResult?.result
                              .map((loc) => DropdownMenuItem(
                                    value: loc.locationId,
                                    child: Text(loc.locationName),
                                  ))
                              .toList() ??
                          [],
                    ),
           
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