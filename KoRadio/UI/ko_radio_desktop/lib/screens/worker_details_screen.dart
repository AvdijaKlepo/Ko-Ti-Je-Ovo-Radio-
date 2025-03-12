import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ko_radio_desktop/layout/master_screen.dart';
import 'package:ko_radio_desktop/models/worker.dart';

class WorkerDetailsScreen extends StatefulWidget {
  Worker? worker;
  WorkerDetailsScreen({super.key,this.worker});

  @override
  State<WorkerDetailsScreen> createState() => _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState extends State<WorkerDetailsScreen> {

  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MasterScreen("Detalji",
      Column(children: [
        _buildForm(),
        _save()
      ],)
    );
  }
  
  Widget _buildForm() {
    return FormBuilder(key: _formKey, initialValue: _initialValue,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: FormBuilderTextField(
                  decoration: InputDecoration(labelText: "Ime"),
                  name: "firstName",
                )),
                SizedBox(width: 10,),
                Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "Prezime"),
                  name: "Last Name",
                )),
              ],
            )
          ],
        ),
      )

    );
  }

  Widget _save() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(onPressed: (){
            _formKey.currentState?.saveAndValidate();
            debugPrint(_formKey.currentState?.value.toString());
      
          }, child: Text("Save"))
        ],
      ),
    );
  }
}


