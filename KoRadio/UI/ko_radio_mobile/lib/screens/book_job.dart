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
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

class BookJob extends StatefulWidget {
  const BookJob(
      {super.key,
      this.selectedDay,
      this.freelancer,
      this.job,
      this.bookedJobs});
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
  final _userId = AuthProvider.user?.userId;
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

  SearchResult<Job>? jobResult;
  SearchResult<Service>? serviceResult;
  SearchResult<Freelancer>? freelancerResult;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
        initializeDateFormatting('bs', null);
    jobProvider = context.read<JobProvider>();
    serviceProvider = context.read<ServiceProvider>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      freelancerProvider = context.read<FreelancerProvider>();
      jobProvider = context.read<JobProvider>();
      await _getJobs();
    });

    _initialValue = {'jobDate': widget.selectedDay};

    _workingDayInts = widget.freelancer?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};

    _currentJobDate = widget.selectedDay;

    _currentBookedJobs = widget.bookedJobs;

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
      'FreelancerId': widget.freelancer?.freelancerId,
      'JobDate': _currentJobDate,
    };

    try {
      var job = await jobProvider.get(filter: filter);

      setState(() {
        jobResult = job;
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

      appBar: AppBar(scrolledUnderElevation: 0,title:  Text('Rezerviši posao',style: TextStyle(color: const Color.fromRGBO(27, 76, 125, 1),fontFamily: GoogleFonts.lobster().fontFamily,letterSpacing: 1.2)),
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
            (job) => InputChip(
              label: Text(
                '${job.startEstimate?.substring(0, 5)} - ${job.endEstimate?.substring(0, 5)}',
              ),
              disabledColor: Colors.grey.shade200,
              onPressed: null, 
            ),
          ).toList(),
        ),
        const Divider(height: 20),
      ] else
        const SizedBox.shrink(),
              
                 const Text('Posao i servis',style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
                    const SizedBox(height: 15,),
              
               FormBuilderTextField(
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "Obavezno polje"),
                    FormBuilderValidators.maxLength(25,errorText: 'Maksimalno 25 znakova'),
                    FormBuilderValidators.minLength(4,errorText: 'Minimalno 4 znaka'),


                   (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ\s]+$'); 
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova';
      }
      return null;
    },
                  ]),
                      name: "jobTitle",
                      decoration:  InputDecoration(
                        labelText: 'Naslov posla',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.description),
                        filled: true,
                        fillColor: Colors.grey[100],
                        helperText: 'Minimalno 15 znakova'
                      ),
                   
                    ),  
                    const SizedBox(height: 15,),
                      FormBuilderTextField(
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "Obavezno polje"),
                    FormBuilderValidators.maxLength(230,errorText: 'Maksimalno 230 znakova'),
                    FormBuilderValidators.minLength(15,errorText: 'Minimalno 15 znaka'),
                   (value) {
      if (value == null || value.isEmpty) return null;
       final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ0-9\s.,]+$');

      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova i brojevi';
      }
      return null;
    },
                  ]),
                      name: "jobDescription",
                      decoration:  InputDecoration(
                        labelText: 'Opis problema',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.description),
                         filled: true,
                        fillColor: Colors.grey[100],
                        helperText: 'Maksimalno 230 znakova'
                      ),
                      maxLines: 3,
                    ),
                      const SizedBox(height: 15),
                    FormBuilderCheckboxGroup<int>(
                      name: "serviceId",
                      validator: (value) => value == null || value.isEmpty ? "Odaberite barem jednu uslugu" : null,
                      decoration:  InputDecoration(
                        labelText: "Servis",
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[100],
                        

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
                    
                    
                                 const Text('Rezervacija',style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
                    const SizedBox(height: 15),

                FormBuilderDateTimePicker(
                  validator: FormBuilderValidators.required(errorText: "Obavezno polje"),
                  locale: const Locale('bs'),
                      decoration:  const InputDecoration(
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
                         
                        });

                       


                        
                      },
                    ),
                  const SizedBox(height: 15,),
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
                  const SizedBox(height: 15,),
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
                : const Text("Nema izabrane slike"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
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
               
                fit: BoxFit.cover,
              ),
            ),
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

                if (values["jobDate"] is DateTime) {
                  values["jobDate"] =
                      (values["jobDate"] as DateTime).toIso8601String().split('T')[0];
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
                  "userId": _userId,
                  "freelancerId": widget.freelancer?.freelancerId,
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
                  "jobDescription": capitalize( values["jobDescription"]),
                  "image": values["image"],
                  "jobStatus": JobStatus.unapproved.name,
                  "serviceId": values["serviceId"]
                };


                try{
                await jobProvider.insert(jobInsertRequest);
                  _showMessage('Zahtjev proslijeđen radniku.');
                }
                catch(e){
                  _showMessage('Greška u slanju zahtjeva. Molimo pokušajte ponovo.${e.toString()}');
                }
                
              

                int count = 0;
                if(!mounted) return;
                Navigator.of(context).popUntil((_) => count++ >= 4);
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