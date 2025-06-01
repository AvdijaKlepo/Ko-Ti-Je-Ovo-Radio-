import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
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
  late LocationProvider locationProvider;
  SearchResult<User>? userResult;
  SearchResult<Location>? locationResult;
  String? image="image";
  bool _isLoadingLocations = true;

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
    await initForm();
  }
  }

  Future<void> _getLocations() async {
    try {
      var fetchedLocations = await locationProvider.get();
      setState(() {
        locationResult = fetchedLocations;
        _isLoadingLocations = false;
      });

      print("Fetched locations: ${locationResult?.result.map((l) => l.locationName)}");
    } catch (e) {
      print("Error fetching locations: $e");
      setState(() {
        _isLoadingLocations = false;
      });
    }
  }

  Future<void> initForm() async {
    userResult = await userProvider.get();
    print("Fetched user data: ${userResult?.result}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registracija")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('firstName', 'First Name'),
              _buildTextField('lastName', 'Last Name'),
              _buildTextField('email', 'Email'),
              _buildTextField('password', 'Lozinka', obscureText: true),
              _buildTextField('confirmPassword', 'Potvrdi Lozinku', obscureText: true),

              const SizedBox(height: 16),

              _isLoadingLocations
                  ? const Center(child: CircularProgressIndicator())
                  : FormBuilderDropdown<int>(
            name: 'locationId',
            decoration: const InputDecoration(labelText: "Location"),
            items: locationResult?.result
                    .map((loc) => DropdownMenuItem(
                          value: loc.locationId,
                          child: Text(loc.locationName ?? ''),
                        ))
                    .toList() ??
                [],
          ),

              const SizedBox(height: 16),

              FormBuilderField(
                name: 'image',
                builder: (field) {
                  return InputDecorator(
                    decoration: const InputDecoration(labelText: "Odaberi sliku"),
                    child: ListTile(
                      leading: const Icon(Icons.image),
                      title: const Text("Select image"),
                      trailing: const Icon(Icons.file_upload),
                      onTap: getImage,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _save,
                child: const Text("Sačuvaj"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String name, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FormBuilderTextField(
        name: name,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      var request = Map.from(_formKey.currentState!.value);
      request['image'] = _base64Image;
      request['roles'] = [7];

      try {
        var user = await userProvider.registration(request);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Uspješna registracija: ${user.firstName}")),
        );
      } catch (e) {
        print ("${_formKey.currentState!.value}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
          
        );
      }
    }
  }

  File? _image;
  String? _base64Image;

  Future<void> getImage() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }
}
