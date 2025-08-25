import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/store.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class StoreUpdateDialog extends StatefulWidget {
  const StoreUpdateDialog({required this.store, super.key});
  final Store store;

  @override
  State<StoreUpdateDialog> createState() => _StoreUpdateDialogState();
}

class _StoreUpdateDialogState extends State<StoreUpdateDialog> {
  Uint8List? _decodedImage;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late StoreProvider storesProvider;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  File? _image;
  String? _base64Image;


  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    storesProvider = context.read<StoreProvider>();
    _initialValue = {
      "storeName": widget.store.storeName,
      "description": widget.store.description,  
      "address": widget.store.address,
      "image": widget.store.image,
      "locationId": widget.store.location?.locationId,
    };
    if (widget.store.image != null) {
    try {
      _decodedImage = base64Decode(widget.store.image!);
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
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška tokom dohvaćanja lokacija. Pokušajte ponovo.")),
      );
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
                      const Text("Podaci Trgovine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: "storeName", decoration: const InputDecoration(labelText: "Ime Trgovine:"),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.maxLength(50, errorText: 'Maksimalno 50 znakova'),
                        FormBuilderValidators.minLength(2, errorText: 'Minimalno 2 znaka'),
                        FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž .]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim.'),
                      ])
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: "description",maxLines: 3, decoration: const InputDecoration(labelText: "Opis"),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.maxLength(230, errorText: 'Maksimalno 230 znakova'),
                        FormBuilderValidators.minLength(10, errorText: 'Minimalno 10 znakova'),
                        FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž0-9\s.,\-\/!]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim, brojevi i osnovni znakovi.'),
                      ])
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: "address", decoration: const InputDecoration(labelText: "Adresa"),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž0-9\s.,\-\/!]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim, brojevi i osnovni znakovi.'),
                      ]),
                      ),
                      const SizedBox(height: 20),

                      
                     
                    

                       FormBuilderDropdown<int>(
                        name: 'locationId',
                        decoration: const InputDecoration(labelText: "Lokacija*"),
                        validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        items: locationResult?.result
                                .map((loc) => DropdownMenuItem(
                                      value: loc.locationId,
                                      child: Text(loc.locationName ?? ''),
                                    ))
                                .toList() ??
                            [],
                      ),
                      const SizedBox(height: 20),
                       FormBuilderField(
  name: "image",
  builder: (field) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Logo",
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
                : widget.store?.image != null
                    ? const Text('Proslijeđena slika')
                    : const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image == null && widget.store?.image == null
                  ? const Text("Odaberi", style: TextStyle(color: Colors.white))
                  : const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () => _pickImage(),
            ),
          ),
          const SizedBox(height: 10),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            )
          else if (_decodedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _decodedImage!,
                fit: BoxFit.cover,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  },
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

  Future<void> _save() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
      request['isApplicant'] = false;
      request['isDeleted'] = false;
      request['roles']=[10,1011];
      request['userId']=widget.store.user?.userId;
  
      if(_image!=null)
      {
        request['image'] = _base64Image;
      }
      else{
        request['image'] = widget.store.image;
      }
    

      try {
        await storesProvider.update(widget.store.storeId, request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Podaci uspješno uređeni!")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
    }
  }
}