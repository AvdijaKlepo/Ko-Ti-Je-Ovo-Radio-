import 'dart:convert';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/tender_provider.dart';
import 'package:provider/provider.dart';

class BookTender extends StatefulWidget {
  const BookTender({this.isFreelancer,super.key});
  final bool? isFreelancer;

  @override
  State<BookTender> createState() => _BookTenderState();
}

class _BookTenderState extends State<BookTender> {
  final _formKey = GlobalKey<FormBuilderState>();
  late JobProvider tenderProvider;
  late ServiceProvider serviceProvider;
  SearchResult<Service>? serviceResult;
  File? _image;
  String? _base64Image;
 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tenderProvider = context.read<JobProvider>();
      serviceProvider = context.read<ServiceProvider>();
      _getServices();
    });
  }

  Future<void> _getServices() async {
    try {
      final fetched = await serviceProvider.get();
      setState(() {
        serviceResult = fetched;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri dohvatu servisa: $e")),
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      final request = {
      "jobDate": (values['jobDate'] as DateTime).toIso8601String(),
      

        "jobDescription": values['jobDescription'],
        "jobTitle":values['jobTitle'],
        "isTenderFinalized": true,
        "serviceId": values["serviceId"] ?? [],
        "userId": AuthProvider.user?.userId,
        "image": _base64Image,
        "jobStatus": JobStatus.unapproved.name,
        "isFreelancer":widget.isFreelancer,
        "isInvoiced": false,
        "isRated": false,
      };

      try {
        await tenderProvider.insert(request);
        if (!mounted) return;
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tender je uspešno objavljen")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška prilikom slanja tendera: $e")),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final serviceOptions = serviceResult?.result
            .map((s) => FormBuilderFieldOption<int>(
                  value: s.serviceId,
                  child: Text(s.serviceName ?? ''),
                ))
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(title: const Text('Rezerviši tender')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
             
              
              FormBuilderTextField(
                name: "jobTitle",
                decoration: const InputDecoration(
                  labelText: 'Naslov posla',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),

                
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                     (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ\s]+$'); 
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova';
      }
      return null;
    },
                ]),
              ),
              SizedBox(height: 20,),
               FormBuilderTextField(
                name: "jobDescription",
                decoration: const InputDecoration(
                  labelText: 'Opis posla',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                     (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ0-9\s.]+$');
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova i brojevi';
      }
      return null;
    },
                ]),
              ),
              const SizedBox(height: 20,child: Text("Napomena: Datum tendera mora biti minimalno 5 dana unaprijed.", style: TextStyle(fontSize: 12, color: Color.fromRGBO(27, 76, 125, 25)),),),
              FormBuilderDateTimePicker(
                name: "jobDate",
                initialDate: DateTime.now().add(Duration(days: 5)),
                firstDate: DateTime.now().add(Duration(days: 5)),
                inputType: InputType.date,

            
                decoration: const InputDecoration(
                  labelText: "Datum posla",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
              ),
              
              const SizedBox(height: 15),
              FormBuilderCheckboxGroup<int>(
                name: "serviceId",
                decoration: const InputDecoration(labelText: "Servisi"),
                options: serviceOptions,
                validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
              ),
              const SizedBox(height: 15),
            FormBuilderField(
  name: "image",
  builder: (field) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Proslijedite sliku problema",
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
                : const Text("Nema izabrane slike"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(27, 76, 125, 1),
                textStyle: const TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image==null? const Text("Odaberi", style: TextStyle(color: Colors.white)): const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () => getImage(field),
            ),
          ),
          const SizedBox(height: 10),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _image!,
                width: 350,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  },
),
             
             
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor:Color.fromRGBO(27, 76, 125, 25)),
                onPressed: _submit,
                child: const Text("Objavi tender",style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
