import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/tender_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class BookTender extends StatefulWidget {
  const BookTender({this.isFreelancer,this.tender,super.key});
  final bool? isFreelancer;
  final Job? tender;

  @override
  State<BookTender> createState() => _BookTenderState();
}

class _BookTenderState extends State<BookTender> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late JobProvider tenderProvider;
  late ServiceProvider serviceProvider;
  SearchResult<Service>? serviceResult;
  File? _image;
  String? _base64Image;
  Uint8List? _decodedImage;
 

  @override
  void initState() {
    super.initState();
       tenderProvider = context.read<JobProvider>();
      serviceProvider = context.read<ServiceProvider>();
      _initialValue={
        'jobDate': widget.tender?.jobDate,
        'jobDescription': widget.tender?.jobDescription,
        'jobTitle': widget.tender?.jobTitle,
        'isTenderFinalized': true,
        'serviceId': widget.tender?.jobsServices
               !.map((e) => e.serviceId)
    .whereType<int>() 
    .toList(),

        'userId': widget.tender?.user?.userId,
        'isFreelancer': widget.isFreelancer,
        'image':widget.tender?.image,
      };
      if (widget.tender?.image != null) {
    try {
      _decodedImage = base64Decode(widget.tender!.image!);
    } catch (_) {
      _decodedImage = null;
    }
  }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      
   
      await _getServices();
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

  Future<void> _getServices() async {
    try {
      final fetched = await serviceProvider.get();
      if(!mounted) return;
      setState(() {
        serviceResult = fetched;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri dohvatu servisa.")),
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values =  Map<String, dynamic>.from(_formKey.currentState!.value);
     values['serviceId'] = (values['serviceId'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
      final request = {
      "jobDate": (values['jobDate'] as DateTime).toIso8601String(),
      

        "jobDescription": capitalize( values['jobDescription']),
        "jobTitle":values['jobTitle'],
        "isTenderFinalized": true,
        "serviceId": values["serviceId"] ?? [],
        "userId": AuthProvider.user?.userId,
        'image':_image!=null?_base64Image:widget.tender?.image,
        "jobStatus": JobStatus.unapproved.name,
        "isFreelancer":widget.isFreelancer,
        "isInvoiced": false,
        "isRated": false,
      };
      if(widget.tender==null) {
        try {
        await tenderProvider.insert(request);
    
        
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tender je uspešno objavljen")),
        );
           Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška prilikom slanja tendera: $e")),
        ); 
        Navigator.pop(context);
      }
      }
      else{
        try{
          await tenderProvider.update(widget.tender!.jobId, request);
       
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tender je uspešno izmjenjen")),
            
          );
          Navigator.pop(context);
        } catch (e) {
          if(!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Greška prilikom izmjene tendera. Pokušajte ponovo.")),
          );
         
        }
         Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final serviceOptions = serviceResult?.result
            .map((s) => FormBuilderFieldOption<int>(
                  value: s.serviceId,
                  child: Text(s.serviceName ?? ''),
                ))
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(title: widget.tender==null?  Text('Kreiraj tender',
      style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: Color.fromRGBO(27, 76, 125, 25),letterSpacing: 1.2),): Text('Izmjeni tender',
      style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: Color.fromRGBO(27, 76, 125, 25),letterSpacing: 1.2),),
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
              Text('Posao i servis',style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
                                const SizedBox(height: 10),
              
              FormBuilderTextField(
                name: "jobTitle",
                decoration: const InputDecoration(
                  labelText: 'Naslov posla',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),

                
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(25, errorText: 'Maksimalno 25 znakova'),
                  FormBuilderValidators.minLength(3, errorText: 'Minimalno 3 znaka'),
                     (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ\s]+$'); 
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova';
      }
      return null;
    },
                ]),
              ),
              const SizedBox(height: 20,),
               FormBuilderTextField(
                name: "jobDescription",
                decoration: const InputDecoration(
                  labelText: 'Opis posla',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                         FormBuilderValidators.maxLength(230, errorText: 'Maksimalno 230 znakova'),
                  FormBuilderValidators.minLength(10, errorText: 'Minimalno 10 znaka'),
                     (value) {
      if (value == null || value.isEmpty) return null;
      final regex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ0-9\s.]+$');
      if (!regex.hasMatch(value)) {
        return 'Dozvoljena su samo slova i brojevi';
      }
      return null;
    },
                ]),
              ),     SizedBox(height: 20,),
                FormBuilderCheckboxGroup<int>(
                name: "serviceId",
                decoration: const InputDecoration(labelText: "Servisi",
                border: OutlineInputBorder()),
                options: serviceOptions,
                validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
              ),
              const SizedBox(height: 15),
               
               Text('Rezervacija',style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
              const SizedBox(height: 15),

              FormBuilderDateTimePicker(
                name: "jobDate",
                initialDate: DateTime.now().add(const Duration(days: 5)),
                firstDate: DateTime.now().add(const Duration(days: 5)),
                inputType: InputType.date,
                

            
                decoration: const InputDecoration(
                  labelText: "Datum posla",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
              ),
              
              const SizedBox(height: 15),
                 Text('Slika',style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
              const SizedBox(height: 15),

            FormBuilderField(
  name: "image",
  builder: (field) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Slika",
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
                : widget.tender?.image != null
                    ? const Text('Proslijeđena slika')
                    : const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label: _image == null && widget.tender?.image == null
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
             
             
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor:const Color.fromRGBO(27, 76, 125, 25)),
                  onPressed: _submit,
                  child: widget.tender==null? const Text("Objavi tender",style: TextStyle(color: Colors.white),):const Text("Izmjeni tender",style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
