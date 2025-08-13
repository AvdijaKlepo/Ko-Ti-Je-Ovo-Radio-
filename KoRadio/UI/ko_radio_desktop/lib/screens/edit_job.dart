import 'dart:convert';
import 'dart:io';

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

class EditJob extends StatefulWidget {
  const EditJob({required this.job, super.key});
  final Job job;

  @override
  State<EditJob> createState() => _EditJobState();
}

class _EditJobState extends State<EditJob> {
    final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CompanyEmployeeProvider companyEmployeeProvider;
  late CompanyJobAssignmentProvider companyJobAssignmentProvider;
  SearchResult<CompanyEmployee>? companyEmployeeResult;
  DateTime? _currentJobDate;
  late Set<int> _workingDayInts;
  bool _isLoading = false;

  var _userId = AuthProvider.user?.userId;

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
      'dateFinished': widget.job.dateFinished,
      'payEstimate': widget.job.payEstimate.toString(),
      'companyEmployeeId': companyJobAssignmentResult?.result
          .map((e) => e.companyEmployee?.companyEmployeeId)
          .whereType<int>()
          .toSet()
          .toList(),
    };

    setState(() {
      _isLoading = false;
    });
  });
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
      
      insetPadding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: 
      
      
       SingleChildScrollView(
   
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
  
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text('Rezervacije za ${widget.job.jobDate.toIso8601String().split('T')[0]}'),
              )
          ,
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
                    const ExpansionTile(initiallyExpanded: false,title: Text('Napomena'),
                    children: [
  Text('Datum rezervacije sa firmom ne predstavlja uslov početka rada na isti. U slučaju prihvaćanja zahtjeva, firma će vratiti procjenu roka završetka radova.',
                    style: TextStyle(fontSize: 12),),
                    ]
                  
                    )
                    ,
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
                          print(jobDate);
                          print(jobEnd);
                          print(jobDifference);
                          
                         if (jobDifference != null) {
  var newDateFinished = DateTime(
    value!.year,
    value.month,
    value.day + jobDifference!,
  );

                             if(!_isWorkingDay(newDateFinished))
                          {
                            
                           while (!_isWorkingDay(newDateFinished)) {
                              newDateFinished = newDateFinished.add(Duration(days: 1));
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
                    SizedBox(height: 15,),
                    FormBuilderDateTimePicker(
                    
                      format: DateFormat('dd-MM-yyyy'),
                  validator: FormBuilderValidators.required(errorText: "Obavezno polje"),
                      decoration: const InputDecoration(
                        labelText: 'Kraj radova',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      name: "dateFinished",
                      
                      inputType: InputType.date,
                      firstDate: widget.job.jobDate,
                       initialDate: widget.job.jobDate.isAfter(DateTime.now())
      ? widget.job.jobDate
      : DateTime.now(),
                      selectableDayPredicate: _isWorkingDay,
                     
                    ),
                    SizedBox(height: 15,),
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
      decoration:  InputDecoration(
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
              label:widget.job.image!= null ? Text('Promijeni sliku',style: TextStyle(color: Colors.white)): _image==null? const Text("Odaberi", style: TextStyle(color: Colors.white)): const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () => 
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
SizedBox(height: 15,),
                  ElevatedButton(onPressed: _save,style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(27, 76, 125, 25),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),child: const Text("Sačuvaj",style: TextStyle(color: Colors.white),),),
            ],
          ),
        ),
      ),
      )

      
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
                  "freelancerId": null,
                  "companyId": widget.job.company?.companyId,
                  "jobTitle": formData["jobTitle"],
                  "isTenderFinalized": false,
                  "isFreelancer": false,
                  "isInvoiced": false,
                  "isRated": false,
                  "startEstimate": null,
                  "endEstimate": null,
                  "payEstimate": formData["payEstimate"],
                  "payInvoice": null,
                  "jobDate": formData["jobDate"],
                  "dateFinished": (formData["dateFinished"] as DateTime).toIso8601String(),
                  "jobDescription": formData["jobDescription"],
                  "image": formData["image"],
                  "jobStatus": widget.job.jobStatus.name,
                  "serviceId": formData["serviceId"],
                  "isEdited":true,
                  'rescheduleNote':formData['rescheduleNote']
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
}