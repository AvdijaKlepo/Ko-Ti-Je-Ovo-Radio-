import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/tender.dart';
import 'package:ko_radio_mobile/models/tender_bids.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/tender_bid_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';



class TenderBidScreen extends StatefulWidget {
  const TenderBidScreen({this.tender,this.freelancer, super.key ,this.tenderBid});
  final Job? tender;
  final Freelancer? freelancer;
  final TenderBid? tenderBid;

  @override
  State<TenderBidScreen> createState() => _TenderBidScreenState();
}

class _TenderBidScreenState extends State<TenderBidScreen> {
  var freelancerId = AuthProvider.user?.userId;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialForm = {};
  late TenderBidProvider tenderBidProvider;
  late JobProvider jobProvider;
  SearchResult<Job>? jobResult;
  List<Job>? _currentBookedJobs;
  bool isLoading = false;
  bool multiDateJob=false;
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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('bs', null);
    tenderBidProvider = context.read<TenderBidProvider>();
    jobProvider = context.read<JobProvider>();
    final jobStartTime = parseTime(widget.tenderBid?.startEstimate ?? "08:00");
    final endTimeDate = parseTime(widget.tenderBid?.endEstimate ?? "17:00");
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if(!mounted) return;
     await _getJobs();
       _workingDayInts = widget.freelancer?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
      final currentValues = _formKey.currentState?.value ?? {};
    _initialForm = {
      ...currentValues

    };

    });
    
  }
  
  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }
  Future<void> _getJobs() async {
  if (!mounted) return;
      
  setState(() => isLoading = true);
  try {
    final job = await jobProvider.get(filter: {
      'FreelancerId': freelancerId,
      'DateRange': widget.tender!.jobDate,
      'JobStatus': JobStatus.approved.name,
    });
  
    setState(() {
      jobResult = job;
      _currentBookedJobs = jobResult?.result.toList();
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Greška u dohvaćanju poslova.')));
  }
}
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
    final s = j.startEstimate, e = j.endEstimate;
    if (s == null || e == null) continue;
    final bStart = _parseOn(widget.tender!.jobDate, s);
    final bEnd   = _parseOn(widget.tender!.jobDate, e);
    if (_rangeOverlaps(start, end, bStart, bEnd)) return true;
  }
  return false;
}

Future<void> _submit() async {
  FocusScope.of(context).unfocus();
  if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

  final rawValues = _formKey.currentState!.value;
  final values = Map<String, dynamic>.from(rawValues);
  final message = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  if (widget.tender?.jobId == null) {
    message.showSnackBar(
      const SnackBar(content: Text("Greška: Tender nije validan")),
    );
    return;
  }

  DateTime _combineDateWithTime(DateTime date, DateTime time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  final pickedStart = values['startEstimate'] as DateTime?;
  final pickedEnd = values['endEstimate'] as DateTime?;

  if (pickedStart == null || pickedEnd == null) {
    message.showSnackBar(
      const SnackBar(content: Text("Molimo unesite početak i završetak")),
    );
    return;
  }

  final jobDate = widget.tender!.jobDate;
  final start = _combineDateWithTime(jobDate, pickedStart);
  final end = _combineDateWithTime(jobDate, pickedEnd);

  // Working hours check
  final workStart = _parseOn(jobDate, widget.freelancer!.startTime);
  final workEnd = _parseOn(jobDate, widget.freelancer!.endTime);
  if (start.isBefore(workStart) || end.isAfter(workEnd)) {
    message.showSnackBar(
      const SnackBar(content: Text("Van vašeg radnog vremena")),
    );
    return;
  }

  // Overlap check
  if (_overlapsAny(start, end)) {
    message.showSnackBar(
      const SnackBar(content: Text("Odabrani termin se preklapa sa postojećom rezervacijom")),
    );
    return;
  }

  // Only include dateFinished if multiDateJob is true
  String? dateFinished;
  if (multiDateJob==true && values["dateFinished"] is DateTime) {
    dateFinished = (values["dateFinished"] as DateTime)
        .toIso8601String()
        .split('T')[0];
  }
  else{
    dateFinished=null;
  }

  final request = {
    "jobId": widget.tender!.jobId,
    "companyId": null,
    "freelancerId": freelancerId,
    "dateFinished": dateFinished,
    "bidDescription": values['bidDescription'],
    "startEstimate": DateFormat.Hms().format(start),
    "endEstimate": DateFormat.Hms().format(end),
    "bidAmount": values['bidAmount'],
    "createdAt": DateTime.now().toIso8601String(),
  };

  try {
    if (widget.tenderBid == null) {
      await tenderBidProvider.insert(request);
      message.showSnackBar(const SnackBar(content: Text("Ponuda uspješno dodana")));
    } else {
      await tenderBidProvider.update(widget.tenderBid!.tenderBidId, request);
      message.showSnackBar(const SnackBar(content: Text("Ponuda uspješno uređena")));
    }
    navigator.pop();
  } catch (e) {
    message.showSnackBar(SnackBar(content: Text("Greška: ${e.toString()}")));
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        title:  Text('Napravi ponudu',
        style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: const Color.fromRGBO(27, 76, 125, 25),letterSpacing: 1.2),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            
                        children: [
             if (_currentBookedJobs != null && _currentBookedJobs!.isNotEmpty) ...[
        Text(
          'Rezervacije za ${DateFormat.yMMMMd('bs').format(widget.tender!.jobDate)}',
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
                name: "bidDescription",
                decoration: const InputDecoration(
                  labelText: 'Opis mogućeg riješenja',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Obavezno polje'),
                  FormBuilderValidators.minLength(10, errorText: 'Minimalno 10 znaka'),
                  FormBuilderValidators.maxLength(50, errorText: 'Maksimalno 50 znakova'),
                  FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][a-zA-ZčćžđšČĆŽŠĐ\s0-9 .,\-\/!]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim, brojevi i osnovni znakovi.'),
                ]),
              ),
                    const SizedBox(height: 15,),

                  const Text('Vrijeme',style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
                                 Padding(
                                             padding: const EdgeInsets.all(1.0),
                                             child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                               
                                               children: [
                                                 const Text('Posao traje više dana?',style: TextStyle(fontWeight: FontWeight.bold),),
                                                 Checkbox(value: multiDateJob,onChanged: (value){
                                                   setState(() {
                                                    FocusScope.of(context).unfocus();
                                                     multiDateJob=value!;
                                                    
                                                     
                                                   });
                                                 },),
                                               ],
                                             ),
                                           ),
       if(multiDateJob==true)
        const SizedBox(height: 15),
      
                    const SizedBox(height: 15,),
       if(multiDateJob==true)

                                Visibility(
                                  visible: multiDateJob==true,
                                  maintainState: true,
                                  child: FormBuilderDateTimePicker(
                                    key: const ValueKey('dateFinished'),
                                                  name: "dateFinished",
                                                  initialDate: widget.tender!.jobDate,
                                                  firstDate: widget.tender!.jobDate,
                                                  inputType: InputType.date,
                                                  selectableDayPredicate: _isWorkingDay,
                                                  decoration: const InputDecoration(
                                                    labelText: "Datum završetka",
                                                    border: OutlineInputBorder(),
                                                    prefixIcon: Icon(Icons.date_range),
                                                  ),
                                                  validator: FormBuilderValidators.compose([
                                                    FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                                    (value) {
                                                      
                                  
                                                        final start = widget.tender!.jobDate;
                                                        if (value!.isBefore(start)) {
                                                          return 'Vrijeme završetka mora biti nakon početka.';
                                                        }
                                                        if(value==start)
                                                        {
                                                          return 'Posao mora trajati barem dva dana.';
                                                        }
                                                        return null;
                                                      },
                                                    ]),
                                                
                                                  
                                                ),
                                ),
                    
              const SizedBox(height: 15),
              FormBuilderDateTimePicker(
                name: "startEstimate",
                    key: const ValueKey('startEstimate'),
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                inputType: InputType.time,
                decoration: const InputDecoration(
                  labelText: "Početak radova",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                
              ),
              const SizedBox(height: 15),
              FormBuilderDateTimePicker(
                    key: const ValueKey('endEstimate'),
                
                name: "endEstimate",
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                inputType: InputType.time,
                decoration: const InputDecoration(
                  labelText: "Završetak radova", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Obavezno polje'),
                  (value) {
    if (value == null) return 'Završetak je obavezan.';

    final start = _formKey.currentState?.fields['startEstimate']?.value;
    if (start != null && value.isBefore(start)) {
      return 'Završetak mora biti nakon početka.';
    }
    return null;
  },
                ]),
              ),
                   const SizedBox(height: 15),
               const Text('Procijena',style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
              
         

              FormBuilderTextField(
                name: "bidAmount",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Iznos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                valueTransformer: (value) => double.tryParse(value ?? ''),
                   validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Obavezno polje'),
                    FormBuilderValidators.numeric(errorText: 'Mora biti broj, npr. 10.00'),
                    FormBuilderValidators.max(999,errorText: 'Maksimalno 10000 KM'),
                    FormBuilderValidators.min(1,errorText: 'Minimalno 1 KM'),
                   ])
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
            ],
          ),
        ),
      ),  
    );
  }
}