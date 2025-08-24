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
import 'package:ko_radio_mobile/providers/base_provider.dart';
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
  String? _backendEmailError;
  File? _image;
  String? _base64Image;

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
    if(_image!=null)
    {
      formData['image'] = _base64Image;
    }
    {
      formData['image']=null;
    }

    formData["isDeleted"] = false;
    formData["isApplicant"] = true;
    formData["rating"] = 0; 
    formData["employee"]=[widget.user?.userId];
    formData["isOwner"]=true;

    var selectedServices = formData["serviceId"];
    formData["serviceId"] = (selectedServices is List)
        ? selectedServices.map((id) => int.tryParse(id.toString()) ?? 0).toList()
        : (selectedServices != null
            ? [int.tryParse(selectedServices.toString()) ?? 0]
            : []);

    try {
     await companyProvider.insert(formData);
     if(mounted && context.mounted)
     {
      Navigator.of(context).pop(true);
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Prijava poslana!")));
     }
   } on UserException catch (e) {
  setState(() {
    _backendEmailError = e.exMessage; 
  });
}
  

     catch (e) {
      debugPrint(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title:  Text("Prijava firme",style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,letterSpacing: 1.2,color: const Color.fromRGBO(27, 76, 125, 25)),),centerTitle: true,scrolledUnderElevation: 0,),
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
                    FormBuilderTextField(name: "email", decoration:  InputDecoration(labelText: "Email firme",
                    errorText: _backendEmailError),
                    onChanged: (_) {
    if (_backendEmailError != null) {
      setState(() {
        _backendEmailError = null;
      });
    }
  },
                    validator: FormBuilderValidators.compose([
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
                      decoration: const InputDecoration(labelText: "Radni dani"),
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
                      FormBuilderField(
  name: "image",

  builder: (field) {
    return InputDecorator(
      decoration:  InputDecoration(
        labelText: "Proslijedite sliku firme",
        border: OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.image),
            title: 
            
             _image != null
                ? Text(_image!.path.split('/').last)
                :  
                
                 const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),



              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image==null? const Text("Odaberi", style: TextStyle(color: Colors.white)): const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () =>  getImage(field) 
             
            ),
          ),
          const SizedBox(height: 10),
          _image != null ?
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _image!,
               
                fit: BoxFit.cover,
              ),
            ) 
           
            : 
            const SizedBox.shrink()
           
            ,
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
                  ElevatedButton(onPressed: _onSave, style: ElevatedButton.styleFrom(
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
  void getImage(FormFieldState field) async {
  var result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.single.path != null) {
    setState(() {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
    });

 
    field.didChange(_image);
  }
}
}