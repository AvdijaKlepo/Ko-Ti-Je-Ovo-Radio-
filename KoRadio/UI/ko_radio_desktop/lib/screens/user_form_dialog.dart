import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';

import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';

import 'package:ko_radio_desktop/providers/user_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class UserFormDialog extends StatefulWidget {
  final User? user;

  const UserFormDialog({super.key, this.user});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late UserProvider userProvider;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  bool _isLoadingLocations = true;
  File? _image;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    userProvider = context.read<UserProvider>();

    _initialValue = {
      'userId': widget.user?.userId,
      'firstName': widget.user?.firstName,
      'lastName': widget.user?.lastName,
      'email': widget.user?.email,
      'phoneNumber': widget.user?.phoneNumber,
      'locationId': widget.user?.location?.locationId,
      'address': widget.user?.address,
      'image': widget.user?.image,
    };

    _getLocations();
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
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  initialValue: _initialValue,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Korisnički Podaci", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      FormBuilderTextField(
                          name: "firstName",
                          decoration: const InputDecoration(
                            labelText: "Ime",
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        ),
                        const SizedBox(height: 12),
        
                        FormBuilderTextField(
                          name: "lastName",
                          decoration: const InputDecoration(
                            labelText: "Prezime",
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        ),
                        const SizedBox(height: 12),
        
                        FormBuilderTextField(
                          name: "email",
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: 'Obavezno polje'),
                            FormBuilderValidators.email(errorText: 'Neispravan email'),
                          ]),
                        ),
                        const SizedBox(height: 12),
        
                        FormBuilderTextField(
                          name: "phoneNumber",
                          decoration: const InputDecoration(
                            labelText: "Broj Telefona",
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        ),
                        const SizedBox(height: 12),
        
                        _isLoadingLocations
                            ? const Center(child: CircularProgressIndicator())
                            : FormBuilderDropdown<int>(
                                name: 'locationId',
                                decoration: const InputDecoration(
                                  labelText: "Lokacija",
                                  border: OutlineInputBorder(),
                                ),
                                validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                items: locationResult?.result
                                        .map((loc) => DropdownMenuItem(
                                              value: loc.locationId,
                                              child: Text(loc.locationName ?? ''),
                                            ))
                                        .toList() ??
                                    [],
                              ),
                        const SizedBox(height: 12),
        
                        FormBuilderTextField(
                          name: "address",
                          decoration: const InputDecoration(
                            labelText: "Adresa Stanovanja",
                            border: OutlineInputBorder(),
                          ),
                          validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        ),
                        const SizedBox(height: 10),
                     
                         FormBuilderField(
  name: "image",

  builder: (field) {
    return InputDecorator(
      decoration:  const InputDecoration(
        labelText: "Proslijedite sliku problema",
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
                :  widget.user?.image!= null ?
            const Text('Proslijeđena slika') :
                
                 const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),



              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label:widget.user?.image!= null ? const Text('Promijeni sliku',style: TextStyle(color: Colors.white)): _image==null? const Text("Odaberi", style: TextStyle(color: Colors.white)): const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
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
            ) :
            widget.user?.image!=null ?
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child : imageFromString(widget.user?.image ?? '',
              fit: BoxFit.cover
              ),
            ) : const SizedBox.shrink()
           
            ,
        ],
      ),
    );
  },
),
const SizedBox(height: 20,),
                        const Text('U slučaju da ne mjenjate lozinku ne morate je popuniti.',style: TextStyle(color: Colors.red),),
                        FormBuilderTextField(
          name: "password",
          obscureText: true,
          decoration: const InputDecoration(labelText: "Nova Lozinka",border: OutlineInputBorder()),
          validator: FormBuilderValidators.match(
            _formKey.currentState?.fields['confirmPassword']?.value ?? '',
            errorText: 'Lozinke se ne poklapaju',
          ),
        ),
                        const SizedBox(height: 12),
        
        FormBuilderTextField(
          name: "confirmPassword",
          obscureText: true,
          decoration: const InputDecoration(labelText: "Potvrdi Lozinku",border: OutlineInputBorder()),
        ),

                      const SizedBox(height: 30),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text("Sačuvaj"),
                          onPressed: _save,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
      if (_base64Image != null) {
                  request['image'] = _base64Image;
                }
                else{
                  request['image'] = widget.user?.image;
                }
      request['roles']= [11];
  

    
      

      try {
        if (widget.user == null) {
          await userProvider.insert(request);
          if(!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upsješno unesen korisnik ${widget.user?.firstName} ${widget.user?.lastName}")),
        );
        } else {
          await userProvider.update(widget.user!.userId, request);
          if(!mounted) return;

           ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upsješno uređen korisnik ${widget.user?.firstName} ${widget.user?.lastName}")),
        );
        }

        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
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
