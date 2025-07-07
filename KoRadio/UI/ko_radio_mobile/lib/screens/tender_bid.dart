import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/tender.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/tender_bid_provider.dart';
import 'package:provider/provider.dart';

class TenderBidScreen extends StatefulWidget {
  const TenderBidScreen({this.tender, super.key});
  final Job? tender;

  @override
  State<TenderBidScreen> createState() => _TenderBidScreenState();
}

class _TenderBidScreenState extends State<TenderBidScreen> {
  var freelancerId = AuthProvider.user?.userId;
  final _formKey = GlobalKey<FormBuilderState>();
  late TenderBidProvider tenderBidProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tenderBidProvider = context.read<TenderBidProvider>();
    });
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

    final request = {
      "jobId": widget.tender!.jobId,
      "companyId": null,
      "dateFinished": null,
      "freelancerId": freelancerId,
      "bidDescription": values['bidDescription'],
      "startEstimate": DateFormat.Hms().format(values['startEstimate']),
      "endEstimate": DateFormat.Hms().format(values['endEstimate']),
      "bidAmount": values['bidAmount'],
      "createdAt": DateTime.now().toIso8601String(),
    };

    try {
      await tenderBidProvider.insert(request);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ponuda uspješno dodana")),
      );
      Navigator.pop(context); // <- Also return after successful submit
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
                validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
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