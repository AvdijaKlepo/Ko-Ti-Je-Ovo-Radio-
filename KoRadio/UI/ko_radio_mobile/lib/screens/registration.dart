import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';

class RegistrastionScreen extends StatefulWidget {
  const RegistrastionScreen({super.key});

  @override
  State<RegistrastionScreen> createState() => _RegistrastionScreenState();
}

class _RegistrastionScreenState extends State<RegistrastionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late UserProvider userProvider;
  SearchResult<User>? userResult;
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  @override
  void initState(){
    userProvider = context.read<UserProvider>();

    _initialValue = {
    };

    initForm();
    
  }
    Future initForm() async {
    userResult = await userProvider.get();
    print("Fetched user first name: ${userResult?.result}");
    setState(() {
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return  MasterScreen(
      child: Scaffold(
        body: Column(
          children: [
            _buildForm(),
            _save()
          ],
        ),
      ),
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
                SizedBox(width: 10,),
               
                Expanded(child: FormBuilderTextField(
                  decoration: InputDecoration(labelText: "First Name"),
                  name: 'firstName',
                )),
                SizedBox(width: 10,),
                Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "Last name"),
                  name: "lastName",
                )),
                 SizedBox(width: 10,),
                Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "Email"),
                  name: "email",
                )),
                 SizedBox(width: 10,),
                  Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "Lozinka"),
                  name: "password",
                )),
                 SizedBox(width: 10,),
                  Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "Potvrdi Lozinku"),
                  name: "confirmPassword",
                )),
               
              ],
            ),
             Row(
                  children: [
                    Expanded(child: FormBuilderField(
                      name:"image",
                      builder: (field){
                        return InputDecorator(decoration: InputDecoration(labelText: "Odaberi sliku"),
                        child: Expanded(child: ListTile(
                          leading: Icon(Icons.image),
                          title: Text("Select image"),
                          trailing: Icon(Icons.file_upload),
                          onTap: getImage,
                        )),);
                      },
                    ))
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
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              var request = Map.from(_formKey.currentState!.value);
              request['image'] = _base64Image;

              try {
                var user = await userProvider.registration(request);
                // Handle successful registration, maybe show dialog/snackbar
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Uspješna registracija: ${user.firstName}"),
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Greška: ${e.toString()}"),
                ));
              }
            }
          },
          child: Text("Sačuvaj"),
        ),
      ],
    ),
  );
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
}

 