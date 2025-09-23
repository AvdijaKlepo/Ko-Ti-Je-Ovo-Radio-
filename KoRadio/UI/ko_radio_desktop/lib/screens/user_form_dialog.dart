import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  Uint8List? _decodedImage;

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
    if (widget.user?.image != null) {
    try {
      _decodedImage = base64Decode(widget.user!.image!);
    } catch (_) {
      _decodedImage = null;
    }
  }
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _getLocations();
  });


  }
  Future<void> _pickImage() async {
  var result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.single.path != null) {
    setState(() {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
      _decodedImage = null; 
    });
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
   return Dialog(
  surfaceTintColor: Colors.white,
  child: SizedBox(
    width: MediaQuery.of(context).size.width * 0.25,
    height: MediaQuery.of(context).size.height * 1,
    child:ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Podaci korisnika',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FormBuilder(
                      key: _formKey,
                      initialValue: _initialValue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- PERSONAL INFO ---
                          const Text(
                            'Osnovne informacije',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),

                          FormBuilderTextField(
                            name: "firstName",
                            decoration: InputDecoration(
                              labelText: "Ime",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Ime je obavezno.'),
                              FormBuilderValidators.minLength(2, errorText: 'Minimalno 2 znaka.'),
                              FormBuilderValidators.maxLength(35, errorText: 'Maksimalno 35 znakova.'),
                              FormBuilderValidators.match(
                                r'^[A-Z][a-zA-ZĆČĐŠŽćčđšž]+$',
                                errorText: 'Samo slova, prvo mora biti veliko.',
                              ),
                            ]),
                          ),
                          const SizedBox(height: 12),

                          FormBuilderTextField(
                            name: "lastName",
                            decoration: InputDecoration(
                              labelText: "Prezime",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Prezime je obavezno.'),
                              FormBuilderValidators.minLength(2, errorText: 'Minimalno 2 znaka.'),
                              FormBuilderValidators.maxLength(35, errorText: 'Maksimalno 35 znakova.'),
                              FormBuilderValidators.match(
                                r'^[A-Z][a-zA-ZĆČĐŠŽćčđšž]+$',
                                errorText: 'Samo slova, prvo mora biti veliko.',
                              ),
                            ]),
                          ),

                          const SizedBox(height: 20),

                          // --- CONTACT INFO ---
                          const Text(
                            'Kontakt informacije',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),

                          FormBuilderTextField(
                            name: "email",
                            decoration: InputDecoration(
                              labelText: "Email",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Email je obavezan.'),
                              FormBuilderValidators.email(errorText: 'Neispravan email.'),
                            ]),
                          ),
                          const SizedBox(height: 12),

                          FormBuilderTextField(
                            name: "phoneNumber",
                            decoration: InputDecoration(
                              labelText: "Telefon",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: "Telefon je obavezan."),
                              FormBuilderValidators.match(
                                r'^\+\d{11}$',
                                errorText: "Telefon mora imati +387 i ukupno 11 cifara.",
                              ),
                            ]),
                          ),
                          const SizedBox(height: 12),

                          FormBuilderTextField(
                            name: "address",
                            decoration: InputDecoration(
                              labelText: "Adresa",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Adresa je obavezna.'),
                              FormBuilderValidators.maxLength(40, errorText: 'Maksimalno 40 znakova.'),
                            ]),
                          ),
                          const SizedBox(height: 20),

                          // --- LOCATION ---
                          FormBuilderDropdown<int>(
                            name: 'locationId',
                            decoration: InputDecoration(
                              labelText: "Lokacija*",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.required(errorText: 'Lokacija je obavezna.'),
                            items: locationResult?.result
                                    .map((loc) => DropdownMenuItem(
                                          value: loc.locationId,
                                          child: Text(loc.locationName ?? ''),
                                        ))
                                    .toList() ??
                                [],
                          ),

                          const SizedBox(height: 20),

                          // --- IMAGE UPLOAD ---
                          FormBuilderField(
                            name: "image",
                            builder: (field) {
                              return InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Profilna slika",
                                  border: OutlineInputBorder(),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.image),
                                      title: _image != null
                                          ? Text(_image!.path.split('/').last)
                                          : widget.user?.image != null
                                              ? const Text('Proslijeđena slika')
                                              : const Text("Nema slike"),
                                      trailing: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                                        ),
                                        icon: const Icon(Icons.file_upload, color: Colors.white),
                                        label: _image == null && widget.user?.image == null
                                            ? const Text("Odaberi", style: TextStyle(color: Colors.white))
                                            : const Text("Promijeni", style: TextStyle(color: Colors.white)),
                                        onPressed: () => _pickImage(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (_image != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(_image!, fit: BoxFit.cover),
                                      )
                                    else if (_decodedImage != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(_decodedImage!, fit: BoxFit.cover),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // --- PASSWORD ---
                          const Text(
                            'Ako ne mijenjate lozinku, ostavite polja prazna.',
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),

                          FormBuilderTextField(
                            name: "password",
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Nova Lozinka",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 12),
                          FormBuilderTextField(
                            name: "confirmPassword",
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Potvrdi Lozinku",
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- SAVE BUTTON ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text("Sačuvaj", style: TextStyle(color: Colors.white)),
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      if(request['password']!=request['confirmPassword'])
      {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lozinke se ne poklapaju")));
        return;
      }
  

    
      

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
          const SnackBar(content: Text("Greška tokom spašavanja podataka. Pokušajte ponovo.")),
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
