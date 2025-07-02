import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/store_provider.dart';
import 'package:provider/provider.dart';

class UserStoreApply extends StatefulWidget {
  const UserStoreApply({this.user,super.key});
  final User? user;

  @override
  State<UserStoreApply> createState() => _UserStoreApplyState();
}

class _UserStoreApplyState extends State<UserStoreApply> {
  final _formKey = GlobalKey<FormBuilderState>();


  late StoreProvider storeProvider;
  late LocationProvider locationProvider;
  SearchResult<Location>? locationResult;
  @override
  void initState() {
    super.initState();
    storeProvider = context.read<StoreProvider>();
    locationProvider = context.read<LocationProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getLocations();
    });
  }
  _getLocations() async {
    var filter = {'isDeleted:':false};
    var fetchedLocations = await locationProvider.get(filter: filter);
    setState(() {
      locationResult = fetchedLocations;
      });
  }   
  var _userId = AuthProvider.user?.userId ?? 0;
  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(title: const Text("Prijava Trgovine")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Prijava Trgovine za korisnika: ${widget.user?.firstName} ${widget.user?.lastName}",
                  style: Theme.of(context).textTheme.titleLarge),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                    FormBuilderTextField(name: "storeName", decoration: const InputDecoration(labelText: "Ime Trgovine:")),
                    FormBuilderTextField(name: "description", decoration: const InputDecoration(labelText: "Opis")),
                    FormBuilderDropdown<int>(
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
                    Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _onSave, child: const Text("Sačuvaj")),
                ],
              ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    _formKey.currentState?.saveAndValidate();
    var formData = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});
    formData['userId'] = _userId;
    formData['isApplicant'] = true;
    formData['isDeleted'] = false;
 

    try {
      storeProvider.insert(formData);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Trgovina uspješno dodana!")));
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
}