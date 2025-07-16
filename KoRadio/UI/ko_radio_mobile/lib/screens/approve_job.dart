import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class ApproveJob extends StatefulWidget {
  const ApproveJob({required this.job, required this.freelancer, super.key});
  final Job job;
  final Freelancer freelancer;

  @override
  State<ApproveJob> createState() => _ApproveJobState();
}

class _ApproveJobState extends State<ApproveJob> {
  late JobProvider jobProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      jobProvider = context.read<JobProvider>();
    });
  }
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white), 
      ),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors. white),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildImageRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: value,
          ),
        ],
      ),
    );
  }
  _openImageDialog() {
    return AlertDialog(
      backgroundColor: Color.fromRGBO(27, 76, 125, 25),
      title: const Text('Proslijeđena slika',style: TextStyle(color: Colors.white),),
      content: imageFromString(widget.job.image!),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),))
      ],
    );
  }
  _openCancelDialog() {
    return AlertDialog(
      backgroundColor: Color.fromRGBO(27, 76, 125, 25),
      title: const Text('Odbaci posao',style: TextStyle(color: Colors.white),),
      content: const Text('Jeste li sigurni da želite da otkažete ili odbijete ovaj posao?',style: TextStyle(color: Colors.white),),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),)),
            TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () async {
                var jobUpdateRequest = {
                "userId": widget.job.user?.userId,
                "freelancerId": widget.job.freelancer?.freelancerId,
                "companyId": null,
                "jobTitle": widget.job.jobTitle,
                "isTenderFinalized": false,
                "isFreelancer": true,
                "isInvoiced": false,
                "isRated": false,
                "startEstimate": widget.job.startEstimate,
                "endEstimate": null,  
                "payEstimate": null,
                "payInvoice": null,
                "jobDate": widget.job.jobDate.toUtc().toIso8601String(),
                "dateFinished": null,
                "jobDescription": widget.job.jobDescription,
                "image": widget.job.image,
                "jobStatus": JobStatus.cancelled.name,
                "serviceId": widget.job.jobsServices
                        ?.map((e) => e.service?.serviceId)
                        .toList(),
          };
              try {
            jobProvider.update(widget.job.jobId,
            jobUpdateRequest
            );
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posao odbijen.')));
               int count = 0;
            Navigator.of(context).popUntil((_) => count++ >= 2);
          } on Exception catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška tokom slanja: ${e.toString()}')));
               int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);

          }
            },
            child: const Text("Odbaci",style: TextStyle(color: Colors.white),),
            ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormBuilderState>();
    return Scaffold(
      
      appBar: AppBar(title:  Text('${widget.job.jobTitle}',style: Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.normal,
      letterSpacing: 1.2,

    ),),
      centerTitle: true,
   

    
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        'Detalji posla',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black), 
      ),
    ),
                Card(
                color: const Color.fromRGBO(27, 76, 125, 25),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      _sectionTitle('Zakazan posao'),
                        _buildDetailRow('Posao', widget.job.jobTitle?? 'Nije dostupan'), 
                      _buildDetailRow('Servis', widget.job.jobsServices
                              ?.map((e) => e.service?.serviceName)
                              .where((e) => e != null)
                              .join(', ') ??
                          'N/A'),
                      _buildDetailRow('Datum', DateFormat('dd.MM.yyyy').format(widget.job.jobDate)),
                      _buildDetailRow('Vrijeme početka', widget.job.startEstimate ?? ''),
                      _buildDetailRow('Vrijeme završetka', widget.job.endEstimate ?? ''),
                      _buildDetailRow('Procijena cijene', widget.job.payEstimate?.toString() ?? ''),
                        _buildDetailRow('Opis posla', widget.job.jobDescription),
                        widget.job.image!=null ?
                        _buildImageRow(
                                  'Slika',
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(context: context, builder: (context) => _openImageDialog());
                                    
                                    
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child:  const Text(
                                      'Otvori sliku',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(27, 76, 125, 25)),
                                    ),
                                  ))
                              : const SizedBox(height: 20),
                
                      const Divider(height: 32),
                      _sectionTitle('Korisnički podaci'),
                      _buildDetailRow(
                        'Ime i prezime',
                        widget.job.user != null
                            ? '${widget.job.user?.firstName ?? ''} ${widget.job.user?.lastName ?? ''}'
                            : 'Nepoznato',
                      ),
                      _buildDetailRow('Email', widget.job.user?.email ?? 'Nepoznato'),
                       _buildDetailRow('Telefonski broj', widget.job.user?.phoneNumber ?? 'Nepoznato'),
                        _buildDetailRow(
                        'Lokacija',
                        widget.job.user != null
                            ? '${widget.job.user?.location?.locationName ?? '-'}'
                            : 'Nepoznato',
                      ),
                      _buildDetailRow(
                        'Adresa stanovanja',
                        widget.job.user != null
                            ? '${widget.job.user?.address}'
                            : 'Nepoznato',
                      ),
                      
                           
                    ],
                    
                
                  ),
                
                ),
                ),
                _buildFreelancerJobView(),
                Padding(padding: const EdgeInsets.all(8.0)
                ,child:  Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     ElevatedButton(onPressed: () {
                      showDialog(context: context, builder: (context) => _openCancelDialog());
                     


             
          },style: ElevatedButton.styleFrom(backgroundColor:  Colors.red,elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),), child:  const Text('Odbaci',style: TextStyle(color: Colors.white),),),
          const SizedBox(width: 15,),
             ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(27, 76, 125, 25),elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
            onPressed: () async {
               final isValid =
                        _formKey.currentState?.saveAndValidate() ?? false;
          
                    if (!isValid) {
                      return;
                    }
                    
          
                    var values = Map<String, dynamic>.from(
                        _formKey.currentState?.value ?? {});
                        if (values["endEstimate"] is DateTime) {
            final dateTime = values["endEstimate"] as DateTime;
            final formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
            values["endEstimate"] = formattedTime;
          }
          
              var jobUpdateRequest = {
                "userId": widget.job.user?.userId,
                "freelancerId": widget.job.freelancer?.freelancerId,
                "companyId": null,
                "jobTitle": widget.job.jobTitle,
                "isTenderFinalized": false,
                "isFreelancer": true,
                "isInvoiced": false,
                "isRated": false,
                "startEstimate": widget.job.startEstimate,
                "endEstimate": widget.job.jobStatus== JobStatus.unapproved ? values["endEstimate"] : widget.job.endEstimate,  
                "payEstimate": widget.job.jobStatus== JobStatus.unapproved ? values["payEstimate"] : widget.job.payEstimate,
                "payInvoice": widget.job.jobStatus== JobStatus.unapproved ? null : values["payInvoice"],
                "jobDate": widget.job.jobDate.toUtc().toIso8601String(),
                "dateFinished": null,
                "jobDescription": widget.job.jobDescription,
                "image": widget.job.image,
                "jobStatus": widget.job.jobStatus== JobStatus.unapproved ? JobStatus.approved.name : JobStatus.finished.name,
                "serviceId": widget.job.jobsServices
                        ?.map((e) => e.service?.serviceId)
                        .toList(),
          };
              try {
            jobProvider.update(widget.job.jobId,
            jobUpdateRequest
            );
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faktura poslana korisniku.')));
            Navigator.pop(context,true);

          } on Exception catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška u slanju posla: ${e.toString()}')));
            Navigator.pop(context, false);

          }
            },
            child: const Text('Prihvati',style: TextStyle(color: Colors.white),),
          ),
        
                  ],
                )),
               
              ],
            ),
            ),
          ],
        ),
      ),
    
    );
  }

  Widget _buildFreelancerJobView() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
      padding: const EdgeInsets.all(  12),
      child: Text(
        'Potrebni podaci',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black), 
      ),
    ),
       
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(8.0),
          child:  Column(
              children: [
                if(widget.job.jobStatus == JobStatus.unapproved)
                Column(
                  children: [
                    FormBuilderDateTimePicker(
                      name: "endEstimate",
                      inputType: InputType.time,
                      decoration: const InputDecoration(
                        labelText: 'Trajanje posla',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      validator: FormBuilderValidators.required(
                          errorText: 'Obavezno polje'),
                    ),
                    const SizedBox(height: 15),
                    FormBuilderTextField(
                      name: "payEstimate",
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Moguća Cijena',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                        ]
                      ),
                      valueTransformer: (value) => double.tryParse(value ?? ''),
                    ),
                  ],
                ),
                if (widget.job.jobStatus == JobStatus.approved)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      FormBuilderTextField(
                        name: "payInvoice",
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Finalna cijena',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                         validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                        ]
                      ),
                      valueTransformer: (value) => double.tryParse(value ?? ''),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        
      ],
    );
  }

  Widget _buildInfoRow(String label, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87),
          children: [
            TextSpan(
                text: text,
                style: const TextStyle(fontWeight: FontWeight.normal))
          ],
        ),
      ),
    );
  }
}
