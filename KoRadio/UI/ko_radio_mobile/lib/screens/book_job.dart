import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class BookJob extends StatefulWidget {
   const BookJob({super.key, this.selectedDay, this.freelancer, this.job,this.bookedJobs});
  final DateTime? selectedDay;
  final Freelancer? freelancer;
  final Job? job;
  final List<Job>? bookedJobs;


  @override
  State<BookJob> createState() => _BookJobState();
}

class _BookJobState extends State<BookJob> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  DateTime? _currentJobDate;
  List<Job>? _currentBookedJobs;
    late Set<int> _workingDayInts;

  final Map<String, int> _dayStringToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };


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


     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      jobProvider = context.read<JobProvider>();
      _getServices();
    });
 _workingDayInts = widget.freelancer?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};

    _currentJobDate = widget.selectedDay;


    _currentBookedJobs = widget.bookedJobs;

    _initialValue = {'jobDate': widget.selectedDay};
    initForm();
  }
    bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }

  _getServices() async {
    var filter={'FreelancerId':widget.freelancer?.freelancerId,'JobDate':_currentJobDate,
    };

   
    var job = await jobProvider.get(filter: filter);
  
    setState(() {
      jobResult = job;
    });
  }

  Future initForm() async {
    jobResult = await jobProvider.get();
    serviceResult = await serviceProvider.get();
    freelancerResult = await freelancerProvider.get();
    //print("Fetched user first name: ${jobResult?.result}");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final startTimeString = widget.freelancer?.startTime ?? "08:00";
    final endTimeString = widget.freelancer?.endTime ?? "17:00";

    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final startTime = parseTime(startTimeString);
    final endTime = parseTime(endTimeString);

    return Scaffold(
      appBar: appBar(title: 'Rezerviši posao', automaticallyImplyLeading: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
          child: AuthProvider.userRoles?.role.roleName == "User"
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentBookedJobs != null && _currentBookedJobs!.isNotEmpty) ...[
                      Text(
                        'Rezervacije za ${_currentJobDate?.toIso8601String().split('T')[0]}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      ..._currentBookedJobs!.map(
                        (job) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '  ${job.startEstimate.substring(0, 5)} - ${job.endEstimate?.substring(0, 5)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                    ] else
                      const Text('Nema rezervacija', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    FormBuilderDateTimePicker(
                      decoration: const InputDecoration(
                        labelText: 'Datum rezervacije',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      name: "jobDate",
                      inputType: InputType.date,
                      firstDate: DateTime.now(),
                      selectableDayPredicate: _isWorkingDay,
                      onChanged: (value) async {
                        setState(() {
                          _currentJobDate = value;
                          _formKey.currentState?.patchValue({'startEstimate': null});
                        });

                        var filter = {
                          'FreelancerId': widget.freelancer?.freelancerId,
                          'JobDate': _currentJobDate,
                        };

                        var jobs = await jobProvider.get(filter: filter);

                        setState(() {
                          _currentBookedJobs = jobs.result;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    FormBuilderCustomTimePicker(
                      name: 'startEstimate',
                      minTime: startTime,
                      maxTime: endTime,
                      now: TimeOfDay.now(),
                      jobDate: _currentJobDate,
                      bookedJobs: _currentBookedJobs,
                    ),
                    const SizedBox(height: 15),
                    FormBuilderTextField(
                      name: "jobDescription",
                      decoration: const InputDecoration(
                        labelText: 'Opis problema',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    FormBuilderCheckboxGroup<int>(
                      name: "serviceId",
                      decoration: const InputDecoration(
                        labelText: "Servis",
                        border: InputBorder.none,
                      ),
                      options: widget.freelancer?.freelancerServices
                              ?.map(
                                (item) => FormBuilderFieldOption<int>(
                                  value: item.service!.serviceId,
                                  child: Text(item.service?.serviceName ?? ""),
                                ),
                              )
                              .toList() ??
                          [],
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
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.image),
                            title: _image != null
                                ? Text(_image!.path.split('/').last)
                                : const Text("Nema izabrane slike"),
                            trailing: ElevatedButton.icon(
                              icon: const Icon(Icons.file_upload),
                              label: const Text("Odaberi"),
                              onPressed: getImage,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              : _buildFreelancerJobView(),
        ),
      ),
      bottomNavigationBar: _save(),
    );
  }

  Widget _buildFreelancerJobView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Početak:', widget.job?.startEstimate ?? '-'),
        _buildInfoRow('Opis:', widget.job?.jobDescription ?? '-'),
        _buildInfoRow('Datum:', widget.job?.jobDate.toIso8601String().split('T')[0] ?? '-'),
        _buildInfoRow('Korisnik:', widget.job?.user?.firstName ?? '-'),
        _buildInfoRow(
          'Servisi:',
          widget.job?.jobsServices
                  ?.map((e) => e.service?.serviceName)
                  .where((name) => name != null)
                  .join(', ') ??
              'No services',
        ),
        const SizedBox(height: 15),
        if (widget.job?.endEstimate == null && widget.job?.payEstimate == null)
          Column(
            children: [
              FormBuilderDateTimePicker(
                name: "endEstimate",
                inputType: InputType.time,
                decoration: const InputDecoration(
                  labelText: 'Trajanje posla',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
              ),
              const SizedBox(height: 15),
              FormBuilderTextField(
                name: "payEstimate",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Moguća Cijena',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                valueTransformer: (value) => double.tryParse(value ?? ''),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildInfoRow('Kraj:', widget.job?.endEstimate ?? '-'),
              _buildInfoRow('Procjena cijene:', widget.job?.payEstimate?.toString() ?? '-'),
            ],
          ),
        const SizedBox(height: 15),
        if (widget.job?.endEstimate != null && widget.job?.payEstimate != null)
          FormBuilderTextField(
            name: "payInvoice",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Finalna cijena',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            valueTransformer: (value) => double.tryParse(value ?? ''),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          children: [TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.normal))],
        ),
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
  void _showMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

  void _insertJob(Map<String, dynamic> formData) async {
    try {
      jobProvider.insert(formData);
      
      _showMessage('Zahtjev proslijeđen radniku.');
    } on Exception catch (e) {
      _showMessage('Greška u slanju zahtjeva. Molimo pokušajte ponovo.');
    }
  }

  void _confirmJob(Map<String, dynamic> formData) async {
      final payEstimate = formData['payEstimate'] as double?;
                final endEstimate = (formData['endEstimate'] as DateTime?);
                final payInvoice = formData['payInvoice'] as double?;
                
    if (widget.job?.payEstimate!=null && widget.job?.endEstimate!=null) {
  try {
    jobProvider.update(widget.job!.jobId!, {
                 'endEstimate': widget.job?.endEstimate,
                  'payEstimate': widget.job?.payEstimate,
                  'freelancerId': widget.job?.freelancer?.freelancerId,
                  'startEstimate': widget.job?.startEstimate,
                  'userId': widget.job?.user?.userId,
                  'serviceId': widget.job?.jobsServices
                      ?.map((e) => e.service?.serviceId)
                      .toList(),
                  'jobDescription': widget.job?.jobDescription,
                  'image': widget.job?.image,
                  'jobDate': widget.job?.jobDate.toIso8601String(),
                  'payInvoice': payInvoice!=null?payInvoice:null
                });
    _showMessage('Zahtjev odobren i proslijeđen respektivnom korisniku.');
    Navigator.pop(context);
  } on Exception catch (e) {
    _showMessage('Greška u slanju zahtjeva. Molimo pokušajte ponovo.');
  }
}else{
   formData["freelancerId"] =
                      AuthProvider.freelancer?.freelancerId;
                  formData["userId"] = widget.job?.user?.userId;
                  try{
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
                    'jobDate': widget.job?.jobDate.toIso8601String(),
                    'payInvoice': payInvoice
                  });
                  _showMessage('Zahtjev odobren i proslijeđen respektivnom korisniku.');
    Navigator.pop(context);
                  }
                  catch(e){
                    _showMessage('Greška u slanju zahtjeva. Molimo pokušajte ponovo.');
                  }
                  
                  Navigator.pop(context);
                  
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
                
                final job = widget.job;
                final jobId = job?.jobId;
            _formKey.currentState?.saveAndValidate();
           
                debugPrint(_formKey.currentState?.value.toString());
                var formData = Map<String, dynamic>.from(
                    _formKey.currentState?.value ?? {});

                if (formData["startEstimate"] is TimeOfDay) {
                  formData["startEstimate"] =
                      (formData["startEstimate"] as TimeOfDay)
                          .toString().split('TimeOfDay(')[1].split(')')[0];
                          
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

                if (widget.job == null) {
                  formData["freelancerId"] = widget.freelancer?.freelancerId;
                  formData["userId"] = AuthProvider.user?.userId;
                  _insertJob(formData);

                  Navigator.pop(context);
                }

                if (widget.job?.payEstimate != null &&
                    widget.job?.endEstimate != null && jobId !=null) {
                      _confirmJob(formData);
                } else {
                  formData["freelancerId"] =
                      AuthProvider.freelancer?.freelancerId;
                  formData["userId"] = widget.job?.user?.userId;
                  if(jobId!=null){
                _confirmJob(formData);
                }
              }},
              child: const Text("Sačuvaj"))
        ],
      ),
    );
  }
}
