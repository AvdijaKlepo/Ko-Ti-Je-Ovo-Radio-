import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:provider/provider.dart';

class BookJob extends StatefulWidget {
  BookJob(this.selectedDay,{super.key});
  DateTime selectedDay;
  

  @override
  State<BookJob> createState() => _BookJobState();
}

class _BookJobState extends State<BookJob> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late JobProvider jobProvider;
  late ServiceProvider serviceProvider;

  SearchResult<Job>? jobResult;
  SearchResult<Service>? serviceResult;
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }
  @override
  void initState(){
    jobProvider = context.read<JobProvider>();
    serviceProvider = context.read<ServiceProvider>();

    super.initState();
    _initialValue={
      'jobDate':widget.selectedDay
    };
    initForm();
  }
   Future initForm() async {
    jobResult = await jobProvider.get();
    serviceResult = await serviceProvider.get();
    print("Fetched user first name: ${jobResult?.result}");
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MasterScreen(
      child: Scaffold(
        body:  Column(children: [
        _buildForm(),
        _save()

      ],),
      ),
    );
  }
  
  Widget _buildForm() {
    return FormBuilder(
        key: _formKey,
        initialValue: _initialValue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: FormBuilderDateTimePicker(
                    decoration: InputDecoration(labelText: 'Datum rezervacije'),
                    name: "jobDate",
                    inputType: InputType.date,
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: FormBuilderDateTimePicker(
                    decoration:
                        InputDecoration(labelText: 'Vrijeme rezervacije'),
                    name: "startEstimate",
                    inputType: InputType.time,
                  
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: FormBuilderTextField(
                          decoration:
                              InputDecoration(labelText: 'Opis problema'),
                          name: "jobDescription")),
                ],
              ),
               Row(
                       children: [
                          Expanded(
                            child:   FormBuilderCheckboxGroup<int>(
                              name: "serviceId",
                              decoration: InputDecoration(labelText: "Servis"),
                              options: serviceResult?.result.map((item) => FormBuilderFieldOption<int>(value: item.serviceId ,child: Text(item.serviceName ?? ""),),).toList() ?? [],
                              )
                          ),
                        
                       ],
                    ),
                     Row(
                  children: [
                    Expanded(child: FormBuilderField(
                      name:"image",
                      builder: (field){
                        return InputDecorator(decoration: InputDecoration(labelText: "Proslijedite sliku problema"),
                        child: Expanded(child: ListTile(
                          leading: Icon(Icons.image),
                          title: Text("Slika"),
                          trailing: Icon(Icons.file_upload),
                          onTap: getImage,
                        )),);
                      },
                    ))
                  ],
                )
            ],
          ),
        ));
  }
  
  File? _image;
  String? _base64Image;

  void getImage() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
        _image = File(result.files.single.path!);
        _base64Image = base64Encode(_image!.readAsBytesSync());
    }
  }
  
  Widget _save() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(onPressed: () {
              _formKey.currentState?.saveAndValidate();
              debugPrint(_formKey.currentState?.value.toString());
           var formData = Map<String, dynamic>.from(
                    _formKey.currentState?.value ?? {});

                if (formData["startEstimate"] is DateTime) {
                  formData["startEstimate"] =
                      (formData["startEstimate"] as DateTime)
                          .toIso8601String()
                          .substring(11, 19);
                }

                if (formData["jobDate"] is DateTime) {
                  formData["jobDate"] =
                      (formData["jobDate"] as DateTime).toIso8601String();
                }


                if (_base64Image != null) {
                  formData['image'] = _base64Image;
                }
               
                debugPrint(_formKey.currentState?.value.toString());
                  var selectedServices = formData["serviceId"];
                formData["serviceId"] = (selectedServices is List)
                    ? selectedServices
                        .map((id) => int.tryParse(id.toString()) ?? 0)
                        .toList()
                    : (selectedServices != null
                        ? [int.tryParse(selectedServices.toString()) ?? 0]
                        : []);
                debugPrint(_formKey.currentState?.value.toString());

                jobProvider.insert(formData);

              
            }, child: Text("Sačuvaj"))
          ],
        ),
      );
  }
}