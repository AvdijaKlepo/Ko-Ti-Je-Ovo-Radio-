import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/providers/utils.dart';

class JobDetailsReceipt extends StatefulWidget {
  const JobDetailsReceipt({required this.job, super.key});
  final Job job;

  @override
  State<JobDetailsReceipt> createState() => _JobDetailsReceiptState();
}

class _JobDetailsReceiptState extends State<JobDetailsReceipt> {
      final dateFormat = DateFormat('dd.MM.yyyy');
  @override
  Widget build(BuildContext context) {
    return Column(
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
                      
                    
      ],
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

