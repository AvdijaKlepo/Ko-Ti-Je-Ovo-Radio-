import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/layout/master_screen.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:provider/provider.dart';

class LocationFormDialog extends StatefulWidget {
  final Location? location;

  const LocationFormDialog({super.key, this.location});

  @override
  State<LocationFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<LocationFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late LocationProvider locationProvider;
  File? _image;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    _initialValue = {
      'serviceId': widget.location?.locationId,
      'serviceName': widget.location?.locationName,

    };
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
                        name: "locationName",
                        decoration: const InputDecoration(
                          labelText: "Naziv Lokacije*",
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                      ),
                      const SizedBox(height: 20),
                     
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
      request['image'] = _base64Image;

      try {
        if (widget.location == null) {
          await locationProvider.insert(request);
        } else {
          await locationProvider.update(widget.location!.locationId!, request);
        }

        Navigator.of(context).pop(true); // Return success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> getImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }
}
