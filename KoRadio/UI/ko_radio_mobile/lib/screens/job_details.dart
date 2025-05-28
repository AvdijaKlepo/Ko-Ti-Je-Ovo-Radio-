import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/providers/utils.dart';



class JobDetails extends StatelessWidget {
  final Job job;

  const JobDetails({super.key, required this.job});

  @override
  Widget build(BuildContext context) {

    final dateFormat = DateFormat('dd.MM.yyyy');


    return Scaffold(

        appBar: appBar(title: 'Detalji posla', automaticallyImplyLeading:true),
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
               
        
                  _buildDetailRow('Servis(i)', job.jobsServices
                      ?.map((e) => e.service?.serviceName)
                      .where((e) => e != null)
                      .join(', ') ?? 'N/A'),
        
                  const SizedBox(height: 12),
        
                  _buildDetailRow('Datum', dateFormat.format(job.jobDate)),
        
                  const SizedBox(height: 12),
        
                  _buildDetailRow('Vrijeme početka',
                      job.startEstimate),
        
                  const SizedBox(height: 12),
        
                  _buildDetailRow('Vrijeme završetka',
                      job.endEstimate != null ? job.endEstimate! : 'Nije dostupno'),
        
                  const SizedBox(height: 12),
        
                  _buildDetailRow('Opis posla', job.jobDescription ?? 'Nema opisa'),
        
                  const Divider(height: 32),
        
                  Text(
                    'Korisnički podaci',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
        
                  _buildDetailRow(
                      'Ime i prezime',
                      job.user != null
                          ? '${job.user?.firstName ?? ''} ${job.user?.lastName ?? ''}'
                          : 'Nepoznato'),
        
                  const SizedBox(height: 12),
        
                  const Divider(height: 32),
                  
                  Text(
                    'Podaci radnika',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                   _buildDetailRow(
                      'Ime i prezime',
                      job.user != null
                          ? '${job.freelancer?.user.firstName ?? ''} ${job.freelancer?.user.lastName ?? ''}'
                          : 'Nepoznato'),
        
                  _buildDetailRow('E-mail', job.freelancer?.user.email ?? 'Nepoznato'),
        
                  const Divider(height: 32),
        
                  _buildDetailRow('Procijenjena cijena', job.payEstimate?.toStringAsFixed(2) ?? 'Nije unesena'),
        
                  const SizedBox(height: 12),
        
                  _buildDetailRow('Konačna cijena', job.payInvoice?.toStringAsFixed(2) ?? 'Nije unesena'),
                ],
              ),
            ),
          ),
        ),
      ));
  
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            )),
      ],
    );
  }
}
