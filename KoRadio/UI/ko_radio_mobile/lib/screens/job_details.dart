import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/user_ratings.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';

class JobDetails extends StatefulWidget {
  final Job job;

  const JobDetails({super.key, required this.job});

  @override
  State<JobDetails> createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {
  late FreelancerProvider freelancerProvider;
  late CompanyProvider companyProvider;
  late JobProvider jobProvider;
  late UserRatings userRatingsProvider;
  SearchResult<Company>? companyResult;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    freelancerProvider = context.read<FreelancerProvider>();
    userRatingsProvider = context.read<UserRatings>();
    jobProvider = context.read<JobProvider>();
    companyProvider = context.read<CompanyProvider>();
    _getCompany();
  }
  Future<void> _getCompany() async {
    var result = await companyProvider.getById(widget.job.company?.companyId);
    if (result.result.isNotEmpty) {
      companyResult = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: appBar(title: 'Detalji posla', automaticallyImplyLeading: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Color.fromRGBO(27, 76, 125, 25),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Detalji posla'),
                  _buildDetailRow('Posao', widget.job.jobTitle?? 'Nije dostupan'), 
                  _buildDetailRow('Servis', widget.job.jobsServices
                          ?.map((e) => e.service?.serviceName)
                          .where((e) => e != null)
                          .join(', ') ??
                      'N/A'),
                  _buildDetailRow('Datum', dateFormat.format(widget.job.jobDate)),
                  _buildDetailRow('Vrijeme početka', widget.job.startEstimate ?? ''),
                  _buildDetailRow('Vrijeme završetka',
                      widget.job.endEstimate ?? 'Nije dostupno'),
                  _buildDetailRow('Opis posla', widget.job.jobDescription ?? 'Nema opisa'),

                  const Divider(height: 32),
                  _sectionTitle('Korisnički podaci'),
                  _buildDetailRow(
                    'Ime i prezime',
                    widget.job.user != null
                        ? '${widget.job.user?.firstName ?? ''} ${widget.job.user?.lastName ?? ''}'
                        : 'Nepoznato',
                  ),
                  _buildDetailRow(
                    'Adresa stanovanja',
                    widget.job.user != null
                        ? '${widget.job.user?.firstName ?? ''} ${widget.job.user?.lastName ?? ''}'
                        : 'Nepoznato',
                  ),

                  const Divider(height: 32),
                  widget.job.freelancer != null ?
                  _sectionTitle('Podaci radnika') : _sectionTitle('Podaci Firme'),
                  widget.job.freelancer != null ?
                  _buildDetailRow(
                    'Ime i prezime',
                    widget.job.user != null
                        ? '${widget.job.freelancer?.freelancerNavigation?.firstName ?? ''} ${widget.job.freelancer?.freelancerNavigation?.lastName ?? ''}'
                        : 'Nepoznato',
                  ) : _buildDetailRow('Naziv Firme', widget.job.company?.companyName ?? 'Nepoznato'),
                  widget.job.freelancer != null ?
                  _buildDetailRow('E-mail', widget.job.freelancer?.freelancerNavigation?.email ?? 'Nepoznato'):
                  _buildDetailRow('E-mail', widget.job.company?.email ?? 'Nepoznato'),
                   widget.job.freelancer != null ?
                  _buildDetailRow('Telefonski broj', widget.job.freelancer?.freelancerNavigation?.phoneNumber ?? 'Nepoznato') : 
                   _buildDetailRow('Telefonski broj', widget.job.company?.phoneNumber ?? 'Nepoznato'),
                  const Divider(height: 32),
                  _buildDetailRow('Procijenjena cijena',
                      widget.job.payEstimate?.toStringAsFixed(2) ?? 'Nije unesena'),
                  _buildDetailRow('Konačna cijena',
                      widget.job.payInvoice?.toStringAsFixed(2) ?? 'Nije unesena'),
                      if(widget.job.isInvoiced==true)
                  _buildDetailRow('Plaćen',
                      'Da'), 
                       if(widget.job.isRated==true)
                  _buildDetailRow('Ocijenjen',
                      'Da'), 
                     if(widget.job.jobStatus== JobStatus.cancelled) 
                       _buildDetailRow('Otkazan',
                      'Da'), 

                  const SizedBox(height: 30),
                  
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.job.jobStatus == JobStatus.finished &&
                      widget.job.user?.userId == AuthProvider.user?.userId
                      && widget.job.isInvoiced==false)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => PaypalCheckoutView(
                                  sandboxMode: true,
                                 clientId: "wow", 
          secretKey: "wow",
          
                                  transactions: [
                                    {
                                      "amount": {
                                        "total": widget.job.payInvoice?.toStringAsFixed(2) ?? "10.00",
                                        "currency": "USD",
                                        "details": {
                                          "subtotal":
                                              widget.job.payInvoice?.toStringAsFixed(2) ?? "10.00",
                                          "shipping": '0',
                                          "shipping_discount": 0
                                        }
                                      },
                                      "description": "Plaćanje za uslugu",
                                      "item_list": {
                                        "items": [
                                          {
                                            "name": "Usluga",
                                            "quantity": 1,
                                            "price": widget.job.payInvoice?.toStringAsFixed(2) ?? "10.00",
                                            "currency": "USD"
                                          }
                                        ],
                                      }
                                    }
                                  ],
                                  note: "Hvala što koristite našu aplikaciju!",
                                  onSuccess: (Map params) async {
                                    var request ={
                                       'jobTitle':widget.job.jobTitle,
                 'endEstimate':widget.job.endEstimate,
                  'payEstimate': widget.job.payEstimate,
                  'freelancerId': widget.job.freelancer?.freelancerId,
                  'companyId': widget.job.company?.companyId,
                  'startEstimate': widget.job.startEstimate,
                  'userId': widget.job.user?.userId,
                  'serviceId': widget.job.jobsServices
                      ?.map((e) => e.service?.serviceId)
                      .toList(),
                  'jobDescription': widget.job.jobDescription,
                  'image': widget.job.image,
                  'jobDate': widget.job.jobDate.toIso8601String(),
                  'IsTenderFinalized':false,
                  'payInvoice': widget.job.payInvoice,
                  'isinvoiced':true,
                  'isRated':false,
                  'dateFinished': widget.job.dateFinished,
                
           
                  'jobStatus': JobStatus.finished.name,

                                    };
                                    try{
                                      jobProvider.update(widget.job.jobId,
                                      request
                                      );
ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Plaćanje je uspješno izvršeno!")),
                                    );
                                    Navigator.of(context).pop();
                                    }
                                    catch(e){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Greška tokom plaćanja")),
                                      );
                                      Navigator.of(context).pop();
                                    }
                                    
                                  },
                                  onCancel: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Plaćanje je otkazano.")),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  onError: (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Greška tokom plaćanja.")),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          },
                          child: const Text("Plati PayPal-om"),
                        ),
                         
                        const SizedBox(height: 20),
                       if (widget.job.isInvoiced == true &&
    widget.job.user?.userId == AuthProvider.user?.userId &&
    widget.job.isRated == false)
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.job.freelancer != null ? Text("Ocijenite radnika:", style: Theme.of(context).textTheme.titleMedium) : Text("Ocijenite firmu:", style: Theme.of(context).textTheme.titleMedium),
      
        const SizedBox(height: 8),
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final dayMap = {
              'Nedjelja': 0, 'Ponedjeljak': 1, 'Utorak': 2, 'Srijeda': 3,
              'Četvrtak': 4, 'Petak': 5, 'Subota': 6
            };

            var workingDaysStringList = widget.job.freelancer?.workingDays as List<String>? ?? [];

            final workingDaysIntList = workingDaysStringList
                .map((day) => dayMap[day])
                .whereType<int>()
                .toList();
            widget.job.freelancer?.freelancerId!= null ? 
            await freelancerProvider.update(
              widget.job.freelancer?.freelancerId ?? 0,
              {
                "freelancerId": widget.job.freelancer?.freelancerId,
                "bio": widget.job.freelancer?.bio,
                "rating": _rating,
                "experianceYears": widget.job.freelancer?.experianceYears,
                "startTime": widget.job.freelancer?.startTime,
                "endTime": widget.job.freelancer?.endTime,
                "workingDays": widget.job.freelancer?.workingDays,
                "serviceId": widget.job.freelancer?.freelancerServices.map((e) => e.serviceId).toList(),
                "roles": [10, 11],
                "isApplicant": false,
                "isDeleted": false,
              },
            ) :
            await companyProvider.update(
              widget.job.company?.companyId ?? 0,
              {
                "companyId": widget.job.company?.companyId,
                "companyName": widget.job.company?.companyName,
                "email": widget.job.company?.email,
                "phoneNumber": widget.job.company?.phoneNumber,
                "bio": widget.job.company?.bio,
                "rating": _rating,
                "experianceYears": widget.job.company?.experianceYears,
                "startTime": widget.job.company?.startTime,
                "endTime": widget.job.company?.endTime,
                "workingDays": widget.job.company?.workingDays,
                "serviceId": widget.job.company?.companyServices.map((e) => e.serviceId).toList(),
                "employee": null,
                "isApplicant": false,
                "isDeleted": false,
                'locationId': widget.job.company?.locationId,
              });

            await userRatingsProvider.insert({
              "userId": AuthProvider.user?.userId,
              "freelancerId": widget.job.freelancer?.freelancerId,
              "jobId": widget.job.jobId,
              "rating": _rating,
              "companyId": widget.job.company?.companyId,
            });

            var request = {
              'jobTitle': widget.job.jobTitle,
              'endEstimate': widget.job.endEstimate,
              'payEstimate': widget.job.payEstimate,
              'freelancerId': widget.job.freelancer?.freelancerId,
              'companyId': widget.job.company?.companyId,
              'dateFinished': widget.job.dateFinished,
              'startEstimate': widget.job.startEstimate,
              'userId': widget.job.user?.userId,
              'serviceId': widget.job.jobsServices?.map((e) => e.service?.serviceId).toList(),
              'jobDescription': widget.job.jobDescription,
              'image': widget.job.image,
              'jobDate': widget.job.jobDate.toIso8601String(),
              'IsTenderFinalized': false,
              'payInvoide': widget.job.payInvoice,
              'isinvoiced': true,
              'isRated': true,
              'jobStatus': JobStatus.finished.name,
            };

            await jobProvider.update(widget.job.jobId, request);

            ScaffoldMessenger.of(context).showSnackBar(
              widget.job.freelancer != null ? const SnackBar(content: Text("Radnik ocijenjen!")) : const SnackBar(content: Text("Firma ocijenjen!")),
             
            );
          },
          child: const Text("Ocijeni"),
        ),
      ],
    ),
  ),

                     
                      
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white), 
      ),
    );
  }
}
