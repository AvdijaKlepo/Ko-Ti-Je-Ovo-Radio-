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
import 'package:ko_radio_desktop/screens/add_employee_task.dart';
import 'package:ko_radio_desktop/screens/edit_job.dart';
import 'package:provider/provider.dart';

class BookCompanyJob extends StatefulWidget {
  const BookCompanyJob(this.job,{super.key});
  final Job job;


  @override
  State<BookCompanyJob> createState() => _BookCompanyJobState();
}

class _BookCompanyJobState extends State<BookCompanyJob> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formKeyEmployee = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  final ExpansionTileController _expansionTileController = ExpansionTileController();


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
  SearchResult<Job>? jobResult;
  bool _isLoading = false;
  bool _checkBoxSubmit = false;
   bool _showEditPanel = false;
  bool _showTaskPanel = false;

  double _getDialogWidth() {
    if (_showEditPanel && _showTaskPanel) return 1200;
    if (_showEditPanel || _showTaskPanel) return 1000;
    return 500;
  }



  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      companyProvider = context.read<CompanyProvider>();
      jobProvider = context.read<JobProvider>();
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
      companyJobAssignmentProvider = context.read<CompanyJobAssignmentProvider>();
     await _getEmployees();
     await _getAssignments();
     await _getJob();
     _initialValue = {
      'companyEmployeeId': companyJobAssignmentResult?.result
              .map((e) => e.companyEmployee?.companyEmployeeId)
              .whereType<int>()
              .toSet()
              .toList(),

     };
     
    
    });
 
   _workingDayInts = widget.job.company?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
       
    _initialValue = {
  
    };
    setState(() {
      _isLoading = false;
    });
  }
  Future<void> _getJob() async {
    var filter = {'JobId': widget.job.jobId};
    try {
      var fetchedJob = await jobProvider.get(filter:  filter);
      setState(() {
        jobResult = fetchedJob;
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
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
    
   bool _showEditPanel = false;
   bool _showTaskPanel = false;

 

return StatefulBuilder(
  builder: (context, setState) {
    return Dialog(

      
      insetPadding: const EdgeInsets.all(24),
      child: AnimatedContainer(

        duration: const Duration(milliseconds: 300),
        width: 500 +
        (_showTaskPanel ? 500 : 0) +
        (_showEditPanel ? 500 : 0),
        height: 1250,
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if(_showTaskPanel==true)
                Expanded(
                  flex: 2,
                  child: AddEmployeeTask(job: widget.job,),
                ),
                // --- LEFT MAIN PANEL ---
                Expanded(
                  flex: 2,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Column(
                            

                            children: [
                              Card(

                                color: const Color.fromRGBO(27, 76, 125, 25),
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (jobResult?.result.first.isEdited == true || jobResult?.result.first.isWorkerEdited == true) ...[
  Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.amber.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.info, color: Colors.black87),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            "Ovaj posao je ažuriran.",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        if(jobResult?.result.first.isEdited==true)
        ElevatedButton(
          onPressed: () async {
            final jobUpdateRequest = {
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
              "payEstimate": widget.job.payEstimate,
              "payInvoice": null,
              "jobDate": widget.job.jobDate.toIso8601String(),
              "dateFinished": widget.job.dateFinished?.toIso8601String(),
              "jobDescription": widget.job.jobDescription,
              "image": widget.job.image,
              "jobStatus": widget.job.jobStatus.name,
              "serviceId": widget.job.jobsServices
                  ?.map((e) => e.service?.serviceId)
                  .toList(),
              "isEdited": false,
            };

            try {
              await jobProvider.update(widget.job.jobId, jobUpdateRequest);
              await _getJob(); // refresh so banner disappears
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Posao označen kao pregledan.")),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Greška: $e")),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Označi kao pregledano"),
        ),
      ],
    ),
  ),
],

                                      _sectionTitle('Radne specifikacije'),
                                _buildDetailRow('Posao', jobResult?.result.first.jobTitle ?? 'Nije dostupan'),
                                _buildDetailRow(
                                  'Servis',
                                  jobResult?.result.first.jobsServices
                                          ?.map((e) => e.service?.serviceName)
                                          .where((e) => e != null)
                                          .join(', ') ??
                                      'N/A',
                                ),
                                _buildDetailRow('Datum', DateFormat('dd-MM-yyyy').format(jobResult?.result.first.jobDate ?? DateTime.now())),
                                  _buildDetailRow(
                                  'Datum završetka',
                                  jobResult?.result.first.dateFinished != null
                                      ? DateFormat('dd-MM-yyyy').format(jobResult!.result.first.dateFinished!)
                                      : 'Nije dostupan',
                                ),
                                _buildDetailRow('Opis posla', jobResult?.result.first.jobDescription ?? 'Nije dostupan'),
                                 jobResult?.result.first.image!=null ?
                                 _buildImageRow(
                                  'Slika',
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(context: context, builder: (context) => _openImageDialog());
                                    
                                    
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child:  const Text(
                                      'Otvori sliku',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(27, 76, 125, 25)),
                                    ),
                                  ))
                              : _buildDetailRow('Slika','Nije unesena'),
                              
if(jobResult?.result.first.jobStatus == JobStatus.approved || jobResult?.result.first.jobStatus == JobStatus.finished)

                             const Divider(height: 32),
if(jobResult?.result.first.jobStatus == JobStatus.approved || jobResult?.result.first.jobStatus == JobStatus.finished)
_sectionTitle('Preuzeli dužnost'),

if (jobResult?.result.first.jobStatus == JobStatus.approved || jobResult?.result.first.jobStatus == JobStatus.finished)
FormBuilder(
  key: _formKeyEmployee,
  initialValue: _initialValue,
  child:
  Theme(
    data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
     
      ),
    child: ExpansionTile(
      enabled: jobResult?.result.first.jobStatus == JobStatus.approved,
    
      
      shape: const Border(),
      controller: _expansionTileController,
      
      title: _buildDetailRow(
        'Radnici',
        companyJobAssignmentResult?.result
                .map((e) =>
                    '${e.companyEmployee?.user?.firstName} ${e.companyEmployee?.user?.lastName}')
                .toList()
                .join(', ') ??
            'Nema zaposlenika',
      ),
      collapsedIconColor: Colors.white,
      iconColor:  Colors.white,
      backgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Theme(
            data: Theme.of(context).copyWith(
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: Colors.white, width: 2), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
    ),
  ),
            child: FormBuilderCheckboxGroup<int>(
              onChanged: (value) {
                setState(() {
                  _checkBoxSubmit = true;
                });
              },
              checkColor: Color.fromRGBO(27, 76, 125, 25),
              activeColor: Colors.white,
              
              
              name: 'companyEmployeeId',
              validator: FormBuilderValidators.required(
                  errorText: 'Obavezno polje'),
              decoration: const InputDecoration(
                
                  
                labelStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
              ),
              options: filterLoggedInUser
                      ?.map((e) => FormBuilderFieldOption<int>(
            
                            value: e.companyEmployeeId,
                            child: Text(
                              '${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList() ??
                  [],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if(_checkBoxSubmit)
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () async {
               final isValid = _formKeyEmployee.currentState?.saveAndValidate() ?? false;
    
    if (!isValid) {
    
      return;
    }
             
              
                  var formData = Map<String, dynamic>.from(
                      _formKeyEmployee.currentState?.value ?? {});
                      
    
              try {
                for (var workerId in formData["companyEmployeeId"]) {
                  await companyJobAssignmentProvider.insert({
                    "jobId": widget.job.jobId,
                    "companyEmployeeId": workerId,
                    "assignedAt": DateTime.now().toIso8601String(),
                    "isFinished":false
                  });
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
              _expansionTileController.collapse();
              await _getEmployees();
              await _getAssignments();
              setState(() {
                _checkBoxSubmit = false;
              });
    
     
    
    
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Uredi radnike',
              style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: (){
        
         setState(() => _showTaskPanel = !_showTaskPanel);
        }, child: Text('Dodaj zadatak'),),
      ],
    ),
  )),

const Divider(height: 32),


                                _sectionTitle('Korisnički podaci'),
                               _buildDetailRow(
                    'Ime i prezime',
                    jobResult?.result.first.user != null
                        ? '${widget.job.user?.firstName ?? ''} ${widget.job.user?.lastName ?? ''}'
                        : 'Nepoznato',
                  ),
                   _buildDetailRow('Broj Telefona',widget.job.user?.phoneNumber ??'Nepoznato'), 
                   _buildDetailRow('Lokacija', widget.job.user?.location?.locationName??'Nepoznato'),
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
                                _buildDetailRow('Procijena', jobResult?.result.first.payEstimate?.toStringAsFixed(2) ?? 'Nije unesena'),
                                _buildDetailRow('Konačna cijena', jobResult?.result.first.payInvoice?.toStringAsFixed(2) ?? 'Nije unesena'),
                                _buildDetailRow('Plaćen', jobResult?.result.first.isInvoiced == true ? 'Da' : 'Ne'),
                                if (jobResult?.result.first.jobStatus == JobStatus.cancelled)
                                  _buildDetailRow('Otkazan', 'Da'),

                                    ],
                                  ),
                                ),
                              ),

                              SingleChildScrollView(
                                child: FormBuilder(
                                  key: _formKey,
                                  initialValue: _initialValue,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        if (jobResult?.result.first.jobStatus == JobStatus.unapproved) ...[
                                  const Divider(height: 32,thickness: 1,color: Colors.black, ),
                                   Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'Potrebni podaci',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black), 
      ),
    ),
                                  const SizedBox(height: 12),
                                  FormBuilderDateTimePicker(
                                    enabled: _showEditPanel==true ? false : true,
                                    validator: FormBuilderValidators.required(errorText: "Obavezno polje"),
                                    decoration: const InputDecoration(
                                      labelText: 'Kraj radova',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    name: "dateFinished",
                                    inputType: InputType.date,
                                    firstDate: widget.job.jobDate,
                                    initialDate: widget.job.jobDate.isAfter(DateTime.now()) ? widget.job.jobDate : DateTime.now(),
                                    selectableDayPredicate: _isWorkingDay,
                                  ),
                                  const SizedBox(height: 15),
            
                                  FormBuilderTextField(
                                       enabled: _showEditPanel==true ? false : true,
                                    name: "payEstimate",
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Moguća Cijena',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.attach_money),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                      FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                                    ]),
                                    valueTransformer: (value) => double.tryParse(value ?? ''),
                                  ),
                                   FormBuilderCheckboxGroup<int>(
                                             enabled: _showEditPanel==true ? false : true,
                                          validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                          name: 'companyEmployeeId',
                                          decoration: const InputDecoration(labelText: "Zaduženi radnici"),
                                          options: filterLoggedInUser
                                                  ?.map((e) => FormBuilderFieldOption(
                                                        value: e.companyEmployeeId,
                                                        child: Text('${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}'),
                                                      ))
                                                  .toList() ??
                                              [],
                                        ),
                                ],

                                // --- Extra Fields for Approved Jobs ---
                                if (jobResult?.result.first.jobStatus == JobStatus.approved) ...[
                                  const Divider(height: 32),
                                  FormBuilderTextField(
                                       enabled: _showEditPanel==true || (widget.job.isWorkerEdited==true || widget.job.isEdited==true) ? false : true,
                                    name: "payInvoice",
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Finalna cijena',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.attach_money),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                      FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                                    ]),
                                    valueTransformer: (value) => double.tryParse(value ?? ''),
                                  ),
                                ],

                                // --- Employee Assignment ---
                                if (companyJobAssignmentResult?.count == 0 && widget.job.jobStatus == JobStatus.approved) ...[
                                  const Divider(height: 32),
                                  FormBuilder(
                                    key: _formKeyEmployee,
                                    child: Column(
                                      children: [
                                        FormBuilderCheckboxGroup<int>(
                                             enabled: _showEditPanel==true ? false : true,
                                          validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                          name: 'companyEmployeeId',
                                          decoration: const InputDecoration(labelText: "Zaduženi radnici"),
                                          options: filterLoggedInUser
                                                  ?.map((e) => FormBuilderFieldOption(
                                                        value: e.companyEmployeeId,
                                                        child: Text('${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}'),
                                                      ))
                                                  .toList() ??
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
        "isFinished":false
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
                              },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                    ],
                                  ),
                                )
                              ),
                               const Divider(height: 32),
                                if (widget.job.jobStatus != JobStatus.cancelled && widget.job.jobStatus != JobStatus.finished)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        label: const Text("Otkaži", style: TextStyle(color: Colors.red)),
                                        onPressed: () => showDialog(context: context, builder: (_) => _openCancelDialog()),
                                      ),
                                      const SizedBox(width: 12),
                                                            if(jobResult?.result.first.jobStatus == JobStatus.approved)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                        icon: const Icon(Icons.edit),
                                        label: const Text("Uredi"),
                                        onPressed: () => setState(() => _showEditPanel = !_showEditPanel),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text("Odobri"),
                                        onPressed: () => _submit(JobStatus.approved),
                                      ),
                                    ],
                                  ),


                              

                            ],
                          )
      ),
                ),
                
       if (_showEditPanel) ...[
        SizedBox(width: 50,),
                  const VerticalDivider(width: 1),
            
             
                  Expanded(
                    flex: 3,
                    child:  EditJob(job: widget.job),
                    
                  ),
                  
       ]
              ],
            ),
          ),
        )

    );
  },
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
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;

    if (!isValid) {
      return;
    }
    var values = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});
    if (values["dateFinished"] is DateTime) {
      values['dateFinished'] =
          (values['dateFinished'] as DateTime).toIso8601String();
    }

    if (values["endEstimate"] is DateTime) {
      final dateTime = values["endEstimate"] as DateTime;
      final formattedTime =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
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
      "payEstimate": widget.job.jobStatus == JobStatus.unapproved
          ? values["payEstimate"]
          : widget.job.payEstimate,
      "payInvoice": widget.job.jobStatus == JobStatus.unapproved
          ? null
          : values["payInvoice"],
      "jobDate": widget.job.jobDate.toIso8601String(),
      "dateFinished": values["dateFinished"],
      "jobDescription": widget.job.jobDescription,
      "image": widget.job.image,
      "jobStatus": widget.job.jobStatus == JobStatus.unapproved
          ? JobStatus.approved.name
          : JobStatus.finished.name,
      "serviceId":
          widget.job.jobsServices?.map((e) => e.service?.serviceId).toList(),
    };

    try {
      jobProvider.update(widget.job.jobId, jobUpdateRequest);
      final selectedEmployeeIds = values["companyEmployeeId"] as List<dynamic>?;

      if (selectedEmployeeIds != null && selectedEmployeeIds.isNotEmpty) {
        for (final employeeId in selectedEmployeeIds) {
          await companyJobAssignmentProvider.insert({
            "jobId": widget.job.jobId,
            "companyEmployeeId": employeeId,
            "assignedAt": DateTime.now().toIso8601String(),
          });
        }
      }
      if(widget.job.jobStatus == JobStatus.approved){
        for (var workerId in companyJobAssignmentResult!.result.map((e) => e.companyEmployee?.companyEmployeeId).whereType<int>().toSet().toList()) { 
          await companyJobAssignmentProvider.update(companyJobAssignmentResult!.result.firstWhere((element) => element.companyEmployee?.companyEmployeeId == workerId).companyJobId!,{
            "jobId": widget.job.jobId,
            "isFinished": true,
            "companyEmployeeId": workerId,
            "assignedAt": DateTime.now().toIso8601String(),
          
          });
        }
      }
      
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: widget.job.jobStatus == JobStatus.unapproved
              ? const Text('Posao prihvaćen.')
              : const Text('Faktura poslana korisniku.')));
      Navigator.pop(context, true);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška u slanju posla: ${e.toString()}')));
      Navigator.pop(context, false);
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white), 
      ),
    );
  }
    _openImageDialog() {
    return AlertDialog(
    
      backgroundColor: Color.fromRGBO(27, 76, 125, 25),
      title: const Text('Proslijeđena slika',style: TextStyle(color: Colors.white),),
      insetPadding: EdgeInsets.symmetric(horizontal: 500),
      content: imageFromString(widget.job.image!,fit: BoxFit.contain),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),))
      ],
    );
  }
  Widget _buildImageRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: value,
          ),
        ],
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
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors. white),
            ),
          ),
        ],
      ),
    );
  }
  
  

}

