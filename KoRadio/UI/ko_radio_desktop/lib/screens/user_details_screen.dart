import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/user_provider.dart';
import 'package:provider/provider.dart';

class UserPromoteDialog extends StatefulWidget {
  final User? user;
  const UserPromoteDialog({super.key, this.user});

  @override
  State<UserPromoteDialog> createState() => _UserPromoteDialogState();
}

class _UserPromoteDialogState extends State<UserPromoteDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};

  late UserProvider userProvider;
  late ServiceProvider serviceProvider;
  late FreelancerProvider freelancerProvider;
  late LocationProvider locationProvider;

  SearchResult<Service>? serviceResult;
  SearchResult<Location>? locationResult;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    serviceProvider = context.read<ServiceProvider>();
    freelancerProvider = context.read<FreelancerProvider>();
    locationProvider = context.read<LocationProvider>();

    _initialValue = {
      'freelancerId': widget.user?.userId.toString(),
      'firstName': widget.user?.firstName,
      'lastName': widget.user?.lastName,
      'email': widget.user?.email,
      'locationId': widget.user?.location?.locationId,
    };

    _fetchData();
  }

  Future<void> _fetchData() async {
    final locations = await locationProvider.get();
    final services = await serviceProvider.get();
    setState(() {
      locationResult = locations;
      serviceResult = services;
    });
  }

  void _onSave() {
    _formKey.currentState?.saveAndValidate();
    var formData = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});

    if (formData["startTime"] is DateTime) {
      formData["startTime"] = (formData["startTime"] as DateTime)
          .toIso8601String()
          .substring(11, 19);
    }
    if (formData["endTime"] is DateTime) {
      formData["endTime"] = (formData["endTime"] as DateTime)
          .toIso8601String()
          .substring(11, 19);
    }

    Map<String, int> dayMap = {
      'Sunday': 0,
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
    };

    if (formData["workingDays"] != null) {
      formData["workingDays"] = (formData["workingDays"] as List<String>)
          .map((day) => dayMap[day])
          .whereType<int>()
          .toList();
    }

    formData["roles"] = [10];
    formData["isDeleted"] = false;
    formData["isApplicant"] = true; 



    var selectedServices = formData["serviceId"];
    formData["serviceId"] = (selectedServices is List)
        ? selectedServices
            .map((id) => int.tryParse(id.toString()) ?? 0)
            .toList()
        : (selectedServices != null
            ? [int.tryParse(selectedServices.toString()) ?? 0]
            : []);

    try {
      freelancerProvider.insert(formData);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Uspješno zaposlen radnik: ${widget.user?.firstName} ${widget.user?.lastName}")));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Promoviši korisnika: ${widget.user?.firstName} ${widget.user?.lastName}",
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 16),
              FormBuilder(
                key: _formKey,
                initialValue: _initialValue,
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: FormBuilderTextField(
                              name: "freelancerId",
                              decoration: InputDecoration(labelText: "User ID"))),
                      SizedBox(width: 8),
                      Expanded(
                          child: FormBuilderTextField(
                              name: "firstName",
                              decoration: InputDecoration(labelText: "First Name"))),
                      SizedBox(width: 8),
                      Expanded(
                          child: FormBuilderTextField(
                              name: "lastName",
                              decoration: InputDecoration(labelText: "Last Name"))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: FormBuilderTextField(
                              name: "email",
                              decoration: InputDecoration(labelText: "Email"))),
                      SizedBox(width: 8),
                      Expanded(
                          child: FormBuilderTextField(
                              name: "bio",
                              decoration: InputDecoration(labelText: "Bio"))),
                      SizedBox(width: 8),
                      Expanded(
                          child: FormBuilderTextField(
                              name: "experianceYears",
                              decoration: InputDecoration(labelText: "Years of Experience"))),
                    ]),
                    const SizedBox(height: 12),
                    FormBuilderDropdown<int>(
                      name: 'locationId',
                      decoration: const InputDecoration(labelText: "Location"),
                      items: locationResult?.result
                              .map((loc) => DropdownMenuItem(
                                  value: loc.locationId,
                                  child: Text(loc.locationName ?? '')))
                              .toList() ??
                          [],
                    ),
                    const SizedBox(height: 12),
                    FormBuilderCheckboxGroup<int>(
                      name: "serviceId",
                      decoration: InputDecoration(labelText: "Services"),
                      options: serviceResult?.result
                              .map((item) => FormBuilderFieldOption<int>(
                                  value: item.serviceId,
                                  child: Text(item.serviceName ?? "")))
                              .toList() ??
                          [],
                    ),
                    const SizedBox(height: 12),
                    FormBuilderCheckboxGroup<String>(
                      name: 'workingDays',
                      decoration: InputDecoration(labelText: "Working Days"),
                      options: [
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday',
                        'Sunday'
                      ].map((e) => FormBuilderFieldOption(value: e)).toList(),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderDateTimePicker(
                      name: 'startTime',
                      decoration: InputDecoration(labelText: "Početak radnog vremena"),
                      inputType: InputType.time,
                    ),
                    FormBuilderDateTimePicker(
                      name: 'endTime',
                      decoration: InputDecoration(labelText: "Kraj radnog vremena"),
                      inputType: InputType.time,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text("Odustani"),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          child: Text("Sačuvaj"),
                          onPressed: _onSave,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
