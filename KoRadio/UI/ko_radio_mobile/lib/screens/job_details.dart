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
import 'package:ko_radio_mobile/providers/messages_provider.dart';
import 'package:ko_radio_mobile/providers/user_ratings.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  late Company companyResult;
  late Job jobResult;
  late MessagesProvider messagesProvider;
  bool _isLoading = false;
  
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading=true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      messagesProvider = context.read<MessagesProvider>();
      freelancerProvider = context.read<FreelancerProvider>();
      userRatingsProvider = context.read<UserRatings>();
      jobProvider = context.read<JobProvider>();
      companyProvider = context.read<CompanyProvider>();
      if(widget.job.company?.companyId!=null)
      {
       await _getCompany();
      }
      await _getJob();
       setState(() {
      _isLoading=false;
    });
    });
   
  
  }
  Future<void> _getJob() async {
    setState(() {
      _isLoading=true;
    });
  
    try {
      var fetchedJob = await jobProvider.getById(widget.job.jobId);
      setState(() {
        jobResult = fetchedJob;
        _isLoading=false;
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  Future<void> _getCompany() async {
     try {
    var fetchedCompany = await companyProvider.getById(widget.job.company?.companyId ??  0);
    setState(() {
      companyResult = fetchedCompany;
    });
  } catch (e) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
  }
   _openCancelDialog() {
    return AlertDialog(
      backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
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
          var messageRequest = {
                'message1': "Posao ${widget.job.jobTitle} zakazan za  ${DateFormat('dd-MM-yyyy').format(widget.job.jobDate)} je oktazan od strane korisnika ${widget.job.user?.firstName} ${widget.job.user?.lastName}",
                'userId': widget.job.freelancer?.freelancerId,
                'createdAt': DateTime.now().toIso8601String(),
                'isOpened': false,
              };
              try{
                await messagesProvider.insert(messageRequest);
              } on Exception catch (e) {
                if(!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška tokom slanja notifikacije: ${e.toString()}')));
              }
              try {
            jobProvider.update(widget.job.jobId,
            jobUpdateRequest
            );
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posao odbijen.')));
            
            Navigator.pop(context,true);
          } on Exception catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška tokom slanja: ${e.toString()}')));
               
         Navigator.pop(context,true);

          }
            },
            child: const Text("Odbaci",style: TextStyle(color: Colors.white),),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    if(_isLoading==true){
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: appBar(title: 'Detalji posla', automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: const Color.fromRGBO(27, 76, 125, 25),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Radne specifikacije'),
                  _buildDetailRow('Posao', widget.job.jobTitle?? 'Nije dostupan'), 
                  _buildDetailRow('Servis', widget.job.jobsServices
                          ?.map((e) => e.service?.serviceName)
                          .where((e) => e != null)
                          .join(', ') ??
                      'N/A'),
                  _buildDetailRow('Datum', dateFormat.format(widget.job.jobDate)),
                  widget.job.freelancer?.freelancerId!=null ?
                  _buildDetailRow('Vrijeme početka', widget.job.startEstimate.toString().substring(0,5) ?? ''):
                  _buildDetailRow('Datum završetka radova', dateFormat.format(widget.job.dateFinished?? DateTime.now())),
                  if(widget.job.freelancer?.freelancerId!=null)
                  _buildDetailRow('Vrijeme završetka',
                  widget.job.endEstimate!=null ?
                      widget.job.endEstimate.toString().substring(0,5) : 'Nije popunjeno'),
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
                              : _buildDetailRow('Slika','Nije unesena'),

                  _buildDetailRow('Stanje', widget.job.jobStatus==JobStatus.unapproved ? 'Posao još nije odoboren' : 'Odobren posao'), 

                  const Divider(height: 32),
                  _sectionTitle('Korisnički podaci'),
                  _buildDetailRow(
                    'Ime i prezime',
                    widget.job.user != null
                        ? '${widget.job.user?.firstName ?? ''} ${widget.job.user?.lastName ?? ''}'
                        : 'Nepoznato',
                  ),
                   _buildDetailRow('Broj Telefona', widget.job.user?.phoneNumber??'Nepoznato'),
                   _buildDetailRow('Lokacija', widget.job.user?.location?.locationName??'Nepoznato'),
                  _buildDetailRow(
                    'Adresa',
                    widget.job.user != null
                        ? '${widget.job.user?.address}'
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
                  _buildDetailRow('Procijena',
                      widget.job.payEstimate?.toStringAsFixed(2) ?? 'Nije unesena'),
                  _buildDetailRow('Konačna cijena',
                      widget.job.payInvoice?.toStringAsFixed(2) ?? 'Nije unesena'),
                       if(widget.job.jobStatus== JobStatus.cancelled) 
                       _buildDetailRow('Otkazan',
                      'Da'), 
                      if(widget.job.jobStatus== JobStatus.finished)
                      _buildDetailRow('Završen','Da'),
                      if(jobResult.isInvoiced==true)
                  _buildDetailRow('Plaćen',
                      'Da')
                      else
                        _buildDetailRow('Plaćen',
                        'Ne')
                      , 
                       if(jobResult.isRated==true)
                  _buildDetailRow('Ocijenjen',
                      'Da')
                      else
                      _buildDetailRow('Ocijenjen',
                        'Ne')
                      ,
                 

                  const SizedBox(height: 30),
                  
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if(widget.job.jobStatus==JobStatus.unapproved || (widget.job.jobStatus==JobStatus.approved && 
                        DateTime.now().toIso8601String().split('T')[0]!=widget.job.jobDate.toIso8601String().split('T')[0]))
                        ElevatedButton(onPressed: () {
                      showDialog(context: context, builder: (context) => _openCancelDialog());
                     


             
          },style: ElevatedButton.styleFrom(backgroundColor:  Colors.red,elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),), child:  const Text('Odbaci',style: TextStyle(color: Colors.white),),),


                        if (jobResult.jobStatus == JobStatus.finished &&
                      widget.job.user?.userId == AuthProvider.user?.userId
                      && jobResult.isInvoiced==false)
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => PaypalCheckoutView(

                                  sandboxMode: true,
                                 clientId: dotenv.env['clientId'],
          secretKey: dotenv.env['secretKey'],
          
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
                  'payInvoice': jobResult?.payInvoice,
                  'isinvoiced':true,
                  'isRated':false,
                  'dateFinished': widget.job.dateFinished,
                
           
                  'jobStatus': JobStatus.finished.name,

                                    };
                                    try{
                                     await jobProvider.update(widget.job.jobId,
                                      request
                                      );
                                     
                                   
ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Plaćanje je uspješno izvršeno!")), 

                                     
                                      
                                    );
                                  
                                    Navigator.of(context).pop();
                                       
                                       await _getJob();

                                       setState(() {
                                         _getJob();
                                       });
                                    }
                                    catch(e){
                               
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Greška tokom plaćanja")),
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
                         
                        Divider(height: 32),
                       if (jobResult.isInvoiced == true &&
    widget.job.user?.userId == AuthProvider.user?.userId &&
    jobResult.isRated == false)
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.job.freelancer != null ? Text("Ocijenite radnika:", style: TextStyle(fontSize: 16,color: Colors.white)) : Text("Ocijenite firmu:", style: TextStyle(fontSize: 16,color: Colors.white)),
      
        const SizedBox(height: 8),
        RatingBar.builder(
          unratedColor: Colors.white,
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
            if(!mounted) return;
            await jobProvider.update(widget.job.jobId, request);


            ScaffoldMessenger.of(context).showSnackBar(
              widget.job.freelancer != null ? const SnackBar(content: Text("Radnik ocijenjen!")) : const SnackBar(content: Text("Firma ocijenjena!")),
             
            );
            await _getJob();
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
