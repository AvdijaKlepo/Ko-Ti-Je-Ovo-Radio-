import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:provider/provider.dart';

class BookJob extends StatefulWidget {
  const BookJob({super.key});

  @override
  State<BookJob> createState() => _BookJobState();
}

class _BookJobState extends State<BookJob> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late JobProvider jobProvider;

  SearchResult<Job>? jobResult;
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }
  @override
  void initState(){
    jobProvider = context.read<JobProvider>();

    super.initState();
    _initialValue={

    };
    initForm();
  }
   Future initForm() async {
    jobResult = await jobProvider.get();
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

      ],),
      ),
    );
  }
  
  Widget _buildForm() {
    return FormBuilder(key:_formKey,
    initialValue: _initialValue,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Row(children: [
          SizedBox(
            width: 10,
          ),

          Expanded(child: FormBuilderTextField(
            decoration: InputDecoration(labelText: 'startEstimate'),
            name:"startEstimate"
          ))
        ],)
      ],),
    ) 
    
    );
  }
  

}