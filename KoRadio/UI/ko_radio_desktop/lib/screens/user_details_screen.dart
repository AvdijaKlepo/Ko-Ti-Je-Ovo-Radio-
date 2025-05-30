import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ko_radio_desktop/layout/master_screen.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/user_provider.dart';
import 'package:provider/provider.dart';


class UserDetailsScreen extends StatefulWidget {
  User? user;
  UserDetailsScreen({super.key,this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {

  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late UserProvider userProvider;
  late ServiceProvider serviceProvider;
  late FreelancerProvider freelancerProvider;
  late LocationProvider locationProvider;
  SearchResult<Service>? serviceResult;
  SearchResult<Location>? locationResult;
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  @override
  void initState() {
    userProvider = context.read<UserProvider>();
    serviceProvider= context.read<ServiceProvider>();
    freelancerProvider=context.read<FreelancerProvider>();
    locationProvider=context.read<LocationProvider>();
    _getLocations();
    super.initState();

    _initialValue = {
      'userId':widget.user?.userId.toString(),
      'firstName':widget.user?.firstName,
      'lastName':widget.user?.lastName,
      'email':widget.user?.email
    };

    initForm();
  }
  _getLocations() async{
    var fetchedLocations = await locationProvider.get();
    setState(() {
      locationResult = fetchedLocations;
    });
  }
  Future initForm() async {
    serviceResult = await serviceProvider.get();
    print("Fetched user first name: ${serviceResult?.result}");
    setState(() {
      
    });
  }
  @override
  Widget build(BuildContext context) {
    

      return Scaffold( body:
       Column(children: [
        _buildForm(),
        _save()
      ],),);

  }
  
  Widget _buildForm() {

    return FormBuilder(key: _formKey, initialValue: _initialValue,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 10,),
                Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "User ID"),
                  name: "userId",
                )),
                Expanded(child: FormBuilderTextField(
                  decoration: InputDecoration(labelText: "First Name"),
                  name: 'firstName',
                )),
                SizedBox(width: 10,),
                Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "Last name"),
                  name: "lastName",
                )),
                 SizedBox(width: 10,),
                Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "Email"),
                  name: "email",
                )),
                 SizedBox(width: 10,),
                Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "Bio"),
                  name: "bio",
                )),
                 SizedBox(width: 10,),
            
                 SizedBox(width: 10,),
             
                 SizedBox(width: 10,),
           
                SizedBox(width: 10,),
                Expanded(child: FormBuilderTextField(
                   decoration: InputDecoration(labelText: "ExperianceYears"),
                  name: "experianceYears",
                )),
                  SizedBox(width: 10,),
                  Expanded(child:  FormBuilderDropdown<int>(
            name: 'locationId',
            decoration: const InputDecoration(labelText: "Location"),
            items: locationResult?.result
                    .map((loc) => DropdownMenuItem(
                          value: loc.locationId,
                          child: Text(loc.locationName ?? ''),
                        ))
                    .toList() ??
                [],
          ))
                ,
                
              ],
            ),
             Row(
                       children: [
                          Expanded(
                            child:   FormBuilderCheckboxGroup<int>(
                              name: "serviceId",
                              decoration: InputDecoration(labelText: "Service"),
                              options: serviceResult?.result.map((item) => FormBuilderFieldOption<int>(value: item.serviceId ,child: Text(item.serviceName ?? ""),),).toList() ?? [],
                              )
                          ),
                        
                       ],
                    ),
                   Column(
                    children: [
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
                    FormBuilderDateTimePicker(
                      name: 'startTime',
                      decoration:
                          InputDecoration(labelText: "Početak radnog vremena."),
                      inputType: InputType.time,
                    ),
                    FormBuilderDateTimePicker(
                      name: 'endTime',
                      decoration:
                          InputDecoration(labelText: "Kraj radnog vremena"),
                      inputType: InputType.time,
                    )

                    ],

                   )
                  
          ],
        )
          
      
      )
    );
  }

  Widget _save() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BackButton(),
          ElevatedButton(
              onPressed: () {
                _formKey.currentState?.saveAndValidate();
                var formData = Map<String, dynamic>.from(
                    _formKey.currentState?.value ?? {});
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
                  formData["workingDays"] =
                      (formData["workingDays"] as List<String>)
                          .map((day) => dayMap[day])
                          .whereType<int>()
                          .toList();
                }


                
             
                
                debugPrint("Final form data: ${formData.toString()}");

                var selectedServices = formData["serviceId"];
                formData["serviceId"] = (selectedServices is List)
                    ? selectedServices
                        .map((id) => int.tryParse(id.toString()) ?? 0)
                        .toList()
                    : (selectedServices != null
                        ? [int.tryParse(selectedServices.toString()) ?? 0]
                        : []);
                debugPrint(_formKey.currentState?.value.toString());

                freelancerProvider.insert(formData);
              },
              child: Text("Save"))
        ],
      ),
    );
  }
  
}


