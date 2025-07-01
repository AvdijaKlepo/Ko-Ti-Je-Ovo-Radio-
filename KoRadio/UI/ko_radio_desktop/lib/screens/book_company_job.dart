import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';

import 'package:provider/provider.dart';

class BookCompanyJob extends StatefulWidget {
  const BookCompanyJob(this.job,{super.key});
  final Job job;


  @override
  State<BookCompanyJob> createState() => _BookCompanyJobState();
}

class _BookCompanyJobState extends State<BookCompanyJob> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};


  DateTime? _currentJobDate;
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      companyProvider = context.read<CompanyProvider>();
      jobProvider = context.read<JobProvider>();
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
      companyJobAssignmentProvider = context.read<CompanyJobAssignmentProvider>();
      _getEmployees();
      _getAssignments();
    
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
      var filter = {'jobId': widget.job.jobId};
      var fetchedCompanyJobAssignments = await companyJobAssignmentProvider.get(filter: filter);
      setState(() {
        companyJobAssignmentResult = fetchedCompanyJobAssignments;
      });
    } catch (e) {
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

    return Dialog(
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
                    children: [
                     
                      Text("Posao #${widget.job.jobId}",  
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      if(widget.job.jobStatus==JobStatus.unapproved)
                        _buildUnapprovedDisplay()
                      else if(widget.job.jobStatus==JobStatus.approved)
                      _buildApprovedDisplay(),

                   
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text("Otkazi", style: TextStyle(color: Colors.red)),
                            onPressed: () => _cancel(),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Odobri"),
                            onPressed: () => _submit(JobStatus.approved),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _cancel() async {
     _formKey.currentState?.saveAndValidate();
  final formData = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});

  if (_base64Image != null) {
    formData["image"] = _base64Image;
  }

  formData["jobStatus"] = JobStatus.cancelled.name;
  formData["userId"] = widget.job.user?.userId;
  formData["companyId"] = widget.job.company?.companyId;


  formData["serviceId"] = widget.job.jobsServices
      ?.map((e) => e.service?.serviceId)
      .whereType<int>() 
      .toList();


  
  formData["jobDate"] = widget.job.jobDate.toUtc().toIso8601String();

  formData["jobDescription"] = widget.job.jobDescription;





    try {
      await jobProvider.update(widget.job.jobId, formData);
      if (context.mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Posao označen kao ${JobStatus.cancelled.name}.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

 Future<void> _submit(JobStatus status) async {
  _formKey.currentState?.saveAndValidate();
  final formData = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});

  if (_base64Image != null) {
    formData["image"] = _base64Image;
  }

  formData["jobStatus"] = status.name;
  formData["userId"] = widget.job.user?.userId;
  formData["companyId"] = widget.job.company?.companyId;


  formData["serviceId"] = widget.job.jobsServices
      ?.map((e) => e.service?.serviceId)
      .whereType<int>() 
      .toList();
  formData["jobDate"] = widget.job.jobDate.toUtc().toIso8601String();

  formData["jobDescription"] = widget.job.jobDescription;


  if (widget.job.jobStatus.name == JobStatus.unapproved.name) {
  if (formData["dateFinished"] is DateTime) {
    formData["dateFinished"] =
        (formData["dateFinished"] as DateTime).toUtc().toIso8601String();
  } else {
    formData["dateFinished"] = null;
  }
} else {
  formData["dateFinished"] = widget.job.dateFinished?.toUtc().toIso8601String();
}




  if (widget.job.jobStatus.name == JobStatus.unapproved.name) {
    if (formData["payEstimate"] != null) {
      formData["payEstimate"] = (formData["payEstimate"] as double).toString();
    } else {
      formData["payEstimate"] = null;
    }
  } else {
    formData["payEstimate"] = widget.job.payEstimate.toString();
  }

  if(widget.job.jobStatus.name == JobStatus.approved.name) {
    formData["payInvoice"] = (formData["payInvoice"] as double).toString();
    formData["jobStatus"] = JobStatus.finished.name;
  }


  try {
    await jobProvider.update(widget.job.jobId, formData);
    if (context.mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Posao označen kao ${status.name}.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: $e")),
    );
  }
 try {
  final selectedEmployeeIds = formData["companyEmployeeId"] as List<dynamic>?;

  if (selectedEmployeeIds != null && selectedEmployeeIds.isNotEmpty) {
    for (final employeeId in selectedEmployeeIds) {
      await companyJobAssignmentProvider.insert({
        "jobId": widget.job.jobId,
        "companyEmployeeId": employeeId,
        "assignedAt":DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Zaposlenici uspješno dodani.")),
    );
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Greška tokom dodavanja radnika: $e")),
  );
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
  
  Widget _buildUnapprovedDisplay(){
    return Column(
      children: [
          _buildInfoRow('Zakazan datum',DateFormat('dd-MM-yyyy').format(widget.job.jobDate)), 
                      const SizedBox(height: 12),
                     _buildInfoRow('Opis problema',widget.job.jobDescription),
                      const SizedBox(height: 12),
                      _buildInfoRow('Zakazani servisi',widget.job.jobsServices!.map((e) => e.service?.serviceName).toList().join(', ')),
                      const SizedBox(height: 12),
                       LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final height = width * 0.45;
                              return SizedBox(
                                width: width,
                                height: height,
                                child: widget.job.image!=null ? imageFromString(
                                  widget.job.image ?? '',
                                 
                                ): Image.asset("assets/images/Image_not_available.png"),
                              );
                            },
                          ),
                      const SizedBox(height: 24),
                       FormBuilderDateTimePicker(
                        decoration: const InputDecoration(
                          labelText: 'Kraj radova',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        name: "dateFinished",
                        inputType: InputType.date,
                        firstDate: DateTime.now(),
                        selectableDayPredicate: _isWorkingDay,
                      ),
                      SizedBox(height: 12,),
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
              const SizedBox(height: 24),
             FormBuilderCheckboxGroup(
  name: 'companyEmployeeId',
  decoration: const InputDecoration(labelText: "Zaposlenici"),
  options: companyEmployeeResult?.result
          .map((e) => FormBuilderFieldOption(
                value: e.companyEmployeeId,
                child: Text('${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}'),
              ))
          .toList() ??
      [],
)

      ],
    );

}

Widget _buildApprovedDisplay()
{
  return Column(
    children: [
 _buildInfoRow('Zakazan datum',DateFormat('dd-MM-yyyy').format(widget.job.jobDate)), 
                      const SizedBox(height: 12),
                     _buildInfoRow('Opis problema',widget.job.jobDescription),
                      const SizedBox(height: 12),
                      _buildInfoRow('Zakazani servisi',widget.job.jobsServices!.map((e) => e.service?.serviceName).toList().join(', ')),
                      const SizedBox(height: 12),
                       LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final height = width * 0.45;
                              return SizedBox(
                                width: width,
                                height: height,
                                child: widget.job.image!=null ? imageFromString(
                                  widget.job.image ?? '',
                                 
                                ): Image.asset("assets/images/Image_not_available.png"),
                              );
                            },
                          ),
                      const SizedBox(height: 24),

                      _buildInfoRow('Kraj Radova', widget.job.dateFinished.toString()),
                        const SizedBox(height: 24),
                      _buildInfoRow('Procjene', widget.job.payEstimate.toString()),
                        const SizedBox(height: 24),
                      _buildInfoRow('Zaposlenici', companyJobAssignmentResult?.result.map((e) => e.companyEmployee?.user?.firstName ?? '').toList().join(', ') ?? 'Nema zaposlenika'),
                        FormBuilderTextField(
                name: "payInvoice",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Faktura',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                valueTransformer: (value) => double.tryParse(value ?? ''),
              ),
                       
                     
    ],
  );
        
}
}

