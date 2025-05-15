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
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:provider/provider.dart';

class BookJob extends StatefulWidget {
  BookJob(
      {Key? key,
      this.selectedDay,
      this.freelancer,
      this.job})
      : super(key: key);
  final DateTime? selectedDay;
  final Freelancer? freelancer;
  final Job? job;

  @override
  State<BookJob> createState() => _BookJobState();
}

class _BookJobState extends State<BookJob> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late JobProvider jobProvider;
  late ServiceProvider serviceProvider;
  late FreelancerProvider freelancerProvider;

  SearchResult<Job>? jobResult;
  SearchResult<Service>? serviceResult;
  SearchResult<Freelancer>? freelancerResult;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  

  @override
  void initState() {
    jobProvider = context.read<JobProvider>();
    serviceProvider = context.read<ServiceProvider>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      freelancerProvider = context.read<FreelancerProvider>();

    });

    super.initState();
    _initialValue = {
      'jobDate': widget.selectedDay,
      
    };
    initForm();
  }

  Future initForm() async {
    jobResult = await jobProvider.get();
    serviceResult = await serviceProvider.get();
    freelancerResult = await freelancerProvider.get();
    print("Fetched user first name: ${jobResult?.result}");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      
      child: Scaffold(
        body: Column(
          children: [_buildForm(), _save()],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return FormBuilder(
        key: _formKey,
        initialValue: _initialValue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AuthProvider.userRoles?.role.roleName=="User" ? 
          Column(
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
                      child: FormBuilderCheckboxGroup<int>(
                    name: "serviceId",
                    decoration: InputDecoration(labelText: "Servis"),
                    options: widget.freelancer!.freelancerServices?.map(
                              (item) => FormBuilderFieldOption<int>(
                                value: item.service!.serviceId,
                                child: Text(item.service?.serviceName ?? ""),
                              ),
                            )
                            .toList() ??
                        [],
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: FormBuilderField(
                    name: "image",
                    builder: (field) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            labelText: "Proslijedite sliku problema"),
                        child: Expanded(
                            child: ListTile(
                          leading: Icon(Icons.image),
                          title: Text("Slika"),
                          trailing: Icon(Icons.file_upload),
                          onTap: getImage,
                        )),
                      );
                    },
                  ))
                ],
              )
            ],
          ): Column(
            children: [
              Text('${widget.job?.startEstimate}'),
              Text('${widget.job?.jobDescription}'),
              Text('${widget.job?.jobDate}'),
              Text('${widget.job?.user?.firstName}'),
              Text(widget.job!.jobsServices
                      ?.map((e) => e.service?.serviceName)
                      .where((name) => name != null)
                      .join(', ') ??
                  'No services'),
              Row(
                children: [
                  Expanded(
                      child: FormBuilderDateTimePicker(
                    decoration: InputDecoration(labelText: 'Trajanje posla'),
                    name: "endEstimate",
                    inputType: InputType.time,
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: FormBuilderTextField(
                    decoration: InputDecoration(labelText: 'Moguća Cijena'),
                    name: "payEstimate",
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    valueTransformer: (value) => double.tryParse(value ?? ''),
                  )),
                ],
              ),
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
          ElevatedButton(
              onPressed: () {
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
            final payEstimate = formData['payEstimate'] as double?;
                final endEstimate = (formData['endEstimate'] as DateTime?);

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

                if(widget.job==null){
                      formData["freelancerId"] = widget.freelancer?.freelancerId;
                formData["userId"] = AuthProvider.user?.userId;
                   jobProvider.insert(formData);
                } else{
                formData["freelancerId"] = AuthProvider.freelancer?.freelancerId;
                formData["userId"] = widget.job?.user?.userId;
                  jobProvider.update(widget.job!.jobId!, {
                    'endEstimate': endEstimate != null
                        ? '${endEstimate.hour.toString().padLeft(2, '0')}:${endEstimate.minute.toString().padLeft(2, '0')}:${endEstimate.second.toString().padLeft(2, '0')}'
                        : null,
                    'payEstimate': payEstimate,
                    'freelancerId': widget.job?.freelancer?.freelancerId,
                    'startEstimate': widget.job?.startEstimate,
                    'userId': widget.job?.user?.userId,
                    'serviceId': widget.job?.jobsServices
                        ?.map((e) => e.service?.serviceId)
                        .toList(),
                    'jobDescription': widget.job?.jobDescription,
                    'image': widget.job?.image,
                    'jobDate': widget.job?.jobDate.toIso8601String()
                  });
                     ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Job updated successfully')),
                  );
                }

               
              },
              child: Text("Sačuvaj"))
        ],
      ),
    );
  }
}
