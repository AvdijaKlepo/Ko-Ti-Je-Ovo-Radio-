import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  Uint8List? _decodedImage;

  @override
  void initState() {
    super.initState();
    companyProvider = context.read<CompanyProvider>();
    serviceProvider = context.read<ServiceProvider>();
    locationProvider = context.read<LocationProvider>();

    print(widget.user?.userId);

    _initialValue = {
      
    };
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    await _fetchData();
    });
  
  }

  Future<void> _fetchData() async {
    final services = await serviceProvider.get();
    final locations = await locationProvider.get();
    setState(() {
      serviceResult = services;
      locationResult = locations;
      });
  }
   Future<void> _pickImage() async {
  var result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.single.path != null) {
    setState(() {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
      _decodedImage = null; 
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
_formKey.currentState?.invalidateField(
        name: "email",
        errorText: e.exMessage,
      );
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
             
             
          
            
                     FormBuilderTextField(
  name: "companyName",
  decoration: const InputDecoration(labelText: "Ime Firme:",border: OutlineInputBorder()),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Ime firme je obavezno."),
    FormBuilderValidators.minLength(2, errorText: "Minimalno 2 znaka."),
    FormBuilderValidators.maxLength(50, errorText: "Maksimalno 50 znakova."),
    FormBuilderValidators.match(r'^[A-Z][A-Za-zĆČĐŠŽćčđšž. ]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim'),
  ]),
),
const SizedBox(height: 20),

FormBuilderTextField(
  name: "bio",
  maxLines: 5,
  decoration: const InputDecoration(labelText: "Opis",border: OutlineInputBorder()),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Opis je obavezan."),
    FormBuilderValidators.minLength(10, errorText: "Minimalno 10 znakova."),
    FormBuilderValidators.maxLength(300, errorText: "Maksimalno 300 znakova."),
    FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž0-9\s.,\-\/!]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim i brojevi'),
  ]),
),
const SizedBox(height: 20),

FormBuilderTextField(
  name: "email",
  decoration: const InputDecoration(labelText: "Email",border: OutlineInputBorder()),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Email je obavezan."),
    FormBuilderValidators.email(errorText: "Unesite ispravan email."),
  ]),
),
const SizedBox(height: 20),

FormBuilderTextField(
  name: "experianceYears",
  decoration: const InputDecoration(labelText: "Godine iskustva",border: OutlineInputBorder()),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Godine iskustva su obavezne."),
    FormBuilderValidators.integer(errorText: "Mora biti broj."),
    FormBuilderValidators.min(0, errorText: "Ne može biti negativno."),
    FormBuilderValidators.max(100, errorText: "Unesite realan broj godina. Max 100"),
  ]),
),
const SizedBox(height: 20),

FormBuilderTextField(
  name: "phoneNumber",
  decoration: const InputDecoration(labelText: "Telefonski broj",border: OutlineInputBorder()),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: "Telefon je obavezan."),
    FormBuilderValidators.match(
      r'^\+?\d{11}$',
      errorText: "Potrebno je 11 cifara sa početkom od +387",
    ),
  ]),
),
const SizedBox(height: 20),

FormBuilderDateTimePicker(
  name: 'startTime',
  decoration: const InputDecoration(labelText: "Početak radnog vremena",border: OutlineInputBorder()),
  inputType: InputType.time,
  validator: FormBuilderValidators.required(errorText: "Početak je obavezan."),
),
const SizedBox(height: 20),

FormBuilderDateTimePicker(
  name: 'endTime',
  decoration: const InputDecoration(labelText: "Kraj radnog vremena",border: OutlineInputBorder()),
  inputType: InputType.time,
  validator: (value) {
    final form = FormBuilder.of(context);
    final start = form?.fields['startTime']?.value;
    if (value == null) return "Kraj je obavezan.";
    if (start != null) {
      if (value.isBefore(start)) {
        return "Kraj mora biti nakon početka.";
      }
      if (value.difference(start).inHours < 3) {
        return "Smjena mora trajati barem 3 sata.";
      }
    }
    return null;
  },
),
const SizedBox(height: 20),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 0),
  child: serviceResult?.result.isNotEmpty == true
      ? FormBuilderFilterChip<int>(
          name: "serviceId",
          decoration: const InputDecoration(border: OutlineInputBorder()),
          options: serviceResult!.result
              .map((s) => FormBuilderChipOption(
                  value: s.serviceId, child: Text(s.serviceName ?? "")))
              .toList(),
          spacing: 6,
          runSpacing: 4,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: "Odaberite bar jednu uslugu."),
          ]),
        )
      : const Text("Nema dostupnih usluga"),
),
const SizedBox(height: 20),

FormBuilderCheckboxGroup<String>(
  name: 'workingDays',
  decoration: const InputDecoration(labelText: "Radni dani",border: OutlineInputBorder()),
  options: [
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday',
  ].map((e) => FormBuilderFieldOption(value: e)).toList(),
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.minLength(1, errorText: "Odaberite bar jedan dan."),
  ]),
),
const SizedBox(height: 20),

FormBuilderDropdown<int>(
  name: 'locationId',
  decoration: const InputDecoration(labelText: "Lokacija*",border: OutlineInputBorder()),
  validator: FormBuilderValidators.required(errorText: 'Lokacija je obavezna.'),
  items: locationResult?.result
          .map((loc) => DropdownMenuItem(
                value: loc.locationId,
                child: Text(loc.locationName ?? ''),
              ))
          .toList() ??
      [],
),

                    const SizedBox(height: 20,),
                      FormBuilderField(
  name: "image",
  builder: (field) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Logo",
        border: OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.image),
            title: _image != null
                ? Text(_image!.path.split('/').last)
                
                    : const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image == null 
                  ? const Text("Odaberi", style: TextStyle(color: Colors.white))
                  : const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () => _pickImage(),
            ),
          ),
          const SizedBox(height: 10),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            )
          else if (_decodedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _decodedImage!,
                fit: BoxFit.cover,
              ),
            )
          else
            const SizedBox.shrink(),
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