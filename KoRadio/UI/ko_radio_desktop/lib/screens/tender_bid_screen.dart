import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/tender_bid_provider.dart';
import 'package:provider/provider.dart';

class TenderBidScreen extends StatefulWidget {
  const TenderBidScreen({required this.tender,super.key});
  final Job tender;

  @override
  State<TenderBidScreen> createState() => _TenderBidScreenState();
}

class _TenderBidScreenState extends State<TenderBidScreen> {
   var companyId = AuthProvider.selectedCompanyId;
  final _formKey = GlobalKey<FormBuilderState>();
  late TenderBidProvider tenderBidProvider;
  late CompanyProvider companyProvider;
  late Company company;
  Set<int> _workingDayInts ={};
  bool _isLoading = true;

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
      tenderBidProvider = context.read<TenderBidProvider>();
      companyProvider = context.read<CompanyProvider>();
      await _getCompany();
        List<String>? workingDays = company.workingDays;
    _workingDayInts = workingDays
        ?.map((day) => _dayStringToInt[day] ?? -1)
        .where((dayInt) => dayInt != -1)
        .toSet() ?? {};
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


  Future<void> _submit() async {
  if (_formKey.currentState?.saveAndValidate() ?? false) {
    final values = _formKey.currentState!.value;

 


    if (widget.tender.jobId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška: Tender nije validan")),
      );
      return;
    }
  

    final request = {
      "jobId": widget.tender!.jobId,
      "companyId": companyId,
      "dateFinished": (values['dateFinished'] as DateTime).toIso8601String().split('T')[0],
      "freelancerId": null,
      "bidDescription":values['bidDescription'],
      "startEstimate": null,
      "endEstimate": null,
      "bidAmount": values['bidAmount'],
      "createdAt": DateTime.now().toIso8601String()
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
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
              child:SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: FormBuilder(
          key: _formKey,
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
              ),

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
     
            )
          ]
        ),
      ),

     
    );
  }
}