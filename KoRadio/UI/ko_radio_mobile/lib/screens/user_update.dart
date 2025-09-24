import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/user_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class UserUpdate extends StatefulWidget {
  const UserUpdate({required this.user,  required this.locationId, super.key});
  final User user;
  final int locationId;

  @override
  State<UserUpdate> createState() => _UserUpdateState();
}

class _UserUpdateState extends State<UserUpdate> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late UserProvider userProvider;
  SearchResult<User>? userResult;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  bool _isLoadingLocations = true;
  File? _image;
  String? _base64Image;
  Uint8List? _decodedImage;
  @override
  void initState() {
    super.initState();

    locationProvider = context.read<LocationProvider>();
    userProvider = context.read<UserProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
await  _getLocations(); 
await _getUsers();



  
  });
 int? locationId = userResult?.result.first.location?.locationId;
 print(locationId);
_initialValue = {
      'userId': widget.user?.userId,
      'firstName': widget.user?.firstName,
      'lastName': widget.user?.lastName,
      'email': widget.user?.email,
      'phoneNumber': widget.user?.phoneNumber,
      'locationId': widget.locationId,
      'address': widget.user?.address,
      'image': widget.user?.image,
    
    };
   
    if(widget.user?.image!=null)
    {
      try {
        _decodedImage = base64Decode(widget.user.image!);
      } catch (_) {
        _decodedImage = null;
      }
    }
  
  }
  Future<void> _pickImage() async {
  var result = await FilePicker.platform.pickFiles(type: FileType.image,
  allowedExtensions: ['png', 'jpg', 'jpeg']);

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
      if(!mounted) return;
      setState(() {
        locationResult = fetchedLocations;
        _isLoadingLocations = false;
      });
    } catch (_) {
      if(!mounted) return;
      setState(() => _isLoadingLocations = false);
    }
  }
  Future<void> _getUsers() async {
    var filter = {
      'UserId': widget.user.userId,
    };
    try {
      var fetchedUsers = await userProvider.get(filter: filter);
      if(!mounted) return;
      setState(() {
        userResult = fetchedUsers;
        
      });
    } catch (_) {

    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text('Ažuriraj račun',style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: Color.fromRGBO(27, 76, 125, 25),letterSpacing: 1.2),),
      centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
                  child: FormBuilder(
                    key: _formKey,
                    initialValue: _initialValue,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        const SizedBox(height: 20),
                      
                         
                          
                         
                       
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
        
                        const SizedBox(height: 20),
        
                  
                        const SizedBox(height: 30),
        
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                             style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(27, 76, 125, 25)),
                            icon: const Icon(Icons.save,color: Colors.white,),
                            label: const Text("Sačuvaj",style: TextStyle(color: Colors.white),),
                            onPressed: _save,
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
      request['image'] = _base64Image;


    
      

      try {
        
        
          await userProvider.update(widget.user!.userId, request);
    
        
 ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Podaci ažurirani")),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
         Navigator.of(context).pop(false);
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