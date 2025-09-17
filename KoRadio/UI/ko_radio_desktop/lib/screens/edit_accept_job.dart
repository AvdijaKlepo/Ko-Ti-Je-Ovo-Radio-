import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class EditAcceptJob extends StatefulWidget {
  const EditAcceptJob({super.key , required this.job});
  final Job job;

  @override
  State<EditAcceptJob> createState() => _EditAcceptJobState();
}

class _EditAcceptJobState extends State<EditAcceptJob> {
      final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CompanyEmployeeProvider companyEmployeeProvider;
  late CompanyJobAssignmentProvider companyJobAssignmentProvider;
  SearchResult<CompanyEmployee>? companyEmployeeResult;
  DateTime? _currentJobDate;
  late Set<int> _workingDayInts;
  bool _isLoading = false;
  Uint8List? _decodedImage;

  final _userId = AuthProvider.user?.userId;

  final Map<String, int> _dayStringToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };

  late CompanyProvider companyProvider;
  late JobProvider jobProvider;

  SearchResult<Service>? serviceResult;
  SearchResult<Company>? companyResult;
  SearchResult<CompanyJobAssignment>? companyJobAssignmentResult;



  @override
void initState() {
  super.initState();
  _isLoading = true;
  companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
  companyProvider = context.read<CompanyProvider>();
  jobProvider = context.read<JobProvider>();
  companyJobAssignmentProvider  = context.read<CompanyJobAssignmentProvider>();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _getEmployees();
    await _getAssignments(); 
    var jobStart = parseTime(widget.job.startEstimate!);

    _workingDayInts = widget.job.company?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ?? {};

    _currentJobDate = widget.job.jobDate;
    _initialValue = {
      'jobDate': widget.job.jobDate,
      'jobTitle': widget.job.jobTitle,
      'jobDescription': widget.job.jobDescription,
      'image': widget.job.image,
      'serviceId': widget.job.jobsServices
          ?.map((e) => e.serviceId)
          .whereType<int>()
          .toSet()
          .toList(),

      'startEstimate': jobStart,

   
    };
     if (widget.job?.image != null) {
    try {
      _decodedImage = base64Decode(widget.job!.image!);
    } catch (_) {
      _decodedImage = null;
    }
  }

    setState(() {
      _isLoading = false;
    });
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
  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }
  Future<void> _getEmployees() async {
    try {
      var filter = {'companyId': widget.job.company?.companyId};
      var fetchedCompanyEmployees = await companyEmployeeProvider.get(filter: filter);
      setState(() {
        companyEmployeeResult = fetchedCompanyEmployees;
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  Future<void> _getAssignments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var filter = {'JobId': widget.job.jobId};
      var fetchedCompanyJobAssignments = await companyJobAssignmentProvider.get(filter: filter);
      setState(() {
        companyJobAssignmentResult = fetchedCompanyJobAssignments;
       _isLoading = false;
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
   final filterLoggedInUser = companyEmployeeResult?.result
        .where((element) => element.userId != AuthProvider.user?.userId)
        .toList();
   var jobDate = widget.job.jobDate;
var jobEnd = widget.job.dateFinished;

jobDate = DateTime(jobDate.year, jobDate.month, jobDate.day);

int? jobDifference;
if (jobEnd != null) {
  jobEnd = DateTime(jobEnd.year, jobEnd.month, jobEnd.day);
  jobDifference = jobEnd.difference(jobDate).inDays;
} else {
  jobDifference = null; 
}
if(_isLoading) return const Center(child: CircularProgressIndicator());


  
  return Dialog(
    insetPadding: const EdgeInsets.all(16),
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.95,
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text('Uredi i prihvati',style: const TextStyle(color: Colors.black),),
          
                
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
      
      
       Expanded(
         child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
           
         child: FormBuilder(
           key: _formKey,
           initialValue: _initialValue,
           
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.end,
          
             children: [
             
               const SizedBox(height: 6),
                FormBuilderTextField(
                   validator: FormBuilderValidators.compose([
                     FormBuilderValidators.required(errorText: "Obavezno polje"),
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
                       enabled: false,
                       decoration: const InputDecoration(
                         labelText: 'Naslov posla',
                         border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.description),
                       ),
                    
                     ),  
                     const SizedBox(height: 15,),
                  
                     
                     const SizedBox(height: 15,),
                 FormBuilderDateTimePicker(
                   validator: FormBuilderValidators.required(errorText: "Obavezno polje"),
                       decoration: const InputDecoration(
                         labelText: 'Datum rezervacije',
                         border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.calendar_today),
                       ),
                       name: "jobDate",
               
                       format: DateFormat('dd-MM-yyyy'),
                       inputType: InputType.date,
                       firstDate: DateTime.now(),
                       selectableDayPredicate: _isWorkingDay,
                       onChanged: (value) async {
                         setState(() {
                           _currentJobDate = value;
                         
                          if (jobDifference != null) {
          var newDateFinished = DateTime(
            value!.year,
            value.month,
            value.day + jobDifference,
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
                      
                        
                          
                       }});
               
                        
               
               
                         
                       },
                     ),
                     const SizedBox(height: 15,),
                    
                  
                     const SizedBox(height: 15,),
                     FormBuilderDateTimePicker(name: 'startEstimate',
                     inputType: InputType.time,
                     decoration: const InputDecoration(labelText: 'Početak', border: OutlineInputBorder(), prefixIcon: Icon(Icons.schedule_outlined),
                     ),
                     validator: FormBuilderValidators.compose([
                       FormBuilderValidators.required(errorText: 'Obavezno polje'),
                       
                       

                       
                       
                     ]),
                   ),
                  
                     const SizedBox(height: 15,),

                       if(widget.job.jobStatus==JobStatus.approved)
                 FormBuilderTextField(name: 'rescheduleNote',
                 
                   decoration: const InputDecoration(
               
                     labelText: 'Razlog promjene',
                     
                     
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
                   const SizedBox(height: 15,),
                FormBuilderTextField(
                   validator: FormBuilderValidators.compose([
                     FormBuilderValidators.required(errorText: "Obavezno polje"),
                    (value) {
              if (value == null || value.isEmpty) return null;
               final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ0-9\s]+$');
               
              if (!regex.hasMatch(value)) {
         return 'Dozvoljena su samo slova i brojevi';
              }
              return null;
            },
                   ]),
                       name: "jobDescription",
                       enabled: false,
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
                       enabled: widget.job.jobStatus==JobStatus.unapproved ? true:false,
                       validator: (value) => value == null || value.isEmpty ? "Odaberite barem jednu uslugu" : null,
                       decoration: const InputDecoration(
                         labelText: "Servis",
                         border: InputBorder.none,
               
                       ),
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
                     
                                 
                     const SizedBox(height: 15),
                      if(widget.job.jobStatus==JobStatus.approved)
                       FormBuilderTextField(
                       name: "payEstimate",
                       enabled: false,
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
                     
                    FormBuilderField(
          name: "image",
          enabled: false ,
               
          builder: (field) {
            return InputDecorator(
              decoration:  const InputDecoration(
         enabled: false ,
         labelText: "Proslijedite sliku problema",
         border: OutlineInputBorder(),
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
                 
                 backgroundColor:  Colors.grey,
                 textStyle:   const TextStyle(color: Colors.grey),
               
               
               ),
               icon: const Icon(Icons.file_upload, color: Colors.white),
               label:widget.job.image!= null ? const Text('Promijeni sliku',style: TextStyle(color: Colors.white)): _image==null? const Text("Odaberi", style: TextStyle(color: Colors.white)): const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
               onPressed: () => 
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sliku može promijeniti samo korisnik."))),
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
               const SizedBox(height: 15,),
                   ElevatedButton(onPressed: _save,style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(27, 76, 125, 25),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),child: const Text("Sačuvaj",style: TextStyle(color: Colors.white),),),
             ],
           ),
         ),
              ),
       )
      
        ],
      ),
    ),
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
  Future<void> _save() async {

                
          
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

                if (_base64Image != null) {
                  formData['image'] = _base64Image;
                }
                  if (formData["startEstimate"] is DateTime) {
            final dateTime = formData["startEstimate"] as DateTime;
            final formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
            formData["endEstistartEstimatemate"] = formattedTime;

              
          

             
                var selectedServices = formData["serviceId"];
                formData["serviceId"] = (selectedServices is List)
                    ? selectedServices
                        .map((id) => int.tryParse(id.toString()) ?? 0)
                        .toList()
                    : (selectedServices != null
                        ? [int.tryParse(selectedServices.toString()) ?? 0]
                        : []);
                  var jobInsertRequest = {
                  "userId": widget.job.user?.userId,
            
                  "companyId": widget.job.company?.companyId,
                  "jobTitle": formData["jobTitle"],
             
            
          
           
                  "startEstimate": formattedTime,
            
              
          
                  "jobDate": formData["jobDate"],
                
                  "jobDescription": formData["jobDescription"],
                  "image": formData["image"],
                  "jobStatus": widget.job.jobStatus.name,
                  "serviceId": formData["serviceId"],
                
         
                };

       
              try{
               
                await jobProvider.update(widget.job.jobId,jobInsertRequest);
            
                if(!mounted) return;
                 Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Posao uređen. Završite procjenu.")));
              }
              catch(e){
   

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Greška u slanju zahtjeva. Molimo pokušajte ponovo.")));
              }


       
  }
  }
}