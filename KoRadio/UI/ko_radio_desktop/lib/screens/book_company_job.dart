import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:provider/provider.dart';

class BookCompanyJob extends StatefulWidget {
  const BookCompanyJob(this.job,{super.key});
  final Job job;


  @override
  State<BookCompanyJob> createState() => _BookCompanyJobState();
}

class _BookCompanyJobState extends State<BookCompanyJob> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formKeyEmployee = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};


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

  late CompanyProvider companyProvider;
  late JobProvider jobProvider;
  late CompanyEmployeeProvider companyEmployeeProvider;
  late CompanyJobAssignmentProvider companyJobAssignmentProvider;
  SearchResult<Service>? serviceResult;
  SearchResult<Company>? companyResult;
  SearchResult<CompanyEmployee>? companyEmployeeResult;
  SearchResult<CompanyJobAssignment>? companyJobAssignmentResult;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      companyProvider = context.read<CompanyProvider>();
      jobProvider = context.read<JobProvider>();
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
      companyJobAssignmentProvider = context.read<CompanyJobAssignmentProvider>();
     await _getEmployees();
     await _getAssignments();
    
    });
 
   _workingDayInts = widget.job.company?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
    _initialValue = {
  
    };
  }
  Future<void> _getAssignments() async {
    try {
      var filter = {'JobId': widget.job.jobId};
      var fetchedCompanyJobAssignments = await companyJobAssignmentProvider.get(filter: filter);
      setState(() {
        companyJobAssignmentResult = fetchedCompanyJobAssignments;
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
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
  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }
  @override
  Widget build(BuildContext context) {
   final filterLoggedInUser = companyEmployeeResult?.result
        .where((element) => element.userId != AuthProvider.user?.userId)
        .toList();

    return  Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 500,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: SvgPicture.asset(
                    'assets/images/undraw_data-input_whqw.svg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
             
                  
                  child: FormBuilder(
                    key: _formKey,
                    initialValue: _initialValue,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       
                       _sectionTitle('Radne specifikacije'),
                  _buildDetailRow('Posao', widget.job.jobTitle?? 'Nije dostupan'), 
                  _buildDetailRow('Servis', widget.job.jobsServices
                          ?.map((e) => e.service?.serviceName)
                          .where((e) => e != null)
                          .join(', ') ??
                      'N/A'),
                  _buildDetailRow('Datum', DateFormat('dd-MM-yyyy').format(widget.job.jobDate)),
                 
                  _buildDetailRow('Opis posla', widget.job.jobDescription),
                    _buildDetailRow('Datum završetka', widget.job.dateFinished!=null ? DateFormat('dd-MM-yyyy').format(widget.job.dateFinished ?? DateTime.now()) : 'Nije dostupan'),
                      _buildDetailRow('Radnici', companyJobAssignmentResult?.result.map((e) => e.companyEmployee?.user?.firstName ?? 'Nepoznato').toList().join(', ') ?? 'Nema zaposlenika'),

                  const Divider(height: 32),
                  _sectionTitle('Korisnički podaci'),
                  _buildDetailRow(
                    'Ime i prezime',
                    widget.job.user != null
                        ? '${widget.job.user?.firstName ?? ''} ${widget.job.user?.lastName ?? ''}'
                        : 'Nepoznato',
                  ),
                  _buildDetailRow(
                    'Adresa',
                    widget.job.user != null
                        ? '${widget.job.user?.address}'
                        : 'Nepoznato',
                  ),

                  const Divider(height: 32),
                 _sectionTitle('Podaci Firme'),
                 _buildDetailRow('Naziv Firme', widget.job.company?.companyName ?? 'Nepoznato'),
               
                  _buildDetailRow('E-mail', widget.job.company?.email ?? 'Nepoznato'),
           
                   _buildDetailRow('Telefonski broj', widget.job.company?.phoneNumber ?? 'Nepoznato'),

                 
                  const Divider(height: 32),
                   _sectionTitle('Račun'),
                  _buildDetailRow('Procijena',
                      widget.job.payEstimate?.toStringAsFixed(2) ?? 'Nije unesena'),
                  _buildDetailRow('Konačna cijena',
                      widget.job.payInvoice?.toStringAsFixed(2) ?? 'Nije unesena'),
                      widget.job.isInvoiced==true ?
                  _buildDetailRow('Plaćen',
                      'Da'): _buildDetailRow('Plaćen',
                      'Ne'),
                      
                     if(widget.job.jobStatus== JobStatus.cancelled) 
                       _buildDetailRow('Otkazan',
                      'Da'), 
const Divider(height: 32),
                      if(widget.job.jobStatus == JobStatus.unapproved)
_sectionTitle('Potrebni podaci'),
                   if(widget.job.jobStatus == JobStatus.unapproved)
                Column(
                  children: [
                    FormBuilderDateTimePicker(
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
                  

                  ],
                ),
                if (widget.job.jobStatus == JobStatus.approved)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      FormBuilderTextField(
                        name: "payInvoice",
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Finalna cijena',
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
                        
      
                     
                     
                      ],
                    ),
                      if(companyJobAssignmentResult?.count==0 || widget.job.jobStatus== JobStatus.unapproved) 
                   FormBuilder(key: _formKeyEmployee,child:   Column(
                      children: [
                          FormBuilderCheckboxGroup<int>(
                      validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                     
  name: 'companyEmployeeId',
  decoration: const InputDecoration(labelText: "Zaduženi radnici"),
  options: filterLoggedInUser!=null ? filterLoggedInUser
          .map((e) => FormBuilderFieldOption(
                value: e.companyEmployeeId,
                child: Text('${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}'),
              ))
          .toList() : 
          [],
      

     
),
TextButton.icon(
                              icon: const Icon(Icons.check, color: Colors.blue),
                              label: const Text("Dodaj radnike na posao", style: TextStyle(color: Colors.black)),
                              onPressed: () async {
                                  final isValid =
                        _formKey.currentState?.saveAndValidate() ?? false;

                                  if (!isValid) {
                                    return;
                                  }
          
                   
                    var values = Map<String, dynamic>.from(
                        _formKey.currentState?.value ?? {});
 try {
  final selectedEmployeeIds = values["companyEmployeeId"] as List<dynamic>?;

  if (selectedEmployeeIds != null && selectedEmployeeIds.isNotEmpty) {
    for (final employeeId in selectedEmployeeIds) {
      await companyJobAssignmentProvider.insert({
        "jobId": widget.job.jobId,
        "companyEmployeeId": employeeId,
        "assignedAt":DateTime.now().toIso8601String(),
      });
    }
  }

  if (context.mounted) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Zaposlenici uspješno dodani.")),
    );
  }
} catch (e) {
  if(!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Greška tokom dodavanja radnika: $e")),
  );
}
                              })
                            
                      ],
                    ),),
                  
                    const SizedBox(height: 30),
                    if(widget.job.jobStatus!= JobStatus.cancelled && widget.job.jobStatus!= JobStatus.finished)
                       Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              label: const Text("Otkazi", style: TextStyle(color: Colors.red)),
                              onPressed: () =>showDialog(context: context, builder: (context) => _openCancelDialog())
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle),
                              label: const Text("Odobri"),
                              onPressed: () => _submit(JobStatus.approved),
                            ),
                          ],
                        )
                      ]
                  ),
                ),
              ),
              )
            ],
          ),
        ),
      );
    
  }
  _openCancelDialog() {
    return AlertDialog(
      backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
      title: const Text('Odbaci posao',style: TextStyle(color: Colors.white),),
      content: const Text('Jeste li sigurni da želite da otkažete ili odbijete ovaj posao?',style: TextStyle(color: Colors.white),),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),)),
            TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () async {
                var jobUpdateRequest = {
                "userId": widget.job.user?.userId,
                "freelancerId": null,
                "companyId": widget.job.company?.companyId,
                "jobTitle": widget.job.jobTitle,
                "isTenderFinalized": false,
                "isFreelancer": false,
                "isInvoiced": false,
                "isRated": false,
                "startEstimate": null,
                "endEstimate": null,  
                "payEstimate": null,
                "payInvoice": null,
                "jobDate": widget.job.jobDate.toIso8601String(),
                "dateFinished": widget.job.dateFinished?.toIso8601String(),
                "jobDescription": widget.job.jobDescription,
                "image": widget.job.image,
                "jobStatus": JobStatus.cancelled.name,
                "serviceId": widget.job.jobsServices
                        ?.map((e) => e.service?.serviceId)
                        .toList(),
          };
              try {
            jobProvider.update(widget.job.jobId,
            jobUpdateRequest
            );
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posao odbijen.')));
               int count = 0;
            Navigator.of(context).popUntil((_) => count++ >= 2);
          } on Exception catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška tokom slanja: ${e.toString()}')));
               int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);

          }
            },
            child: const Text("Odbaci",style: TextStyle(color: Colors.white),),
            ),
      ],
    );
  }
  

 Future<void> _submit(JobStatus status) async {
     final isValid =
                        _formKey.currentState?.saveAndValidate() ?? false;
          
                    if (!isValid) {
                      return;
                    }
                    var values = Map<String, dynamic>.from(
                        _formKey.currentState?.value ?? {});
                 if(values["dateFinished"] is DateTime) {
                    values['dateFinished'] = 
                      (values['dateFinished'] as DateTime).toIso8601String();
          }
                    
          
                    
                        if (values["endEstimate"] is DateTime) {
            final dateTime = values["endEstimate"] as DateTime;
            final formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
            values["endEstimate"] = formattedTime;
          }
          
              var jobUpdateRequest = {
                "userId": widget.job.user?.userId,
                "freelancerId": null,
                "companyId": widget.job.company?.companyId,
                "jobTitle": widget.job.jobTitle,
                "isTenderFinalized": false,
                "isFreelancer": false,
                "isInvoiced": false,
                "isRated": false,
                "startEstimate": null,
                "endEstimate": null,  
                "payEstimate": widget.job.jobStatus== JobStatus.unapproved ? values["payEstimate"] : widget.job.payEstimate,
                "payInvoice": widget.job.jobStatus== JobStatus.unapproved ? null : values["payInvoice"],
                "jobDate": widget.job.jobDate.toIso8601String(),
                "dateFinished": values["dateFinished"],
                "jobDescription": widget.job.jobDescription,
                "image": widget.job.image,
                "jobStatus": widget.job.jobStatus== JobStatus.unapproved ? JobStatus.approved.name : JobStatus.finished.name,
                "serviceId": widget.job.jobsServices
                        ?.map((e) => e.service?.serviceId)
                        .toList(),
          };

          
              try {
            jobProvider.update(widget.job.jobId,
            jobUpdateRequest
            );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: widget.job.jobStatus== JobStatus.unapproved ? const Text('Posao prihvaćen.') : const Text('Faktura poslana korisniku.')));
            Navigator.pop(context,true);

          } on Exception catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška u slanju posla: ${e.toString()}')));
            Navigator.pop(context, false);

          }
          if(widget.job.jobStatus== JobStatus.unapproved) {
           try {
  final selectedEmployeeIds = values["companyEmployeeId"] as List<dynamic>?;

  if (selectedEmployeeIds != null && selectedEmployeeIds.isNotEmpty) {
    for (final employeeId in selectedEmployeeIds) {
      await companyJobAssignmentProvider.insert({
        "jobId": widget.job.jobId,
        "companyEmployeeId": employeeId,
        "assignedAt":DateTime.now().toIso8601String(),
      });
    }
  }

  if (context.mounted) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Zaposlenici uspješno dodani.")),
    );
  }
} catch (e) {
  if(!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Greška tokom dodavanja radnika: $e")),
  );
}
          }
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
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black), 
      ),
    );
  }
 

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors. black),
            ),
          ),
        ],
      ),
    );
  }
  
  

}

