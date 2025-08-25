import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class ServiceFormDialog extends StatefulWidget {
  final Service? service;

  const ServiceFormDialog({super.key, this.service});

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ServiceProvider serviceProvider;
  File? _image;
  String? _base64Image;
  String? serviceErrorMessage;
  Uint8List? _decodedImage;

  @override
  void initState() {
    super.initState();
    serviceProvider = context.read<ServiceProvider>();
    _initialValue = {
      'serviceId': widget.service?.serviceId,
      'serviceName': widget.service?.serviceName,
      'image': widget.service?.image,
    };
    if (widget.service?.image != null) {
    try {
      _decodedImage = base64Decode(widget.service!.image!);
    } catch (_) {
      _decodedImage = null;
    }
    }
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
                      FormBuilderTextField(
                        name: "serviceName",
                        decoration:  InputDecoration(
                          labelText: "Naziv Servisa*",
                          border: OutlineInputBorder(),
                          errorText: serviceErrorMessage,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Obavezno polje'),
                          FormBuilderValidators.maxLength(50, errorText: 'Maksimalno 15 znakova'),
                          FormBuilderValidators.minLength(2, errorText: 'Minimalno 2 znaka'),
                          FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž ]+$', errorText: 'Dozvoljena su samo slova sa prvim velikim.'),
                        ])
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
                : widget.service?.image != null
                    ? const Text('Proslijeđena slika')
                    : const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image == null && widget.service?.image == null
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

  Future<void> _save() async {
  if (_formKey.currentState?.saveAndValidate() ?? false) {
    final request = Map<String, dynamic>.from(_formKey.currentState!.value);
    if (_image != null) {
      request['image'] = _base64Image;
    } else {
      request['image'] = widget.service?.image;
    }

    try {
      if (widget.service == null) {
        await serviceProvider.insert(request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usluga uspješno dodana")),
        );
      } else {
        await serviceProvider.update(widget.service!.serviceId, request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usluga uspješno ažurirana")),
        );
      }

      Navigator.of(context).pop(true);
    } on UserException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.exMessage)),
  );
    }
 catch (e) {
      // Fallback for unknown errors
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
