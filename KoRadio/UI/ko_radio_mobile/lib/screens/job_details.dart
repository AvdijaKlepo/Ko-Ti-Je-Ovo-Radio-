import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
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
  late UserRatings userRatingsProvider;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    freelancerProvider = context.read<FreelancerProvider>();
    userRatingsProvider = context.read<UserRatings>();
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
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Detalji posla'),
                  _buildDetailRow('Servis(i)', widget.job.jobsServices
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

                  const Divider(height: 32),
                  _sectionTitle('Podaci radnika'),
                  _buildDetailRow(
                    'Ime i prezime',
                    widget.job.user != null
                        ? '${widget.job.freelancer?.freelancerNavigation?.firstName ?? ''} ${widget.job.freelancer?.freelancerNavigation?.lastName ?? ''}'
                        : 'Nepoznato',
                  ),
                  _buildDetailRow('E-mail', widget.job.freelancer?.freelancerNavigation?.email ?? 'Nepoznato'),

                  const Divider(height: 32),
                  _buildDetailRow('Procijenjena cijena',
                      widget.job.payEstimate?.toStringAsFixed(2) ?? 'Nije unesena'),
                  _buildDetailRow('Konačna cijena',
                      widget.job.payInvoice?.toStringAsFixed(2) ?? 'Nije unesena'),

                  const SizedBox(height: 30),
                  if (widget.job.jobStatus == JobStatus.finished &&
                      widget.job.user?.userId == AuthProvider.user?.userId)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => PaypalCheckoutView(
                                  sandboxMode: true,
                                 clientId: "client", 
          secretKey: "Wow",
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Plaćanje je uspješno izvršeno!")),
                                    );
                                    Navigator.of(context).pop();
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
                        Text("Ocijenite radnika:", style: Theme.of(context).textTheme.titleMedium),
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
                          onRatingUpdate: (rating) async {
                            setState(() {
                              _rating = rating;
                            });
                           
                            
                          },

                        ),
                         ElevatedButton(onPressed: () async{
                                 final dayMap = {
  'Nedjelja': 0, 'Ponedjeljak': 1, 'Utorak': 2, 'Srijeda': 3,
  'Četvrtak': 4, 'Petak': 5, 'Subota': 6
};

var workingDaysStringList = widget.job.freelancer?.workingDays as List<String>? ?? [];

final workingDaysIntList = workingDaysStringList
    .map((day) => dayMap[day])
    .whereType<int>()
    .toList();
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
    "roles": [10,11],
    "isApplicant": false,
    "isDeleted": false,
  });
  await userRatingsProvider.insert({
    "userId": AuthProvider.user?.userId,
    "freelancerId": widget.job.freelancer?.freelancerId,
    "jobId": widget.job.jobId,
    "rating": _rating,
  });
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Radnik odobren.!")),
    
  );
 
                          
                        }, child: Text("Ocijeni"))
                      
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
