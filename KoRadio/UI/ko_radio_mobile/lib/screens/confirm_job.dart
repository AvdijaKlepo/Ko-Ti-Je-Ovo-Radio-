

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:provider/provider.dart';

class ConfirmJob extends StatefulWidget {
  ConfirmJob(this.jobId, {super.key});
  Job? jobId;

  @override
  State<ConfirmJob> createState() => _ConfirmJobState();
}

class _ConfirmJobState extends State<ConfirmJob> {
 final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late JobProvider jobProvider;
  late ServiceProvider serviceProvider;

  SearchResult<Job>? jobResult;
  SearchResult<Service>? serviceResult;
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }
  @override
  void initState(){
    jobProvider = context.read<JobProvider>();
    serviceProvider = context.read<ServiceProvider>();

    super.initState();
    _initialValue={
  
    };
    initForm();
  }
   Future initForm() async {
    var filter = {
      'JobId':widget.jobId
    };
    jobResult = await jobProvider.get(filter: filter);
    serviceResult = await serviceProvider.get();
    print("Fetched user first name: ${jobResult?.result}");
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MasterScreen(
      child: Scaffold(
        body:  Column(children: [
        _buildForm(),
        _save()

      ],),
      ),
    );
  }
  
  Widget _buildForm() {
    return FormBuilder(
        key: _formKey,
        initialValue: _initialValue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('${widget.jobId?.startEstimate}'),
              Text('${widget.jobId?.jobDescription}'),
              Text('${widget.jobId?.jobDate}'),
              Text('${widget.jobId?.user?.firstName}'),
              Text(
  widget.jobId!.jobsServices
      ?.map((e) => e.service?.serviceName)
      .where((name) => name != null)
      .join(', ') ?? 'No services'
),
 Row(
                children: [
                  Expanded(
                      child: FormBuilderDateTimePicker(
                    decoration:
                        InputDecoration(labelText: 'Trajanje posla'),
                    name: "endEstimate",
                    inputType: InputType.time,
                  
                  )),
                ],
              ),
               Row(
                children: [
                  Expanded(
                      child: FormBuilderTextField(
                    decoration:
                        InputDecoration(labelText: 'Moguća Cijena'),
                    name: "payEstimate",
                    keyboardType: TextInputType.numberWithOptions(decimal: true),

                    valueTransformer: (value) => double.tryParse(value ?? ''),
                  
                  )),
                ],
              ),


             
              
              
                  
            ],
          ),
        ));
  }
  String formatTimeOnly(DateTime? time) {
  if (time == null) return '';
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
}

  Widget _save() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final formData = _formKey.currentState!.value;
     
              // Extract values
              final payEstimate = formData['payEstimate'] as double?;
              final endEstimate = formData['endEstimate'];
 
              try {
                await jobProvider.update(
                  widget.jobId!.jobId!,
                  {
                    'payEstimate': payEstimate,
                    'endEstimate': endEstimate,
                  },
                );
                print(endEstimate);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Job updated successfully')),
                );

                Navigator.pop(context); 
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update job: $e')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Validation failed')),
              );
            }
          },
          child: Text("Sačuvaj"),
        ),
      ],
    ),
  );
}

}