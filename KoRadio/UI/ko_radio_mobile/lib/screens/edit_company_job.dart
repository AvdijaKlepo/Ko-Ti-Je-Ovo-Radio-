import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/company_job_assignment.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/company_job_assignemnt_provider.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/messages_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

class EditCompanyJob extends StatefulWidget {
  const EditCompanyJob({required this.job, super.key});
  final Job job;

  @override
  State<EditCompanyJob> createState() => _EditCompanyJobState();
}

class _EditCompanyJobState extends State<EditCompanyJob> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  DateTime? _currentJobDate;
  List<CompanyJobAssignment>? _currentBookedJobs;
  List<Job>? _employeeJobs;
  late Set<int> _workingDayInts;
  bool isLoading = false;
  Uint8List? _decodedImage;
  int jobDifference=0;
  final Map<String, int> _dayStringToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };

  late CompanyJobAssignmentProvider companyJobCheck;
  late JobProvider jobProvider;
  late ServiceProvider serviceProvider;
  late CompanyProvider companyProvider;
  late MessagesProvider messagesProvider;

  SearchResult<CompanyJobAssignment>? jobResult;
  SearchResult<Service>? serviceResult;
  SearchResult<Company>? companyResult;
  SearchResult<CompanyJobAssignment>? companyJobResult;

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

  return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
}


DateTime _parseOn(DateTime day, String hhmm) {
  final p = hhmm.split(':');
  return DateTime(day.year, day.month, day.day, int.parse(p[0]), int.parse(p[1]));
}

bool _overlapsAny(DateTime start, DateTime end) {
  if (_currentBookedJobs == null) return false;
  for (final j in _currentBookedJobs!) {
    final s = j.job?.startEstimate, e = j.job?.endEstimate;
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
      'jobDate': job.jobDate,
      'dateFinished': job.dateFinished,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
       initializeDateFormatting('bs', null);
    _currentJobDate = widget.job.jobDate;
    _initialValue = _buildInitialValues(widget.job);

    _workingDayInts = widget.job.company?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
    if(widget.job.dateFinished!=null)
    {
      jobDifference = widget.job.dateFinished!.difference(widget.job.jobDate).inDays;
    }

    companyJobCheck = context.read<CompanyJobAssignmentProvider>();
    jobProvider = context.read<JobProvider>();
    serviceProvider = context.read<ServiceProvider>();
    messagesProvider = context.read<MessagesProvider>(); 
    companyProvider = context.read<CompanyProvider>();
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
      await _getCompanyJobs();
      await _getJobs(); 
    
  
      initForm();
       final assignedEmployeeIds =
      companyJobResult?.result.map((e) => e.companyEmployeeId).toSet() ?? {};
     _currentBookedJobs = jobResult?.result
      .where((element) =>
          element.jobId != widget.job.jobId &&
          assignedEmployeeIds.contains(element.companyEmployeeId))
      .toList();
          _employeeJobs = _currentBookedJobs?.map((e) => e.job!).toList();
      setState(() {
        isLoading = false;
      });
    });

 
  }

  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }

Future<void> _getJobs() async {
  final message = ScaffoldMessenger.of(context);
  if (!mounted) return;
  final requested = _currentJobDate;       
  setState(() => isLoading = true);
  try {
    final job = await companyJobCheck.get(filter: {
     'DateRange': requested,
      'IsFinished': false,
      'IsCancelled': false,
      
    });
    print(requested);
    if (!mounted || requested != _currentJobDate) return; 
    setState(() {
      jobResult = job;
        final assignedEmployeeIds =
      companyJobResult?.result.map((e) => e.companyEmployeeId).toSet() ?? {};
     _currentBookedJobs = jobResult?.result
      .where((element) =>
          element.jobId != widget.job.jobId &&
          assignedEmployeeIds.contains(element.companyEmployeeId))
      .toList();
          _employeeJobs = _currentBookedJobs?.map((e) => e.job!).toList();
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => isLoading = false);
    message.showSnackBar(const SnackBar(content: Text('Greška u prikazivanju termina. Molimo pokušajte ponovo.')));
  }
}

Future<void> _getCompanyJobs() async {
  var filter = {'JobId': widget.job.jobId};
  try {
    var fetchedCompanyJob = await companyJobCheck.get(filter: filter);
    setState(() {
      companyJobResult = fetchedCompanyJob;
  
    });
  } on Exception catch (e) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}



  Future<void> initForm() async {
    try{
      serviceResult = await serviceProvider.get();
    companyResult = await companyProvider.get();
    
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
  final jobStartTime = widget.job.startEstimate != null
    ? _parseTime(widget.job.startEstimate!)
    : null;
final jobEndTime = widget.job.endEstimate != null
    ? _parseTimeDate(widget.job.endEstimate!)
    : null;

final freelancerShiftStartTime = widget.job.company?.startTime != null
    ? _parseTime(widget.job.company!.startTime!)
    : null;
final freelancerShiftEndTime = widget.job.company?.endTime != null
    ? _parseTime(widget.job.company!.endTime!)
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
          
                 if (_currentBookedJobs != null && _currentBookedJobs!.isNotEmpty) ...[
        Text(
          'Rezervacije za ${DateFormat.yMMMMd('bs').format(_currentJobDate!)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
               Wrap(
          spacing: 6,
          runSpacing: -8,
          children: _currentBookedJobs!.map(
            (job) {
              final startRaw = job.job?.startEstimate ?? '';
              final endRaw = job.job?.endEstimate ?? '';
              final start = startRaw.length >= 5 ? startRaw.substring(0, 5) : startRaw;
              final end = endRaw.length >= 5 ? endRaw.substring(0, 5) : endRaw;

              final firstName = job.companyEmployee?.user?.firstName ?? '';
              final lastName = job.companyEmployee?.user?.lastName ?? '';
              final employeeDisplay = (firstName + (lastName.isNotEmpty ? ' $lastName' : '')).trim();
              final initials = (firstName.isNotEmpty ? firstName[0] : '') +
                  (lastName.isNotEmpty ? lastName[0] : '');

              final chipLabel = employeeDisplay.isNotEmpty
                  ? '$employeeDisplay — $start - $end'
                  : '$start - $end';

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Tooltip(
                          
                  message: chipLabel,
                  child: InputChip(
                  
                    avatar: CircleAvatar(
                      child: Text(
                        initials.toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    label: Text(chipLabel),
                    disabledColor: Colors.grey.shade200,
                    onPressed: null,
                  ),
                ),
              );
            },
          ).toList(),
        ),
        

        const Divider(height: 20),
      ] else
        const SizedBox.shrink(),
                  
                  
              
            const Text('Posao i servis',style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
                    const SizedBox(height: 15,),
               
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
           
                const SizedBox(height: 15,),
               
                FormBuilderTextField(
                  name: "jobDescription",
                  enabled:true,
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
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(
                      errorText: 'Obavezno polje'),
                  options: widget.job.company?.companyServices
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

               
                    
            const Text('Rezervacija',style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
                    const SizedBox(height: 15,),
               
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
                  final message = ScaffoldMessenger.of(context);
  
                  
  if (value == null) return;
  setState(() {
    _currentJobDate = value;
      if (jobDifference != null) {
  var newDateFinished = DateTime(
    value!.year,
    value.month,
    value.day + jobDifference!,
  );

                             if(!_isWorkingDay(newDateFinished))
                          {
                            
                           while (!_isWorkingDay(newDateFinished)) {
                              newDateFinished = newDateFinished.add(const Duration(days: 1));
                            }
                            _formKey.currentState?.patchValue({
                              'dateFinished': newDateFinished,
                            });
                          }
                          else{
                          _formKey.currentState?.patchValue({
                            'dateFinished': newDateFinished,
                          });
                          }
                     
                       
                         
                      }
  
  });

  await _getJobs();           

  //_formKey.currentState?.patchValue({'dateFinished': _currentJobDate?.add(Duration(days: jobDifference))});
    
                



  final formStartTod = _formKey.currentState?.fields['startEstimate']?.value as TimeOfDay?;
  final effectiveStartTod = formStartTod ?? _parseTime(widget.job.startEstimate ?? "08:00");
  final duration = _atDate(DateTime.now(), _parseTime(widget.job.endEstimate ?? "17:00"))
                    .difference(_atDate(DateTime.now(), _parseTime(widget.job.startEstimate ?? "08:00")));

  final start = _atDate(_currentJobDate!, effectiveStartTod);
  final end   = start.add(duration);

  if (_overlapsAny(start, end)) {

    patchStartEnd(null, duration: duration);
    message.showSnackBar(const SnackBar(content: Text('Pronađene rezervacije za odabrani datum. Odaberite drugo vrijeme.')));
  } else {

    patchStartEnd(effectiveStartTod, duration: duration);
  }
},


                ),
                const SizedBox(height: 15),
                if(widget.job.dateFinished!=null)
                FormBuilderDateTimePicker(name: 'dateFinished',
                 format: DateFormat('dd-MM-yyyy'),
                 enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Datum završetka',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
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
                  bookedJobs: _employeeJobs,
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
                        prefixIcon: Icon(Icons.schedule_outlined),

                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: 'Obavezno polje'),
                       
                      ]),
                      
                    ),
                  if(widget.job.jobStatus==JobStatus.approved)
            const Text('Procijena',style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
                    const SizedBox(height: 15,),
               
              
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
              
                 const Text('Slika',style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
                    const SizedBox(height: 15,),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(27, 76, 125, 25),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
              onPressed: () async {
                
                
          
           final isValid = _formKey.currentState?.saveAndValidate() ?? false;

  if (!isValid) {
  
    return;
  }
           
            
                var formData = Map<String, dynamic>.from(
                    _formKey.currentState?.value ?? {});

    

                if (formData["jobDate"] is DateTime) {
                  formData["jobDate"] =
                      (formData["jobDate"] as DateTime).toIso8601String();
                }
                   if (formData["startEstimate"] is TimeOfDay) {
                  formData["startEstimate"] =
                      (formData["startEstimate"] as TimeOfDay)
                          .toString()
                          .split('TimeOfDay(')[1]
                          .split(')')[0];
                }
                 
                 if (formData["dateFinished"] is DateTime && widget.job.dateFinished!=null) {
                  formData["dateFinished"] = (formData["dateFinished"] as DateTime)
                      .toIso8601String()
                      .split('T')[0];
                }
                 if (widget.job.endEstimate != null &&
                    AuthProvider.user?.freelancer?.freelancerId != null) {
                  final dateTime = formData["endEstimate"] as DateTime;
                  final formattedTime =
                      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
                  formData["endEstimate"] = formattedTime;
                }

                if (_base64Image != null) {
                  formData['image'] = _base64Image;
                }
              
          

             
                var selectedServices = formData["serviceId"];
                formData["serviceId"] = (selectedServices is List)
                    ? selectedServices
                        .map((id) => int.tryParse(id.toString()) ?? 0)
                        .toList()
                    : (selectedServices != null
                        ? [int.tryParse(selectedServices.toString()) ?? 0]
                        : []);
                        if (widget.job.jobStatus == JobStatus.unapproved) {
                  var jobInsertRequest = {
                  "userId": widget.job.user?.userId,
                  "freelancerId": null,
                  "companyId": widget.job.company?.companyId,
                  "jobTitle": formData["jobTitle"],
                  "isTenderFinalized": false,
                  "isFreelancer": false,
                  "isInvoiced": false,
                  "isRated": false,
                  "startEstimate": formData["startEstimate"],
                  "endEstimate":null,
                  "payEstimate": null,
                  "payInvoice": null,
                  "jobDate": formData["jobDate"],
                  "dateFinished": null,
             
                  "jobDescription": formData["jobDescription"],
                  "image": formData["image"],
                  "jobStatus": widget.job.jobStatus.name,
                  "serviceId": formData["serviceId"]
                };

       
              try{
               
                await jobProvider.update(widget.job.jobId,jobInsertRequest);
               
            
                if(!mounted) return;
                 Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Zahtjev proslijeđen firmi!")));
              }
              catch(e){
                print(e);

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Greška u slanju zahtjeva. Molimo pokušajte ponovo.")));
              }
                        }
              if (widget.job.jobStatus == JobStatus.approved) {
var jobInsertRequestApproved = {
                  "userId": widget.job.user?.userId,
                  "freelancerId": null,
                  "companyId": widget.job.company?.companyId,
                  "jobTitle": formData["jobTitle"],
                  "isTenderFinalized": false,
                  "isFreelancer": false,
                  "isInvoiced": false,
                  "isRated": false,
                  "startEstimate": formData["startEstimate"],
                  "endEstimate": formData["endEstimate"],
                  "payEstimate": formData["payEstimate"],
                  "payInvoice": null,
                  "jobDate": formData["jobDate"],
                  "dateFinished": widget.job.dateFinished!= null ? formData["dateFinished"] : null,
                  "jobDescription": formData["jobDescription"],
                  "image": formData["image"],
                  "jobStatus": widget.job.jobStatus.name,
                  "serviceId": formData["serviceId"],
                  'isEdited':true,
                  'isWorkerEdited':false
                };

       
              try{
               
                await jobProvider.update(widget.job.jobId,jobInsertRequestApproved);
               
            
                if(!mounted) return;
                 Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Zahtjev proslijeđen firmi!")));
              }
              catch(e){
                print(e);

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Greška u slanju zahtjeva. Molimo pokušajte ponovo.")));
              }
              }



           },
              child: const Text("Sačuvaj",style: TextStyle(color: Colors.white),))
        ],
      ),
    );
  }
}