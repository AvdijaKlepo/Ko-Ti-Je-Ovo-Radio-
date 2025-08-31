import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/tender.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/tender_bid_provider.dart';
import 'package:provider/provider.dart';

class TenderBidScreen extends StatefulWidget {
  const TenderBidScreen({this.tender,this.freelancer, super.key});
  final Job? tender;
  final Freelancer? freelancer;

  @override
  State<TenderBidScreen> createState() => _TenderBidScreenState();
}

class _TenderBidScreenState extends State<TenderBidScreen> {
  var freelancerId = AuthProvider.user?.userId;
  final _formKey = GlobalKey<FormBuilderState>();
  late TenderBidProvider tenderBidProvider;
  late JobProvider jobProvider;
  SearchResult<Job>? jobResult;
    List<Job>? _currentBookedJobs;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    tenderBidProvider = context.read<TenderBidProvider>();
    jobProvider = context.read<JobProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if(!mounted) return;
     await _getJobs();
    });
  }
  Future<void> _getJobs() async {
  if (!mounted) return;
      
  setState(() => isLoading = true);
  try {
    final job = await jobProvider.get(filter: {
      'FreelancerId': freelancerId,
      'JobDate': widget.tender!.jobDate,
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
  // back-to-back allowed
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
  if (_formKey.currentState?.saveAndValidate() ?? false) {
    final values = _formKey.currentState!.value;

    if (widget.tender?.jobId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška: Tender nije validan")),
      );
      return;
    }
    DateTime _combineDateWithTime(DateTime date, DateTime time) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
    time.second,
  );
}
final pickedStart = values['startEstimate'] as DateTime?;
final pickedEnd = values['endEstimate'] as DateTime?;

if (pickedStart == null || pickedEnd == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Molimo unesite početak i završetak")),
  );
  return;
}

final jobDate = widget.tender!.jobDate; // this is the actual day
final start = _combineDateWithTime(jobDate, pickedStart);
final end   = _combineDateWithTime(jobDate, pickedEnd);




    if (start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Molimo unesite početak i završetak")),
      );
      return;
    }

   
    

    final workStart = _parseOn(widget.tender!.jobDate, widget.freelancer!.startTime);
    final workEnd   = _parseOn(widget.tender!.jobDate, widget.freelancer!.endTime);


    if (start.isBefore(workStart) || end.isAfter(workEnd)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Van vašeg radnog vremena")),
      );
      print(start);
      print(end);
         print(workStart);
    print(workEnd);
      return;
    }

    // ✅ Prevent overlap with booked jobs
    if (_overlapsAny(start, end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Odabrani termin se preklapa sa postojećom rezervacijom")),
      );
      return;
    }

    // ✅ Build request
    final request = {
      "jobId": widget.tender!.jobId,
      "companyId": null,
      "dateFinished": null,
      "freelancerId": freelancerId,
      "bidDescription": values['bidDescription'],
      "startEstimate": DateFormat.Hms().format(start),
      "endEstimate": DateFormat.Hms().format(end),
      "bidAmount": values['bidAmount'],
      "createdAt": DateTime.now().toIso8601String(),
    };

    try {
      await tenderBidProvider.insert(request);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ponuda uspješno dodana")),
      );
      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezerviši tender')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            
                        children: [
              isLoading ? const Center(child: LinearProgressIndicator()) :
               
                _currentBookedJobs!=null && _currentBookedJobs!.isNotEmpty ? 
                 Text(
                    'Rezervacije za ${DateFormat('dd-MM-yyyy').format(widget.tender!.jobDate)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ) : const SizedBox.shrink(),
                  
              
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
                  FormBuilderValidators.maxLength(500, errorText: 'Maksimalno 230 znaka'),
                  FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][a-zA-ZčćžđšČĆŽŠĐ\s0-9 .,\-\/!]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim, brojevi i osnovni znakovi.'),
                ]),
              ),
              const SizedBox(height: 15),
              FormBuilderDateTimePicker(
                name: "startEstimate",
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
                   ])
              ),
               
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(27, 76, 125, 25),
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