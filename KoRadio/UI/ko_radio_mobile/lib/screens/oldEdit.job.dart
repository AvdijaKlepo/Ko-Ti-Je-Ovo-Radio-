import 'dart:convert';
import 'dart:io';

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
  const EditJob({ required this.job, super.key});
  final Job job;

  @override
  State<EditJob> createState() => _EditJobState();
}

class _EditJobState extends State<EditJob> {

  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late DateTime? _currentJobDate = widget.job.jobDate;
  List<Job>? _currentBookedJobs;
  late Set<int> _workingDayInts;
  final _userId = AuthProvider.user?.userId;
  bool isLoading = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() { 
    jobProvider = context.read<JobProvider>();
    serviceProvider = context.read<ServiceProvider>();
    messagesProvider = context.read<MessagesProvider>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      freelancerProvider = context.read<FreelancerProvider>();
      jobProvider = context.read<JobProvider>();
      setState(() {
        isLoading=true;
      });
      await _getJobs();
      _currentBookedJobs = jobResult?.result.where((element) => element.jobId!=widget.job.jobId).toList();
      setState(() {
        isLoading=false;
      });
    
    });
     final startTimeString = widget.job.startEstimate ?? "08:00";
    final endTimeString = widget.job.freelancer?.endTime ?? "17:00";

    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final jobStartTime = parseTime(startTimeString);
    final endTime = parseTime(endTimeString);
    final endTimeStringDate = widget.job.endEstimate ?? "17:00";


    DateTime parseTimeDate(String timeStr) {
      final parts = timeStr.split(':');
      return DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

 
    final endTimeDate = parseTimeDate(endTimeStringDate);


    _initialValue = {
      'jobTitle': widget.job.jobTitle,
      'jobDescription': widget.job.jobDescription,
      'image': widget.job.image,
      'serviceId': widget.job.jobsServices?.
       map((e) => e.serviceId)
    .whereType<int>()
    .toSet()
    .toList(),
      'startEstimate': jobStartTime,
      'endEstimate': endTimeDate,
      'payEstimate': widget.job.payEstimate.toString(),
      'rescheduleNote':
      widget.job.isEdited==false ? null :
       widget.job.rescheduleNote,
      
      'jobDate': widget.job.jobDate};

    _workingDayInts = widget.job.freelancer?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};




    initForm();
  }

  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }

  _getJobs() async {
    setState(() {
      isLoading=true;
    });
    var filter = {
      'FreelancerId': widget.job.freelancer?.freelancerId,
      'JobDate': _currentJobDate,
      'JobStatus': JobStatus.approved.name,
    };

    try {
      var job = await jobProvider.get(filter: filter);

      setState(() {
        jobResult = job;
        isLoading=false;
      });
    } on Exception catch (e) {
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

  void _showSnackBar(String message,context) {
    final snackbar = SnackBar(
  content: Text(message),
  duration: Duration(seconds: 2),
);
if(!mounted) return;
ScaffoldMessenger.of(context).hideCurrentSnackBar();
ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
  @override
  Widget build(BuildContext context) {
    final jobStartTimeString = widget.job.startEstimate ?? "08:00";
    final jobEndTimeString = widget.job.endEstimate ?? "17:00";
  
TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    

    final jobStartTime = parseTime(jobStartTimeString);
     final startTimeString = widget.job.freelancer?.startTime ?? "08:00";
    final endTimeString = widget.job.freelancer?.endTime ?? "17:00";

    

    final startTime = parseTime(startTimeString);
    final endTime = parseTime(endTimeString);

     bool outOfWorkHours = false;
    
    String? selectedJobTime = widget.job.startEstimate;

    final jobStartEstimate = parseTime(widget.job.startEstimate ?? '');

    final jobEndEstimate = parseTime(widget.job.endEstimate ?? "08:00");


final dummyDate = DateTime.now(); 

final originalStart = DateTime(dummyDate.year, dummyDate.month, dummyDate.day,
    jobStartEstimate.hour, jobStartEstimate.minute);
final originalEnd = DateTime(dummyDate.year, dummyDate.month, dummyDate.day,
    jobEndEstimate.hour, jobEndEstimate.minute);

final duration = originalEnd.difference(originalStart);

    final parts = selectedJobTime!.split(":");
final parsedTime = DateTime(
  DateTime.now().year,
  DateTime.now().month,
  DateTime.now().day,

  int.parse(parts[0]),
  int.parse(parts[1]),
);
DateTime normalizeTime(DateTime t) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, t.hour, t.minute, t.second);
}

 final startTimeStringDate = widget.job.freelancer?.startTime ?? "08:00";
 final endTimeStringDate = widget.job.freelancer?.endTime ?? "17:00";

    DateTime parseTimeDate(String timeStr) {
      final parts = timeStr.split(':');
      return DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    final startTimeDate = parseTimeDate(startTimeStringDate);
    final endTimeDate = parseTimeDate(endTimeStringDate);
    final jobEndTimeDate = parseTimeDate(jobEndTimeString);
    
    bool shiftCheck = false;
    if(jobEndTimeDate.isAfter(endTimeDate)){
      shiftCheck = true;
    }
    bool isOverlapping(DateTime start) {
      if (_currentBookedJobs == null) return false;

      for (final job in _currentBookedJobs!) {
        if (job.startEstimate != null && job.endEstimate != null) {
          final bookedStart = parseTimeDate(job.startEstimate!);
          final bookedEnd = parseTimeDate(job.endEstimate!);

          if (start.isAtSameMomentAs(bookedStart) ||
              (start.isAfter(bookedStart) && start.isBefore(bookedEnd))) {
            return true;
          }
        }
      }
      return false;
    }
   

    
    

    return  Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('Šta ćemo ljudino?',style:TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: const Color.fromRGBO(27, 76, 125, 25),letterSpacing: 1.2),),
      ),
      body: SingleChildScrollView(
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
                  ) : SizedBox.shrink(),
                  
              
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
  setState(() {
    _currentJobDate = value;
  });

  await _getJobs();

  if (!mounted) return;

  setState(() {
    _currentBookedJobs = jobResult?.result
        .where((e) => e.jobId != widget.job.jobId)
        .toList();


   


    final startCandidate = DateTime(
      dummyDate.year,
      dummyDate.month,
      dummyDate.day,
      jobStartEstimate.hour,
      jobStartEstimate.minute,
    );

    if (_currentBookedJobs?.isNotEmpty == true &&
        isOverlapping(startCandidate)) {
      _formKey.currentState?.patchValue({
        'startEstimate': null,
        'endEstimate': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pronađeni već rezervisani termini za odabrani datum. "
            "Rezervišite vrijeme respektivno prema njima.",
          ),
          duration: Duration(seconds: 3),
        ),
        
      );
    
    } else if (_currentBookedJobs?.isEmpty == true) {
      _formKey.currentState?.patchValue({'startEstimate': jobStartEstimate});
    }
  });
},

                ),
                const SizedBox(height: 15),
               
                FormBuilderCustomTimePicker(
                  initialValue: jobStartTime,
                  name: 'startEstimate',
                 onChanged: (TimeOfDay? value) {
  if (value == null) return;

  final newStart = DateTime(
    dummyDate.year,
    dummyDate.month,
    dummyDate.day,
    value.hour,
    value.minute,
  );

  final newEnd = newStart.add(duration);

  // if job goes beyond worker's working hours
  if (newEnd.isAfter(endTimeDate)) {
    _showSnackBar(
      'Trajanje posla van okvira radnikovog radnog vremena.',
      context,
    );

    // 👇 Only reset if it's not already correct
    final currentStart = _formKey.currentState?.fields['startEstimate']?.value;
    if (currentStart != jobStartTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue({
          'startEstimate': jobStartTime,
          'endEstimate': jobEndTimeDate,
        });
      });
    }
    return;
  }

  // if newEnd overlaps with a booked job
  if (_currentBookedJobs?.isNotEmpty == true && isOverlapping(newEnd.add(const Duration(minutes: 5)))) {
    _showSnackBar(
      'Termin zauzet. Referencirajte se prema terminima iznad.',
      context,
    );

    // 👇 Defer patching to next frame to avoid recursion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.patchValue({
        'startEstimate': jobStartTime,
        'endEstimate': jobEndTimeDate,
      }); 
      
    });
   
    return;
  }

  // otherwise update endEstimate normally
  _formKey.currentState?.patchValue({
    'endEstimate': newEnd,
  });
},

                  minTime: startTime,
                  maxTime: endTime,
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
                        (value) {
                         
                        }
                      ]),
                      onChanged: (value) {
    if (value == null) return;

    final selected = normalizeTime(value);
    final maxTime = normalizeTime(endTimeDate);
     DateTime threshold = normalizeTime(parsedTime);
    
    

    if (selected.isAfter(maxTime)) {

      
 

     

      
    }}
                    ),
                const SizedBox(height: 15),
                if(widget.job.jobStatus==JobStatus.approved)
               
                const SizedBox(height: 15,),
                FormBuilderTextField(
                  name: "jobDescription",
                   enabled: AuthProvider.selectedRole=="Freelancer" ? false:true ,
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
                  ]
                   
                ),
                ),
                const SizedBox(height: 15),
                FormBuilderCheckboxGroup<int>(
                  enabled: AuthProvider.selectedRole=="Freelancer" ? false:true ,
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
                if(widget.job.jobStatus!=JobStatus.unapproved)
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
                      validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                        ]
                      ),
                      valueTransformer: (value) => double.tryParse(value ?? ''),
                    ),
                    const SizedBox(height: 15,),
               
             

FormBuilderField(
  name: "image",
  enabled: AuthProvider.selectedRole=="Freelancer" ? false:true ,

  builder: (field) {
    return InputDecorator(
      decoration:  InputDecoration(
        enabled: AuthProvider.selectedRole=="Freelancer" ? false:true ,
        labelText: "Proslijedite sliku problema",
        border: const OutlineInputBorder(),
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
                :  widget.job.image!= null ?
            const Text('Proslijeđena slika') :
                
                 const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(

              style: ElevatedButton.styleFrom(
                
                backgroundColor: AuthProvider.selectedRole=="User" ? const Color.fromRGBO(27, 76, 125, 1) : Colors.grey,
                textStyle:  AuthProvider.selectedRole=="User" ? const TextStyle(color: Colors.white) : const TextStyle(color: Colors.grey),


              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label:widget.job.image!= null ? const Text('Promijeni sliku',style: TextStyle(color: Colors.white)): _image==null? const Text("Odaberi", style: TextStyle(color: Colors.white)): const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () => AuthProvider.selectedRole=="User" ? getImage(field) : 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sliku može promijeniti samo korisnik."))),
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
            ) :
            widget.job.image!=null ?
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child : imageFromString(widget.job.image ?? '',
              fit: BoxFit.cover
              ),
            ) : const SizedBox.shrink()
           
            ,
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
                  values["jobDate"] =
                      (values["jobDate"] as DateTime).toIso8601String().split('T')[0];
                }
                if(widget.job.endEstimate!=null && AuthProvider.user?.freelancer?.freelancerId!=null){
                    final dateTime = values["endEstimate"] as DateTime;
            final formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
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
                
            
               




                

                if(widget.job.jobStatus==JobStatus.unapproved){
                      var jobInsertRequest = {
                  "userId": widget.job.user?.userId,
                  "freelancerId": widget.job.freelancer?.freelancerId,
                  "companyId": widget.job.company?.companyId,
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
                
                try{
                await jobProvider.update(widget.job.jobId,jobInsertRequest);
                await messagesProvider.insert({
                    'message1': "Posao ${widget.job.jobTitle} je uređen od strane korisnika",
                    'userId': widget.job.freelancer?.freelancerId,
                    'createdAt': DateTime.now().toIso8601String(),
                    'isOpened': false,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posao uređen i radnik obaviješten.')));
                }
                catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška tokom slanja: ${e.toString()}')));
                }
                
              

                
                if(!mounted) return;
                Navigator.of(context).pop();
              }
              var end = DateTime.parse(values["endEstimate"] as String).toIso8601String().split('T')[1];
            
              if(widget.job.jobStatus==JobStatus.approved)
              { var jobInsertRequestEdited = {
                  "userId": widget.job.user?.userId,
                  "freelancerId": widget.job.freelancer?.freelancerId,
                  "companyId": widget.job.company?.companyId,
                  "jobTitle": values["jobTitle"],
                  "isTenderFinalized": false,
                  "isFreelancer": true,
                  "isInvoiced": false,
                  "isRated": false,
                  "startEstimate": values["startEstimate"],
                  "endEstimate":end,
                  "payEstimate":values["payEstimate"],
                  "payInvoice": null,
                  "jobDate": values["jobDate"].toString(),
                  "dateFinished": null,
                  "jobDescription": values["jobDescription"],
                  "image": values["image"],
                  "jobStatus": JobStatus.approved.name,
                  "serviceId": values["serviceId"]
               
            
                 
                };
                try{
                   
              
                await jobProvider.update(widget.job.jobId,jobInsertRequestEdited);
                print(jobInsertRequestEdited);
                await messagesProvider.insert({
                    'message1': "Posao ${widget.job.jobTitle} je uređen od strane korisnika",
                    'userId': widget.job.freelancer?.freelancerId,
                    'createdAt': DateTime.now().toIso8601String(),
                    'isOpened': false,
                  });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posao uređen i radnik obaviješten.')));
                Navigator.pop(context,true);
              }
              catch(e){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška tokom slanja: ${e.toString()}')));
              }
               if(!mounted) return;
                Navigator.of(context).pop();
              
              }
              }
              
              
              ,
              child:
                  const Text("Sačuvaj", style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

}