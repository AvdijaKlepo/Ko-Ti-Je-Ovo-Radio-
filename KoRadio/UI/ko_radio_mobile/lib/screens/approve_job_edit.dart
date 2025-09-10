import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class ApproveJobEdit extends StatefulWidget {
  const ApproveJobEdit({ required this.job, super.key});
  final Job job;

  @override
  State<ApproveJobEdit> createState() => _ApproveJobEditState();
}

class _ApproveJobEditState extends State<ApproveJobEdit> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  DateTime? _currentJobDate;
  List<Job>? _currentBookedJobs;
  late Set<int> _workingDayInts;
  final _userId = AuthProvider.user?.userId;
  Uint8List? _decodedImage;
  File? _image;
  String? _base64Image;
  bool multiDateJob=false;

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
        freelancerProvider = context.read<FreelancerProvider>();
  
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
  
      await _getJobs();
         _currentBookedJobs = jobResult?.result;
    });

    _initialValue = {'jobTitle': widget.job.jobTitle, 'jobDate': widget.job.jobDate,
    'jobDescription': widget.job.jobDescription,
    'serviceId': widget.job.jobsServices?.map((e) => e.service?.serviceId).whereType<int>().toList(),
    'image': widget.job.image};
    if(widget.job.image!=null)
    {
      try {
        _decodedImage = base64Decode(widget.job.image!);
      } catch (_) {
        _decodedImage = null;
      }
    }

    _workingDayInts = widget.job.freelancer?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};

    _currentJobDate = widget.job.jobDate;

 

    initForm();
  }

  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
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

  Future<void>_getJobs() async {
    var filter = {
      'FreelancerId': widget.job.freelancer?.freelancerId,
      'DateRange': _currentJobDate,
      'JobStatus': JobStatus.approved.name
    };

    try {
      var job = await jobProvider.get(filter: filter);
      if(!mounted) return;

      setState(() {
        jobResult = job;
      });
    } on Exception catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Greška u dohvaćanju poslova: ${e.toString()}')));
    }
  }

  Future initForm() async {
    jobResult = await jobProvider.get();
    serviceResult = await serviceProvider.get();
    freelancerResult = await freelancerProvider.get();

    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
  final startTimeString = widget.job.freelancer?.startTime ?? "08:00";
    final endTimeString = widget.job.freelancer?.endTime ?? "17:00";

    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final startTime = parseTime(startTimeString);
    final endTime = parseTime(endTimeString);

    return Scaffold(

      appBar: AppBar(scrolledUnderElevation: 0,title:  Text('Rezerviši posao',style: TextStyle(color: Color.fromRGBO(27, 76, 125, 1),fontFamily: GoogleFonts.lobster().fontFamily,letterSpacing: 1.2)),
      centerTitle: true,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: FormBuilder(
            key: _formKey,
            initialValue: _initialValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentBookedJobs != null &&
                    _currentBookedJobs!.isNotEmpty) ...[
                  Text(
                    'Rezervacije za ${widget.job.jobDate?.toIso8601String().split('T')[0]}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  ..._currentBookedJobs!.map(
                    (job) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '  ${job.startEstimate?.substring(0, 5)} - ${job.endEstimate?.substring(0, 5)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const Divider(height: 20),
                ] else
                   SizedBox.shrink(),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: "jobTitle",
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Naslov posla',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: FormBuilderValidators.compose(
                    [
                      FormBuilderValidators.required(errorText: 'Obavezno polje'),
                       (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[A-Z][a-zA-ZčćžšđČĆŽŠĐ\s]+$'); 
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova, prvo velikim';
      }
      return null;
    },
                    ]
                      
                ),
                ),
                const SizedBox(height: 15),
                FormBuilderDateTimePicker(
                  decoration: const InputDecoration(
                    labelText: 'Datum rezervacije',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: FormBuilderValidators.required(
                      errorText: 'Obavezno polje'),
                  name: "jobDate",
                  inputType: InputType.date,
                  firstDate: DateTime.now(),
                  selectableDayPredicate: _isWorkingDay,
                  onChanged: (value) async {
                    setState(() {
                      _currentJobDate = value;
                      _formKey.currentState
                          ?.patchValue({'startEstimate': null});
                    });

                    var filter = {
                      'FreelancerId': widget.job.freelancer?.freelancerId,
                      'DateRange': _currentJobDate,
                      'JobStatus': JobStatus.approved.name
                    };

                    var jobs = await jobProvider.get(filter: filter);

                    setState(() {
                      _currentBookedJobs = jobs.result
                          .where((element) => element.payEstimate != null)
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 15),

                  Checkbox(value: multiDateJob,onChanged: (value){
                setState(() {
                  multiDateJob=value!;
                });
              },),
                const SizedBox(height: 15),
                  if(multiDateJob==true && widget.job.jobStatus==JobStatus.unapproved)
                    FormBuilderDateTimePicker(name: 'dateFinished',
                    locale: Locale('bs'),
                    firstDate: _currentJobDate,
                    initialDate: _currentJobDate,
                    inputType: InputType.date,
            
                    decoration: const InputDecoration(
                      labelText: 'Datum završetka',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    )
                    ),
                const SizedBox(height: 15),

                FormBuilderCustomTimePicker(
                  name: 'startEstimate',
                  minTime: startTime,
                  maxTime: endTime,
                  now: TimeOfDay.now(),
                  jobDate: _currentJobDate,
                  bookedJobs: _currentBookedJobs,
                  validator: FormBuilderValidators.required(
                      errorText: 'Obavezno polje'),
                ),
                const SizedBox(height: 20),
                FormBuilderDateTimePicker(
                      name: "endEstimate",
                      
                     
                      inputType: InputType.time,
                      firstDate: DateTime.now(),
                      currentDate: DateTime.now(),
                      initialDate: DateTime.now(),
                      decoration: const InputDecoration(
                        labelText: 'Vrijeme završetka',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule),
                      ),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  name: "jobDescription",
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Opis problema',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Obavezno polje'),
                    FormBuilderValidators.maxLength(230, errorText: 'Maksimalno 230 znakova'),
                    FormBuilderValidators.minLength(10, errorText: 'Minimalno 10 znakova'),
                    FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][a-zA-ZčćžđšČĆŽŠĐ\s0-9 .,\-\/!]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim, brojevi i osnovni znakovi.'),
                  
                  ]
                   
                ),
                ),
                const SizedBox(height: 15),

                 FormBuilderTextField(
                      name: "payEstimate",
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Moguća Cijena',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                        ]
                      ),
                      valueTransformer: (value) => double.tryParse(value ?? ''),
                    ),
                const SizedBox(height: 15),
                FormBuilderCheckboxGroup<int>(
                  name: "serviceId",
                  decoration: const InputDecoration(
                    labelText: "Servis",
                    border: InputBorder.none,
                  ),
                  validator: FormBuilderValidators.required(
                      errorText: 'Obavezno polje'),
                  options: widget.job.freelancer?.freelancerServices
                          .map(
                            (item) => FormBuilderFieldOption<int>(
                              value: item.service!.serviceId,
                              child: Text(item.service?.serviceName ?? ""),
                            ),
                          )
                          .toList() ??
                      [],
                ),
                const SizedBox(height: 15),
                
         
if(widget.job.image!=null)
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
                : widget.job.image != null
                    ? const Text('Proslijeđena slika')
                    : const Text("Nema proslijeđene slike"),
           
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

                const SizedBox(height: 20),
              ],
            )),
      ),
      bottomNavigationBar: _save(),
    );
  }
    void _showMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _save() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                  textStyle: const TextStyle(color: Colors.white)),
              onPressed: () async {
                final isValid =
                    _formKey.currentState?.saveAndValidate() ?? false;

                if (!isValid) {
                  return;
                }
                

                var values = Map<String, dynamic>.from(
                    _formKey.currentState?.value ?? {});

                if (values["startEstimate"] is TimeOfDay) {
                  values["startEstimate"] =
                      (values["startEstimate"] as TimeOfDay)
                          .toString()
                          .split('TimeOfDay(')[1]
                          .split(')')[0];
                }
                if (values["endEstimate"] is DateTime) {
            final dateTime = values["endEstimate"] as DateTime;
            final formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
            values["endEstimate"] = formattedTime;
          }

                if (values["jobDate"] is DateTime) {
                  values["jobDate"] =
                      (values["jobDate"] as DateTime).toIso8601String().split('T')[0];
                }
                 if (values["dateFinished"] is DateTime) {
                  values["dateFinished"] =
                      (values["dateFinished"] as DateTime).toIso8601String().split('T')[0];
                }


                if (_base64Image != null) {
                  values['image'] = _base64Image;
                }

                var selectedServices = values["serviceId"];
                values["serviceId"] = (selectedServices is List)
                    ? selectedServices
                        .map((id) => int.tryParse(id.toString()) ?? 0)
                        .toList()
                    : (selectedServices != null
                        ? [int.tryParse(selectedServices.toString()) ?? 0]
                        : []);
                
                var jobInsertRequest = {
                  "userId": widget.job.user?.userId,
                  "freelancerId": widget.job.freelancer?.freelancerId,
                  "companyId": null,
                  "jobTitle": values["jobTitle"],
                  "isTenderFinalized": false,
                  "isFreelancer": true,
                  "isInvoiced": false,
                  "isRated": false,
                  "startEstimate": values["startEstimate"],
                  "endEstimate": values["endEstimate"],
           
                  "payEstimate": values["payEstimate"],
                  "payInvoice": null,
                  "jobDate": values["jobDate"],
                  "dateFinished": values["dateFinished"],
                  "jobDescription": values["jobDescription"],
                  "image": widget.job.image,
                  "jobStatus": JobStatus.approved.name,
                  "serviceId": values["serviceId"]
                };


                try{
                await jobProvider.update(widget.job.jobId,jobInsertRequest);
                  _showMessage('Posao prihvaćen');
                }
                catch(e){
                  _showMessage('Greška u slanju zahtjeva. Molimo pokušajte ponovo.');
                }
                
              

                int count = 0;
                if(!mounted) return;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
              child:
                  const Text("Sačuvaj", style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}