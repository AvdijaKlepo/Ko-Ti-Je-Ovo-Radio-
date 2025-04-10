import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:provider/provider.dart';

class ServiceDetailScreen extends StatefulWidget {
  Service? service;
  ServiceDetailScreen({super.key, this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
   final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late ServiceProvider serviceProvider;

  SearchResult<Service>? serviceResult;
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  @override
  void initState() {

    serviceProvider= context.read<ServiceProvider>();

    super.initState();

    _initialValue = {
      'serviceId':widget.service?.serviceId,
      'serviceName':widget.service?.serviceName,
      'image':widget.service?.image
    };

    initForm();
  }
  Future initForm() async {
    serviceResult = await serviceProvider.get();
    print("Fetched user first name: ${serviceResult?.result}");
    setState(() {
      
    });
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold( body:
       Column(children: [
        _buildForm(),
        _save()
      ],),);

  }
  
  Widget _buildForm() {
    return FormBuilder(
        key: _formKey,
        initialValue: _initialValue,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Row(children: [
                SizedBox(
                  width: 10,
                ),
              
                   Expanded(
                    child: FormBuilderTextField(
                  decoration: InputDecoration(labelText: "Service Name"),
                  name: "serviceName",
                )),

              
              ]),
                Row(
                  children: [
                    Expanded(child: FormBuilderField(
                      name:"image",
                      builder: (field){
                        return InputDecorator(decoration: InputDecoration(labelText: "Odaberi sliku"),
                        child: Expanded(child: ListTile(
                          leading: Icon(Icons.image),
                          title: Text("Select image"),
                          trailing: Icon(Icons.file_upload),
                          onTap: getImage,
                        )),);
                      },
                    ))
                  ],
                )
            ])));
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

              var request = Map.from(_formKey.currentState!.value);
              
              request['image'] = _base64Image;


              if(widget.service == null) {
                serviceProvider.insert(request);
              } else {
                serviceProvider.update(widget.service!.serviceId, request);
              }

              
            }, child: Text("Sačuvaj"))
          ],
        ),
      );
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
}