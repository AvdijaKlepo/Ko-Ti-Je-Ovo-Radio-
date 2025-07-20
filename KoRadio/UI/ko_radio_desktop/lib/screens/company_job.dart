import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/screens/book_company_job.dart';
import 'package:provider/provider.dart';

class CompanyJob extends StatefulWidget {
  const CompanyJob({super.key});

  @override
  State<CompanyJob> createState() => _CompanyJobState();
}

class _CompanyJobState extends State<CompanyJob> {
  late JobProvider jobProvider;
  SearchResult<Job>? result;
  int selectedIndex = 0;
  final _userId = AuthProvider.user?.userId;

  final List<JobStatus> jobStatuses = [
    JobStatus.finished,
    JobStatus.approved,
    JobStatus.unapproved,
    JobStatus.cancelled,

  ];

  @override
  void initState() {
    super.initState();
    jobProvider = context.read<JobProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchJobsByStatus(jobStatuses[selectedIndex]));
  }

  Future<void> _fetchJobsByStatus(JobStatus status) async {
   
    final filter = <String, dynamic>{
      'CompanyId': AuthProvider.selectedCompanyId,
      'JobStatus': status.name,"isTenderFinalized":false
    };

    try {
  final job = await jobProvider.get(filter: filter);
  if (!mounted) return; 
  setState(() {
    result = job;
  });
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška u dohvaćanju poslova: ${e.toString()}')));
}
  }
  @override
  void dispose() {
    result = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: jobStatuses.length,
      initialIndex: selectedIndex,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                  _fetchJobsByStatus(jobStatuses[index]);
                },
                indicatorColor: Colors.blue,
                labelColor: const Color.fromRGBO(27, 76, 125, 25),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(icon: Icon(Icons.check_circle), text: 'Završeni'),
                  Tab(icon: Icon(Icons.hourglass_top), text: 'Odobreni'),
                  Tab(icon: Icon(Icons.free_cancellation), text: 'Zahtjevi'),
                  Tab(icon: Icon(Icons.cancel), text: 'Otkazani'),
                ],
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                'Broj poslova: ${result?.result.length ?? 0}',
                style: Theme.of(context).textTheme.titleMedium,
              ), 
              ),
             
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(), 
                  children: jobStatuses.map((status) {
                    return _buildJobList(context, result?.result ?? [], status);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildJobList(BuildContext context, List<Job> jobs, JobStatus status) {
  if (jobs.isEmpty) {
    return const Center(child: Text('Nema poslova za prikaz.'));
  }

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return _jobCard(context, job);
        },
      ),
    ),
  );
}


    Widget _jobCard(BuildContext context, Job job) {
  return Card(
    color: const Color.fromRGBO(27, 76, 125, 1),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
       await showDialog(context: context, builder: (_) => BookCompanyJob(job));
      
          await _fetchJobsByStatus(jobStatuses[selectedIndex]);

         
       
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Datum: ${DateFormat('dd‑MM‑yyyy').format(job.jobDate)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Korisnik: ${job.user?.firstName} ${job.user?.lastName}",
                    style: const TextStyle(color: Colors.white),
                  ),
                   Text(
                    "Telefonski broj: ${job.user?.phoneNumber}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Adresa: ${job.user?.address}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Posao: ${job.jobTitle}",
                    style: const TextStyle(color: Colors.white),
                  ),
                    Text(
                    "Opis: ${job.jobDescription}",
                    style: const TextStyle(color: Colors.white),
                  ),
                 
                  Text(
                    job.isInvoiced == true ? 'Plaćen' : 'Nije plaćen',
                    style: const TextStyle(color: Colors.white),
                  ),
                  
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.work_outline, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}

}
