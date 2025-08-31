import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';

class _Validators {
  static String? bosnianPhone(String? value) {
    if (value == null || value.isEmpty) return 'Obavezno polje';
    final regex = RegExp(r'^(?:\+387|0)(60|61|62|63|64|65|66|70|71|72|73|74|75|76)\d{6}$');
    if (!regex.hasMatch(value)) return 'Neispravan broj (npr: +38761XXXXXX ili 061XXXXXX)';
    return null;
  }

  static String? confirmPassword(String? val, String? password) {
    if (val == null || val.isEmpty) return 'Obavezno polje';
    if (val != password) return 'Lozinke se ne poklapaju';
    return null;
  }
}

class RegistrastionScreen extends StatefulWidget {
  const RegistrastionScreen({super.key});
  @override
  State<RegistrastionScreen> createState() => _RegistrastionScreenState();
}

class _RegistrastionScreenState extends State<RegistrastionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late UserProvider userProvider;
  late LocationProvider locationProvider;
  SearchResult<User>? userResult;
  SearchResult<Location>? locationResult;
  bool _isLoadingLocations = true;
  File? _image;
  String? _base64Image;
    String? _backendEmailError;
    String? _backendPasswordError;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    locationProvider = context.read<LocationProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    await _getLocations();
    if (AuthProvider.username.isNotEmpty || AuthProvider.password.isNotEmpty) {
      userResult = await userProvider.get();
      setState(() {});
    }
  }

  Future<void> _getLocations() async {
    try {
      var fetchedLocations = await locationProvider.get();
      setState(() {
        locationResult = fetchedLocations;
        _isLoadingLocations = false;
      });
    } catch (_) {
      setState(() => _isLoadingLocations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Registracija",style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,letterSpacing: 1.2,color: const Color.fromRGBO(27, 76, 125, 25)),),centerTitle: true,scrolledUnderElevation: 0,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('firstName', 'Ime*',validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: "Obavezno polje."),
                FormBuilderValidators.minLength(2,
                    errorText: "Minimalna dužina imena je 2 znaka."),
                FormBuilderValidators.maxLength(40,
                    errorText: "Maksimalna dužina imena je 40 znakova."),
                FormBuilderValidators.match(r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ]*$',
                    errorText:
                        "Ime mora počinjati sa velikim slovom i smije sadržavati samo slova.")
              ]),),
              _buildTextField('lastName', 'Prezime*',validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: "Obavezno polje."),
                FormBuilderValidators.minLength(2,
                    errorText: "Minimalna dužina prezimena je 2 znaka."),
                FormBuilderValidators.maxLength(40,
                    errorText: "Maksimalna dužina prezimena je 40 znakova."),
                FormBuilderValidators.match(r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ]*$',
                    errorText:
                        "Prezime mora počinjati sa velikim slovom i smije sadržavati samo slova.")
              ]),),
              Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FormBuilderTextField(
        name: 'email',
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'Email',
          border: const OutlineInputBorder(),
          errorText: _backendEmailError
        ),
        onChanged: (_) {
          if (_backendEmailError != null) {
            setState(() {
              _backendEmailError = null;
            });
          }
        },
        validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Obavezno polje'),
                FormBuilderValidators.email(errorText: 'Neispravan email'),
              ])
      ),
    ),
              _buildTextField('phoneNumber', 'Broj Telefona*',  validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: "Obavezno polje."),
                FormBuilderValidators.match(r'^\+387\d{7,15}$',
                    errorText:
                        "Telefon mora imati 11 cifara \ni počinjati sa +387."),
              ]),),
              _buildTextField('password', 'Lozinka*',
                  obscureText: true,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Obavezno polje'),
                    FormBuilderValidators.minLength(6, errorText: 'Min 6 karaktera'),
                  ])),
              _buildTextField('confirmPassword', 'Potvrdi Lozinku*',
                  obscureText: true,
                  validator: (val) => _Validators.confirmPassword(
                      val, _formKey.currentState?.fields['password']?.value)),

              const SizedBox(height: 16),
              _isLoadingLocations
                  ? const Center(child: CircularProgressIndicator())
                  : FormBuilderDropdown<int>(
                      name: 'locationId',
                      decoration: const InputDecoration(labelText: "Lokacija*"),
                      validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                      items: locationResult?.result
                              .map((loc) => DropdownMenuItem(
                                    value: loc.locationId,
                                    child: Text(loc.locationName),
                                  ))
                              .toList() ??
                          [],
                    ),
              const SizedBox(height: 16),
              _buildTextField('address', 'Adresa*',validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'Obavezno polje'),
                            FormBuilderValidators.minLength(5, errorText: 'Minimalna dužina adrese je 5 znaka.'),
                            FormBuilderValidators.match(
      r'^(?:[A-Za-zĆČĐŠŽćčđšž0-9\s,.\-]{5,100}|[bB]\.?[bB]\.?)$',
      errorText: 'Adresa mora sadržavati slova/brojeve i , . - (dozvoljeno i "bb"/"b.b.").',
    ),
FormBuilderValidators.maxLength(40, errorText: 'Maksimalno dozvoljeno je 40 znakova'),
                          ]),),
              const SizedBox(height: 16),

             FormBuilderField(
  name: "image",

  builder: (field) {
    return InputDecorator(
      decoration:  const InputDecoration(
        labelText: "Proslijedite profilnu sliku.",
        border: OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.image),
            title: 
            
             _image != null
                ? Text(_image!.path.split('/').last)
                :  
                
                 const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),



              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image==null? const Text("Odaberi", style: TextStyle(color: Colors.white)): const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () =>  getImage(field) 
             
            ),
          ),
          const SizedBox(height: 10),
          _image != null ?
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _image!,
               
                fit: BoxFit.cover,
              ),
            ) 
           
            : 
            const SizedBox.shrink()
           
            ,
        ],
      ),
    );
  },
),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _save,
                child: const Text("Sačuvaj", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String name, String label,
      {bool obscureText = false, FormFieldValidator<String>? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FormBuilderTextField(
        name: name,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? FormBuilderValidators.required(errorText: 'Obavezno polje'),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      var request = Map.from(_formKey.currentState!.value);
      request['image'] = _base64Image;
      request['roles'] = [2];

      try {
        var user = await userProvider.registration(request);
        if(mounted && context.mounted)
        {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Uspješna registracija: ${user.firstName}")),
          
        );
        }
        if(mounted && context.mounted)
        {
        Navigator.of(context).pop();
        }
      } catch (e) {
        print("${_formKey.currentState!.value}");
        if(mounted && context.mounted)
        {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
        }
      }
    }
  }

 void getImage(FormFieldState field) async {
  var result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.single.path != null) {
    setState(() {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
    });

 
    field.didChange(_image);
  }
}
}
