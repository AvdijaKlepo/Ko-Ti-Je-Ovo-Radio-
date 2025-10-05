import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/tender_bids.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/tender_bid_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class TenderBidScreen extends StatefulWidget {
  const TenderBidScreen({required this.tender,super.key ,this.tenderBid});
  final Job tender;
  final TenderBid? tenderBid;

  @override
  State<TenderBidScreen> createState() => _TenderBidScreenState();
}

class _TenderBidScreenState extends State<TenderBidScreen> {
   var companyId = AuthProvider.selectedCompanyId;
  final _formKey = GlobalKey<FormBuilderState>();
    Map<String, dynamic> _initialForm = {};
  late TenderBidProvider tenderBidProvider;
  late CompanyProvider companyProvider;
  late Company company;
  late CompanyJobAssignmentProvider _companyJobCheck;
  late CompanyEmployeeProvider companyEmployeeProvider;
  
  SearchResult<CompanyJobAssignment>? companyJobCheck;
  SearchResult<CompanyEmployee>? _companyEmployeeResult;
  SearchResult<CompanyJobAssignment>? tenderAssignedEmployees;
  Set<int> _workingDayInts ={};
  bool _isLoading = true;
  bool multiDateJob=false;
  DateTime? _dateEndValue;
  List<int> selectedIds=[];

  final Map<String, int> _dayStringToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
       final jobStartTime = parseTime(widget.tenderBid?.startEstimate ?? "08:00");
    final endTimeDate = parseTime(widget.tenderBid?.endEstimate ?? "17:00");
      tenderBidProvider = context.read<TenderBidProvider>();
      companyProvider = context.read<CompanyProvider>();
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
      _companyJobCheck = context.read<CompanyJobAssignmentProvider>();
      await _getCompany();
      await _getEmployees();
      await _getAssignments();
      await _getTenderAssignedEmployees();
        List<String>? workingDays = company.workingDays;
    _workingDayInts = workingDays
        ?.map((day) => _dayStringToInt[day] ?? -1)
        .where((dayInt) => dayInt != -1)
        .toSet() ?? {};
         if(widget.tenderBid?.dateFinished!=null)
    {
      multiDateJob=true;
    }
       if(widget.tenderBid!=null)
    {
    _initialForm = {
      'startEstimate': jobStartTime,
      'endEstimate': endTimeDate,
      'dateFinished': widget.tenderBid?.dateFinished,
      'bidAmount': widget.tenderBid?.bidAmount.toString(),
      'bidDescription': widget.tenderBid?.bidDescription,
      'freelancerId': widget.tenderBid?.freelancerId,
    };
    }
    if(widget.tenderBid==null)
    {
       final currentValues = _formKey.currentState?.value ?? {};
    _initialForm = {
      ...currentValues

    };
    }
    setState(() {
      _isLoading = false;
    });
    });
  }
  DateTime _findNextWorkingDay(DateTime start) {
  DateTime candidate = start;
  while (!_isWorkingDay(candidate)) {
    candidate = candidate.add(const Duration(days: 1));
  }
  return candidate;
}
Future<void> _getTenderAssignedEmployees() async {
  setState(() {
    _isLoading = true;
  });
  try {
    var fetchedCompanyJobAssignments = await _companyJobCheck.get(filter: {
      'JobId': widget.tender.jobId,
    });
    if (!mounted) return;
    setState(() {
      tenderAssignedEmployees = fetchedCompanyJobAssignments;

      
      selectedIds = tenderAssignedEmployees?.result
              ?.map((e) => e.companyEmployeeId ?? -1)
              .where((id) => id != -1)
              .toList() ??
          [];
    });
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

    


  Future<void> _submit() async {
    final message = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
  if (_formKey.currentState?.saveAndValidate() ?? false) {
    final values = _formKey.currentState!.value;
   String? dateFinished;
  if (multiDateJob==true && values["dateFinished"] is DateTime) {
    dateFinished = (values["dateFinished"] as DateTime)
        .toIso8601String()
        .split('T')[0];
  }
  else{
    dateFinished=null;
  }
  if(selectedIds.isEmpty)
  {
    message.showSnackBar(
      const SnackBar(content: Text("Morate odabrati radnike")),
    );
    return;
  }


    final request = {
      "jobId": widget.tender.jobId,
      "companyId": companyId,
      "dateFinished": dateFinished,
      "freelancerId": null,
      "bidDescription":values['bidDescription'],
      "startEstimate": DateFormat.Hms().format(values['startEstimate']),
      "endEstimate": DateFormat.Hms().format(values['endEstimate']),
      "bidAmount": values['bidAmount'],
      "createdAt": DateTime.now().toIso8601String(),
      
    };
 
    final selectedEmployees = values['companyEmployeeId'] as List<dynamic>?;
    if (selectedEmployees != null && selectedEmployees.isNotEmpty) {
      for (final employeeId in selectedEmployees!) {
        try {
  await _companyJobCheck.insert({
    'jobId': widget.tender.jobId,
    'companyEmployeeId': employeeId,
    'assignedAt': DateTime.now().toIso8601String(),
  });
} on Exception catch (e) {

}
      }
    
    }

   
    try {
      if(widget.tenderBid==null)
      {
      await tenderBidProvider.insert(request);
     
      message.showSnackBar(
        const SnackBar(content: Text("Ponuda uspješno dodana")),
      );
     
      navigator.pop();
      } else {
      await tenderBidProvider.update(widget.tenderBid!.tenderBidId, request);
     
      message.showSnackBar(
        const SnackBar(content: Text("Ponuda uspješno uređena")),
      );
     
      navigator.pop();
      }
    } catch (e) {
      message.showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  

  
}
Future<void> _getAssignments() async {
  setState(() {
    _isLoading = true;
  });
  try {

    final dateRangeDate = _dateEndValue ?? widget.tender.jobDate;
    var filter = {
      'IsFinished': false,
      'IsCancelled': false,
      'DateRange': dateRangeDate.toIso8601String(),
      'JobDate': widget.tender.jobDate?.toIso8601String() ?? widget.tender.jobDate.toIso8601String()
    };
    var fetchedCompanyJobAssignments = await _companyJobCheck.get(filter: filter);
    print(fetchedCompanyJobAssignments.result);
    if (!mounted) return;
    setState(() {
      companyJobCheck = fetchedCompanyJobAssignments;
    });
  } catch (e) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

Future<void> _getEmployees() async {
  try {
    var filter = {'CompanyId': AuthProvider.selectedCompanyId};
    var fetchedCompanyEmployees = await companyEmployeeProvider.get(filter: filter);
    setState(() {
      _companyEmployeeResult = fetchedCompanyEmployees;
    });
  } catch (e) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}

Future<void> _getCompany() async {
  try{
    var fetchedCompany = await companyProvider.getById(companyId);
    setState(() {
     company = fetchedCompany;
    });
  }
  catch(e){
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content:  Text("Greška tokom dohvaćanja firme")),
    );
  }
}
bool _isWorkingDay(DateTime day) {
  if (_workingDayInts.isEmpty) return false;
  return _workingDayInts.contains(day.weekday);
}
bool checkIfValid(int companyEmployeeId) {

  final formState = _formKey.currentState;
  if (formState == null) return false;

  final startValue = formState.fields['startEstimate']?.value as DateTime?;
  final endValue = formState.fields['endEstimate']?.value as DateTime?;
  final dateFinishedField = formState.fields['dateFinished']?.value as DateTime?;


  if (startValue == null || endValue == null) return false;

  DateTime combineDateAndTime(DateTime datePart, DateTime timePart) {
    return DateTime(
      datePart.year,
      datePart.month,
      datePart.day,
      timePart.hour,
      timePart.minute,
      timePart.second,
    );
  }


  final proposedStart = combineDateAndTime(widget.tender.jobDate, startValue);


  final proposedEndDate = (multiDateJob && (dateFinishedField != null)) ? dateFinishedField : widget.tender.jobDate;
  final proposedEnd = combineDateAndTime(proposedEndDate, endValue);


  final assignments = companyJobCheck?.result ?? [];


  DateTime? parseJobDate(dynamic d) {
    if (d == null) return null;
    if (d is DateTime) return d;
    try {
      return DateTime.parse(d.toString());
    } catch (_) {
      return null;
    }
  }

  DateTime combineFromJob(dynamic jobDateRaw, String? timeString) {
    final jobDate = parseJobDate(jobDateRaw) ?? widget.tender.jobDate;
    if (timeString == null) {

      return DateTime(jobDate.year, jobDate.month, jobDate.day);
    }
    final parts = timeString.split(':').map((s) => int.tryParse(s) ?? 0).toList();
    final hour = parts.isNotEmpty ? parts[0] : 0;
    final minute = parts.length > 1 ? parts[1] : 0;
    final second = parts.length > 2 ? parts[2] : 0;
    return DateTime(jobDate.year, jobDate.month, jobDate.day, hour, minute, second);
  }

  final selectedEmployeeJobs = assignments.where((e) => e.companyEmployeeId == companyEmployeeId).toList();

  for (var jobCheck in selectedEmployeeJobs) {
    final job = jobCheck.job;
    if (job == null) continue;


    if (job.startEstimate == null || job.endEstimate == null) continue;


    final bookedStart = combineFromJob(job.jobDate ?? job.jobDate, job.startEstimate);

    final bookedEndDate = parseJobDate(job.dateFinished) ?? parseJobDate(job.jobDate) ?? widget.tender.jobDate;
    final bookedEnd = combineFromJob(bookedEndDate, job.endEstimate);

    final overlap = proposedStart.isBefore(bookedEnd) && proposedEnd.isAfter(bookedStart);
    if (overlap) {
      return true; 
    }
  }

  return false; 
}

  @override
  Widget build(BuildContext context) {
    final availableEmployees = _companyEmployeeResult?.result?.where((e) => e.userId != AuthProvider.user?.userId).toList() ?? [];
    if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
    return Dialog(
     
       surfaceTintColor: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
     
        child:
            SingleChildScrollView(
                    
                    child: FormBuilder(
                      key: _formKey,
                      initialValue: _initialForm,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
            Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Napravi ponudu',style: TextStyle(color: Colors.white),),
                        IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.close,color: Colors.white,),)
                      ],
                    )),
                    SizedBox(height: 20,),
            
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: "bidDescription",
                    decoration: const InputDecoration(
                      labelText: 'Opis mogućeg riješenja',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                  ),
                  const SizedBox(height: 15),
                   Row(
                                                    children: [
                                                      const Text('Posao traje više dana?',style: TextStyle(fontWeight: FontWeight.bold),),
                                                      Checkbox(value: multiDateJob,onChanged: (value){
                                                        setState(() {
                                                          multiDateJob=value!;
                                                          if(multiDateJob==false)
                                                          {
                                                            _formKey.currentState?.fields['dateFinished']?.didChange(null);
                                                          }
                                                        });
                                                      },),
                                                    ],
                                                  ),
                                                  if(multiDateJob==true)
                  FormBuilderDateTimePicker(
                    name: "dateFinished",
                    decoration: const InputDecoration(
                      labelText: 'Datum završetka',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    currentDate: widget.tender.jobDate,
                    inputType: InputType.date,
                    firstDate: _findNextWorkingDay(widget.tender.jobDate),
                    initialDate: _findNextWorkingDay(widget.tender.jobDate), 
                        
                     
                          selectableDayPredicate: _isWorkingDay,
                    validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                    onChanged: (value) async { 
                      setState(() {
                      _dateEndValue = value;
                    });
                
                    },
                    
                  ),

                  SizedBox(height: 10,),
                   FormBuilderDateTimePicker(
                name: "startEstimate",
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                inputType: InputType.time,
                decoration: const InputDecoration(
                  labelText: "Vrijeme početka",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Obavezno polje'),
                 (value) {
                                                                                                if (value == null) return null;
                                                                    
                                                                                                final startOfShift = company.startTime; 
                                                                                                final endOfShift = company.endTime;
                                                                    
                                                                                                final formatter = DateFormat('HH:mm:ss');
                                                                    
                                                                                                final baseDate = DateTime(value.year, value.month, value.day);
                                                                    
                                                                                                final start = baseDate.add(formatter.parse(startOfShift)
                                                                                                    .difference(DateTime(1970))); 
                                                                                                final end = baseDate.add(formatter.parse(endOfShift)
                                                                                                    .difference(DateTime(1970)));
                                                                    
                                                                                                if (value.isBefore(start)) {
                                                                                                  return 'Smijena počinje u ${startOfShift.substring(0, 5)}';
                                                                                                }
                                                                                                if (value.isAfter(end)) {
                                                                                                  return 'Smijena završava u ${endOfShift.substring(0, 5)}';
                                                                                                }
                                                                    
                                                                                                return null;
                                                                                              },
                                                        
                ]),
                onChanged: (value) => setState(() {
                
                }),
                
              ),
              const SizedBox(height: 15),
              FormBuilderDateTimePicker(
                name: "endEstimate",
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                inputType: InputType.time,
                decoration: const InputDecoration(
                  labelText: "Vrijeme završetka", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
               validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Obavezno polje'),
                 (value) {
                                                                                                if (value == null) return null;
                                                                    
                                                                                                final startOfShift = company.startTime; 
                                                                                                final endOfShift = company.endTime;
                                                                    
                                                                                                final formatter = DateFormat('HH:mm:ss');
                                                                    
                                                                                                final baseDate = DateTime(value.year, value.month, value.day);
                                                                    
                                                                                                final start = baseDate.add(formatter.parse(startOfShift)
                                                                                                    .difference(DateTime(1970))); 
                                                                                                final end = baseDate.add(formatter.parse(endOfShift)
                                                                                                    .difference(DateTime(1970)));
                                                                    
                                                                                                if (value.isBefore(start)) {
                                                                                                  return 'Smijena počinje u ${startOfShift.substring(0, 5)}';
                                                                                                }
                                                                                                if (value.isAfter(end)) {
                                                                                                  return 'Smijena završava u ${endOfShift.substring(0, 5)}';
                                                                                                }
                                                                    
                                                                                                return null;
                                                                                              },
                                                        
                ]),
                onChanged: (value) => setState(() {
                
                }),
              ),
              const SizedBox(height: 15),
                  FormBuilderTextField(
                    name: "bidAmount",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Iznos',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    valueTransformer: (value) => double.tryParse(value ?? ''),
                       validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                  ),
                ],
              ),
            ),
             
            const SizedBox(height: 15),
            ValueListenableBuilder<DateTime?>(
  valueListenable: ValueNotifier(_dateEndValue),
  builder: (context, endValue, _) {
    final canSelectEmployees = 
        (_dateEndValue != null || endValue != null) || 
        (endValue != null || _dateEndValue == null);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderField<List<int>>(
        name: 'companyEmployeeId',
        enabled: canSelectEmployees,
      
        builder: (field) {
          selectedIds = field.value ?? selectedIds;
      
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(
                message: canSelectEmployees
                    ? 'Odaberite radnika'
                    : 'Prvo unesite datum početka i završetka (ili samo početni datum za jednodnevni posao).',
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Dodaj radnika',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_add),
               
                    helperText: canSelectEmployees
                        ? null
                        : 'Onemogućeno dok ne unesete datume',
                  ),
                  items: availableEmployees.map((e) {
                    final isBusy = checkIfValid(e.companyEmployeeId);
                    return DropdownMenuItem<int>(
                      value: e.companyEmployeeId,
                      child: Row(
                        children: [
                          isBusy
                              ? const Icon(Icons.close, color: Colors.red)
                              : const Icon(Icons.check, color: Colors.green),
                          const SizedBox(width: 6),
                          Text('${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}'),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: canSelectEmployees
                      ? (value) {
                          if (value != null && !selectedIds.contains(value) && !checkIfValid(value)) {
                            field.didChange([...selectedIds, value]);
                          }
                        }
                      : null,
                ),
              ),
      
              const SizedBox(height: 8),
      
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedIds.map((id) {
                  final employee = availableEmployees.firstWhere(
                    (e) => e.companyEmployeeId == id,
                    orElse: () => availableEmployees.first,
                  );
      
                  return Chip(
                    label: Text('${employee.user?.firstName ?? ''} ${employee.user?.lastName ?? ''}'),
                    avatar: checkIfValid(id)
                        ? const Icon(Icons.close, color: Colors.red, size: 16)
                        : const Icon(Icons.check, color: Colors.green, size: 16),
                    deleteIcon: const Icon(Icons.clear),
                    onDeleted: () {
                      field.didChange(selectedIds.where((x) => x != id).toList());
                    },
                  );
                }).toList(),
              ),
      
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    field.errorText ?? '',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  },
),
            const SizedBox(height: 15),


            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text("Sačuvaj", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 15,),
                        ],
                      ),
                    ),
                  )
       
      ),

     
    );
  }
}