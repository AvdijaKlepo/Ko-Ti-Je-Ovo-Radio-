import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/layout/master_screen.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
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

  @override
  void initState() {
    super.initState();
    serviceProvider = context.read<ServiceProvider>();
    _initialValue = {
      'serviceId': widget.service?.serviceId,
      'serviceName': widget.service?.serviceName,
      'image': widget.service?.image,
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
                        name: "serviceName",
                        decoration: const InputDecoration(
                          labelText: "Naziv Servisa*",
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderField<String>(
                        name: 'image',
                        builder: (field) {
                          return InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Odaberi sliku",
                              border: OutlineInputBorder(),
                            ),
                            child: InkWell(
                              onTap: getImage,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.image),
                                      SizedBox(width: 10),
                                      Text("Odaberi sliku"),
                                    ],
                                  ),
                                  const Icon(Icons.file_upload),
                                ],
                              ),
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
      request['image'] = _base64Image;

      try {
        if (widget.service == null) {
          await serviceProvider.insert(request);
        } else {
          await serviceProvider.update(widget.service!.serviceId, request);
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
