import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/messages_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class EditJob extends StatefulWidget {
  const EditJob({required this.job, super.key});
  final Job job;

  @override
  State<EditJob> createState() => _EditJobState();
}

class _EditJobState extends State<EditJob> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late DateTime? _currentJobDate;
  List<Job>? _currentBookedJobs;
  late Set<int> _workingDayInts;
  bool isLoading = false;
  Uint8List? _decodedImage;
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
  late MessagesProvider messagesProvider;

  SearchResult<Job>? jobResult;
  SearchResult<Service>? serviceResult;
  SearchResult<Freelancer>? freelancerResult;

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  DateTime _parseTimeDate(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(':');
    return DateTime(
        now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
  DateTime _atDate(DateTime day, TimeOfDay t) =>
    DateTime(day.year, day.month, day.day, t.hour, t.minute);

bool _rangeOverlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
  // back-to-back allowed
  return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
}

// booked job strings like "HH:mm" -> DateTimes on selected day
DateTime _parseOn(DateTime day, String hhmm) {
  final p = hhmm.split(':');
  return DateTime(day.year, day.month, day.day, int.parse(p[0]), int.parse(p[1]));
}

bool _overlapsAny(DateTime start, DateTime end) {
  if (_currentBookedJobs == null) return false;
  for (final j in _currentBookedJobs!) {
    final s = j.startEstimate, e = j.endEstimate;
    if (s == null || e == null) continue;
    final bStart = _parseOn(_currentJobDate!, s);
    final bEnd   = _parseOn(_currentJobDate!, e);
    if (_rangeOverlaps(start, end, bStart, bEnd)) return true;
  }
  return false;
}

void patchStartEnd(TimeOfDay? startTod, {required Duration duration}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (startTod == null) {
      _formKey.currentState?.patchValue({'startEstimate': null, 'endEstimate': null});
      return;
    }
    final start = _atDate(_currentJobDate!, startTod);
    final end   = start.add(duration);
    _formKey.currentState?.patchValue({'startEstimate': startTod, 'endEstimate': end});
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



  Map<String, dynamic> _buildInitialValues(Job job) {
    final jobStartTime = _parseTime(job.startEstimate ?? "08:00");
    final endTimeDate = _parseTimeDate(job.endEstimate ?? "17:00");

    return {
      'jobTitle': job.jobTitle,
      'jobDescription': job.jobDescription,
      'image': job.image,
      'serviceId': job.jobsServices
          ?.map((e) => e.serviceId)
          .whereType<int>()
          .toSet()
          .toList(),
      'startEstimate': jobStartTime,
      'endEstimate': endTimeDate,
      'payEstimate': job.payEstimate.toString(),
      'rescheduleNote': job.isEdited == false ? null : job.rescheduleNote,
      'jobDate': job.jobDate,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _currentJobDate = widget.job.jobDate;
    _initialValue = _buildInitialValues(widget.job);

    _workingDayInts = widget.job.freelancer?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};

    jobProvider = context.read<JobProvider>();
    serviceProvider = context.read<ServiceProvider>();
    messagesProvider = context.read<MessagesProvider>(); 
    freelancerProvider = context.read<FreelancerProvider>();
     if (widget.job.image != null) {
    try {
      _decodedImage = base64Decode(widget.job.image!);
    } catch (_) {
      _decodedImage = null;
    }
  }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      await _getJobs(); 
      initForm();
      _currentBookedJobs = jobResult?.result
          .where((element) => element.jobId != widget.job.jobId)
          .toList();
      setState(() {
        isLoading = false;
      });
    });

 
  }

  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }

Future<void> _getJobs() async {
  if (!mounted) return;
  final requested = _currentJobDate;       
  setState(() => isLoading = true);
  try {
    final job = await jobProvider.get(filter: {
      'FreelancerId': widget.job.freelancer?.freelancerId,
      'JobDate': requested,
      'JobStatus': JobStatus.approved.name,
    });
    if (!mounted || requested != _currentJobDate) return; 
    setState(() {
      jobResult = job;
      _currentBookedJobs = jobResult?.result
          .where((e) => e.jobId != widget.job.jobId)
          .toList();
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => isLoading = false);
    _showSnackBar('Greška u dohvaćanju poslova: $e', context);
  }
}



  Future<void> initForm() async {
    try{
      serviceResult = await serviceProvider.get();
    freelancerResult = await freelancerProvider.get();
    
    if (!mounted) return;
    setState(() {});
    }on Exception catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Greška u dohvaćanju poslova: ${e.toString()}')));
    }
    

  }
  void _showSnackBar(String message,context) {
    final snackbar = SnackBar(
  content: Text(message),
  duration: const Duration(seconds: 2),
);
if(!mounted) return;
ScaffoldMessenger.of(context).hideCurrentSnackBar();
ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   // Parse nullable times safely
final jobStartTime = widget.job.startEstimate != null
    ? _parseTime(widget.job.startEstimate!)
    : null;
final jobEndTime = widget.job.endEstimate != null
    ? _parseTimeDate(widget.job.endEstimate!)
    : null;

final freelancerShiftStartTime = widget.job.freelancer?.startTime != null
    ? _parseTime(widget.job.freelancer!.startTime!)
    : null;
final freelancerShiftEndTime = widget.job.freelancer?.endTime != null
    ? _parseTime(widget.job.freelancer!.endTime!)
    : null;

final dummyDate = DateTime.now();
DateTime? originalStart;
DateTime? originalEnd;
Duration? duration;

if (jobStartTime != null && jobEndTime != null) {
  originalStart = DateTime(dummyDate.year, dummyDate.month, dummyDate.day,
      jobStartTime.hour, jobStartTime.minute);
  originalEnd = DateTime(dummyDate.year, dummyDate.month, dummyDate.day,
      jobEndTime.hour, jobEndTime.minute);
  duration = originalEnd.difference(originalStart);
}

    
   

    

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Uredi posao',
          style: TextStyle(
              fontFamily: GoogleFonts.lobster().fontFamily,
              color: const Color.fromRGBO(27, 76, 125, 25),
              letterSpacing: 1.2),
        ),
      ),
      body:  SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: FormBuilder(
            key: _formKey,
            initialValue: _initialValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 isLoading ? const Center(child: LinearProgressIndicator()) :
               
                _currentBookedJobs!=null && _currentBookedJobs!.isNotEmpty ? 
                 Text(
                    'Rezervacije za ${DateFormat('dd-MM-yyyy').format(_currentJobDate ?? DateTime.now())}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ) : const SizedBox.shrink(),
                  
              
                  const SizedBox(height: 6),
                 
                  ...?_currentBookedJobs?.map(
                    (job) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '  ${job.startEstimate?.substring(0, 5)} - ${job.endEstimate?.substring(0, 5)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  
                  
              
                const SizedBox(height: 20),
               
                FormBuilderTextField(
              
                  name: "jobTitle",
                  decoration: const InputDecoration(
                    labelText: 'Naslov posla',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: FormBuilderValidators.compose(
                    [
                      FormBuilderValidators.required(errorText: 'Obavezno polje'),
                       (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ\s]+$'); 
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova';
      }
      return null;
    },
                    ]
                      
                ),
                ),
                const SizedBox(height: 15),
                FormBuilderDateTimePicker(
                  enabled: !isLoading,
                  format: DateFormat('dd-MM-yyyy'),
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
  if (value == null) return;
  setState(() => _currentJobDate = value);

  await _getJobs();           

  if (!mounted) return;

  final formStartTod = _formKey.currentState?.fields['startEstimate']?.value as TimeOfDay?;
  final effectiveStartTod = formStartTod ?? _parseTime(widget.job.startEstimate ?? "08:00");
  final duration = _atDate(DateTime.now(), _parseTime(widget.job.endEstimate ?? "17:00"))
                    .difference(_atDate(DateTime.now(), _parseTime(widget.job.startEstimate ?? "08:00")));

  final start = _atDate(_currentJobDate!, effectiveStartTod);
  final end   = start.add(duration);

  if (_overlapsAny(start, end)) {

    patchStartEnd(null, duration: duration);
    _showSnackBar(
      "Pronađene rezervacije za odabrani datum. Odaberite drugo vrijeme.",
      context,
    );
  } else {

    patchStartEnd(effectiveStartTod, duration: duration);
  }
},


                ),
                const SizedBox(height: 15),
               
                FormBuilderCustomTimePicker(
                  initialValue: jobStartTime,
                  name: 'startEstimate',
                  enabled: !isLoading,
                onChanged: (TimeOfDay? value) {
  if (value == null || _currentJobDate == null || duration == null) return;

  final start = _atDate(_currentJobDate!, value);
  final end = originalEnd != null && originalStart != null
      ? start.add(duration!)
      : null;

  if (freelancerShiftEndTime != null && end != null) {
    final shiftEnd = _atDate(_currentJobDate!, freelancerShiftEndTime);
    if (end.isAfter(shiftEnd)) {
      _showSnackBar('Van okvira radnog vremena.', context);
      patchStartEnd(null, duration: duration);
      return;
    }
  }

  if (end != null && _overlapsAny(start, end)) {
    _showSnackBar('Termin zauzet. Odaberite drugo vrijeme.', context);
    patchStartEnd(null, duration: duration);
    return;
  }

  patchStartEnd(value, duration: duration);
},


                  minTime: freelancerShiftStartTime!,
                  maxTime: freelancerShiftEndTime!,
                  now: TimeOfDay.now(),
                  jobDate: _currentJobDate,
                  bookedJobs: _currentBookedJobs,
                  validator: FormBuilderValidators.required(
                      errorText: 'Obavezno polje'),
                ),
                const SizedBox(height: 15,),
                   if(widget.job.jobStatus == JobStatus.approved)
                    FormBuilderDateTimePicker(
                      name: "endEstimate",
                      enabled: false,
                      
                      inputType: InputType.time,
                      format: DateFormat('HH:mm a'),
                      firstDate: DateTime.now(),
                      currentDate: DateTime.now(),
                      initialDate: DateTime.now(),
                      decoration: const InputDecoration(
                        labelText: 'Trajanje posla',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule),

                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: 'Obavezno polje'),
                       
                      ]),
                      
                    ),
                const SizedBox(height: 15),
                if (widget.job.jobStatus == JobStatus.approved)
                  const SizedBox(
                    height: 15,
                  ),
                FormBuilderTextField(
                  name: "jobDescription",
                  enabled: AuthProvider.user?.freelancer?.freelancerId != null
                      ? false
                      : true,
                  decoration: const InputDecoration(
                    labelText: 'Opis problema',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Obavezno polje'),
                    (value) {
                      if (value == null || value.isEmpty) return null;
                      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ0-9\s.,]+$');

                      if (!regex.hasMatch(value)) {
                        return 'Dozvoljena su samo slova i brojevi';
                      }
                      return null;
                    },
                  ]),
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
                if (widget.job.jobStatus != JobStatus.unapproved)
                  FormBuilderTextField(
                    enabled: false,
                    name: "payEstimate",
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Moguća Cijena',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: 'Obavezno polje'),
                      FormBuilderValidators.numeric(
                          errorText: 'Decimalu diskriminirati sa tačkom'),
                    ]),
                    valueTransformer: (value) => double.tryParse(value ?? ''),
                  ),
                const SizedBox(
                  height: 15,
                ),
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
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image == null && widget.job.image == null
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
                const SizedBox(height: 20),
              ],
            )),
      ),
      bottomNavigationBar: _save(),
    );
  }

  File? _image;
  String? _base64Image;

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

                if (values["jobDate"] is DateTime) {
                  values["jobDate"] = (values["jobDate"] as DateTime)
                      .toIso8601String()
                      .split('T')[0];
                }
                if (widget.job.endEstimate != null &&
                    AuthProvider.user?.freelancer?.freelancerId != null) {
                  final dateTime = values["endEstimate"] as DateTime;
                  final formattedTime =
                      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
                  values["endEstimate"] = formattedTime;
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
                var endEstimateValue = values["endEstimate"];
                String? formattedEndEstimate;

                if (endEstimateValue is DateTime) {
            
                  formattedEndEstimate =
                      "${endEstimateValue.hour.toString().padLeft(2, '0')}:${endEstimateValue.minute.toString().padLeft(2, '0')}:${endEstimateValue.second.toString().padLeft(2, '0')}";
                } else if (endEstimateValue is String) {
           
                  formattedEndEstimate = endEstimateValue;
                }

                if (widget.job.jobStatus == JobStatus.unapproved) {
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
                    "endEstimate": null,
                    "payEstimate": null,
                    "payInvoice": null,
                    "jobDate": values["jobDate"],
                    "dateFinished": null,
                    "jobDescription": values["jobDescription"],
                    "image": values["image"],
                    "jobStatus": JobStatus.unapproved.name,
                    "serviceId": values["serviceId"]
                  };

                  try {
                    await jobProvider.update(
                        widget.job.jobId, jobInsertRequest);
                  
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Posao uređen i radnik obaviješten.')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Greška tokom slanja. Molimo pokušajte ponovo.')));
                  }

                  if (!mounted) return;
                  Navigator.of(context).pop();
                }

                if (widget.job.jobStatus == JobStatus.approved) {
                  var jobInsertRequestEdited = {
                    "userId": widget.job.user?.userId,
                    "freelancerId": widget.job.freelancer?.freelancerId,
                    "companyId": null,
                    "jobTitle": values["jobTitle"],
                    "isTenderFinalized": false,
                    "isFreelancer": true,
                    "isInvoiced": false,
                    "isRated": false,
                    "startEstimate": values["startEstimate"],
                    "endEstimate": formattedEndEstimate,
                    "payEstimate": values["payEstimate"],
                    "payInvoice": null,
                    "jobDate": values["jobDate"].toString(),
                    "dateFinished": null,
                    "jobDescription": values["jobDescription"],
                    "image": values["image"],
                    "jobStatus": JobStatus.approved.name,
                    "serviceId": values["serviceId"],
                    'isEdited':true,
                    'isWorkerEdited':false
                  };
                  try {
                    await jobProvider.update(
                        widget.job.jobId, jobInsertRequestEdited);
                 
                    
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Posao uređen i radnik obaviješten.')));
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Greška tokom slanja. Molimo pokušajte ponovo.')));
                  }
                  if (!mounted) return;
                  Navigator.of(context).pop();
                }
              },
              child:
                  const Text("Sačuvaj", style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }
}
