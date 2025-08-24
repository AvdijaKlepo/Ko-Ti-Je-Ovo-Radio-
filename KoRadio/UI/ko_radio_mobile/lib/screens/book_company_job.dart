import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:provider/provider.dart';

class BookCompanyJob extends StatefulWidget {
  const BookCompanyJob(this.c,this.selectedDay,{super.key});
  final Company c;
  final DateTime selectedDay;

  @override
  State<BookCompanyJob> createState() => _BookCompanyJobState();
}

class _BookCompanyJobState extends State<BookCompanyJob> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  DateTime? _currentJobDate;
  late Set<int> _workingDayInts;

  var _userId = AuthProvider.user?.userId;

  final Map<String, int> _dayStringToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };

  late CompanyProvider companyProvider;
  late JobProvider jobProvider;

  SearchResult<Service>? serviceResult;
  SearchResult<Company>? companyResult;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      companyProvider = context.read<CompanyProvider>();
      jobProvider = context.read<JobProvider>();
    
    });
  _workingDayInts = widget.c.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
    _currentJobDate = widget.selectedDay;
    _initialValue = {
      'jobDate': widget.selectedDay,
    };
  }
  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text('Rezerviši posao',style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: Color.fromRGBO(27, 76, 125, 25),letterSpacing: 1.2),),
      centerTitle: true,
      scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rezervacije za ${widget.selectedDay.toIso8601String().split('T')[0]}'),
              const SizedBox(height: 6),
               FormBuilderTextField(
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "Obavezno polje"),
                   (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ\s]+$'); 
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova';
      }
      return null;
    },
                  ]),
                      name: "jobTitle",
                      decoration: const InputDecoration(
                        labelText: 'Naslov posla',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                   
                    ),  
                    const SizedBox(height: 15,),
                    const ExpansionTile(initiallyExpanded: false,title: Text('Napomena'),
                    children: [
  Text('Datum rezervacije sa firmom ne predstavlja uslov početka rada na isti. U slučaju prihvaćanja zahtjeva, firma će vratiti procjenu roka završetka radova.',
                    style: TextStyle(fontSize: 12),),
                    ]
                  
                    )
                    ,
                    const SizedBox(height: 15,),
                FormBuilderDateTimePicker(
                  validator: FormBuilderValidators.required(errorText: "Obavezno polje"),
                      decoration: const InputDecoration(
                        labelText: 'Datum rezervacije',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      name: "jobDate",
                      inputType: InputType.date,
                      firstDate: DateTime.now(),
                      selectableDayPredicate: _isWorkingDay,
                      onChanged: (value) async {
                        setState(() {
                          _currentJobDate = value;
                         
                        });

                       


                        
                      },
                    ),
                  const SizedBox(height: 15,),
               FormBuilderTextField(
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "Obavezno polje"),
                   (value) {
      if (value == null || value.isEmpty) return null;
       final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ0-9\s]+$');

      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova i brojevi';
      }
      return null;
    },
                  ]),
                      name: "jobDescription",
                      decoration: const InputDecoration(
                        labelText: 'Opis problema',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                      const SizedBox(height: 15),
                    FormBuilderCheckboxGroup<int>(
                      name: "serviceId",
                      validator: (value) => value == null || value.isEmpty ? "Odaberite barem jednu uslugu" : null,
                      decoration: const InputDecoration(
                        labelText: "Servis",
                        border: InputBorder.none,

                      ),
                      options: widget.c?.companyServices
                              ?.map(
                                (item) => FormBuilderFieldOption<int>(
                                  value: item.service!.serviceId,
                                  child: Text(item.service?.serviceName ?? ""),
                                ),
                              )
                              .toList() ??
                          [],
                    ),
                    const SizedBox(height: 15),
                    FormBuilderField(
  name: "image",
  builder: (field) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Proslijedite sliku problema",
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
                : const Text("Nema izabrane slike"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(27, 76, 125, 1),
                textStyle: const TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image==null? const Text("Odaberi", style: TextStyle(color: Colors.white)): const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () => getImage(field),
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
            ),
        ],
      ),
    );
  },
),
              
            ],
          ),
        ),
      ),
      bottomNavigationBar: _save(),
      
    );
  }
  File? _image;
  String? _base64Image;

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

  Widget _save() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(27, 76, 125, 25),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
              onPressed: () async {
                
                
          
           final isValid = _formKey.currentState?.saveAndValidate() ?? false;

  if (!isValid) {
  
    return;
  }
           
            
                var formData = Map<String, dynamic>.from(
                    _formKey.currentState?.value ?? {});

        

                if (formData["jobDate"] is DateTime) {
                  formData["jobDate"] =
                      (formData["jobDate"] as DateTime).toIso8601String();
                }

                if (_base64Image != null) {
                  formData['image'] = _base64Image;
                }
              
          

             
                var selectedServices = formData["serviceId"];
                formData["serviceId"] = (selectedServices is List)
                    ? selectedServices
                        .map((id) => int.tryParse(id.toString()) ?? 0)
                        .toList()
                    : (selectedServices != null
                        ? [int.tryParse(selectedServices.toString()) ?? 0]
                        : []);
                  var jobInsertRequest = {
                  "userId": _userId,
                  "freelancerId": null,
                  "companyId": widget.c.companyId,
                  "jobTitle": formData["jobTitle"],
                  "isTenderFinalized": false,
                  "isFreelancer": false,
                  "isInvoiced": false,
                  "isRated": false,
                  "startEstimate": null,
                  "endEstimate": null,
                  "payEstimate": null,
                  "payInvoice": null,
                  "jobDate": formData["jobDate"],
                  "dateFinished": null,
                  "jobDescription": formData["jobDescription"],
                  "image": formData["image"],
                  "jobStatus": JobStatus.unapproved.name,
                  "serviceId": formData["serviceId"]
                };

       
              try{
               
                await jobProvider.insert(jobInsertRequest);
                int count = 0;
                if(!mounted) return;
                 Navigator.of(context).popUntil((_) => count++ >= 3);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Zahtjev proslijeđen firmi!")));
              }
              catch(e){
                print(e);

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Greška u slanju zahtjeva. Molimo pokušajte ponovo.")));
              }


           },
              child: const Text("Sačuvaj",style: TextStyle(color: Colors.white),))
        ],
      ),
    );
  }
}