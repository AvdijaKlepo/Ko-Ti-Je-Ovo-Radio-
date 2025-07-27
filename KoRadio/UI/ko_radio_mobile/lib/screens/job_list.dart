import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/screens/approve_job.dart';
import 'package:ko_radio_mobile/screens/job_details.dart';
import 'package:provider/provider.dart';

class JobList extends StatefulWidget {
  const JobList({super.key});

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> with TickerProviderStateMixin {
  late JobProvider jobProvider;
  SearchResult<Job>? result;
  int selectedIndex = 0;
    bool _isLoading = false;

  final _userId = AuthProvider.user?.userId;
  final _freelancerId = AuthProvider.user?.freelancer?.freelancerId;

  final List<JobStatus> jobStatuses = [
    JobStatus.finished,
    JobStatus.approved,
    JobStatus.unapproved,
    JobStatus.cancelled,

  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading=true;
    });

 
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       jobProvider = context.read<JobProvider>();
     await _fetchJobsByStatus(jobStatuses[selectedIndex]);
     });

     setState(() {
       _isLoading=false;
     });

  }

  Future<void> _fetchJobsByStatus(JobStatus status) async {
    setState(() {
      _isLoading=true;
    });

    final isUser = AuthProvider.selectedRole=="User";
    final filter = <String, dynamic>{
      if (isUser) 'UserId': _userId,
      if (!isUser) 'FreelancerId': _freelancerId,
      'JobStatus': status.name,"isTenderFinalized":false,
      'OrderBy': 'desc',
      'isDeleted':false,
    };

    try {
  final job = await jobProvider.get(filter: filter);
  if (!mounted) return; 
  setState(() {
    result = job;
    _isLoading=false;
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
      animationDuration:const Duration(milliseconds: 10),
      length: jobStatuses.length,
      initialIndex: selectedIndex,
   
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                onTap: (index) async {
                  setState(() {
                    selectedIndex = index;
                  });
        
                  await _fetchJobsByStatus(jobStatuses[index]);
         
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
              Text(
                'Broj poslova: ${result?.result.length ?? 0}',
                style: Theme.of(context).textTheme.titleMedium,
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
      if(_isLoading){
      return const Center(child: CircularProgressIndicator());
    }
    if (jobs.isEmpty) {
      return const Center(
        child: Text('Nema poslova za prikaz.'),
      );
    }
   
    else{
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(height: 35),
      
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];

    return Card(
  color: const Color.fromRGBO(27, 76, 125, 25),
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  margin: const EdgeInsets.symmetric(vertical: 8),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Datum: ${DateFormat('dd.MM.yyyy').format(job.jobDate)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.user != null && AuthProvider.selectedRole == "Freelancer"
                    ? "Korisnik: ${job.user?.firstName} ${job.user?.lastName}\nAdresa: ${job.user?.address}\n${job.isInvoiced == true ? 'Plaćen' : 'Nije plaćen'}"
                    : job.freelancer?.freelancerId != null
                        ? "Radnik: ${job.freelancer?.freelancerNavigation?.firstName} ${job.freelancer?.freelancerNavigation?.lastName}\nServis: ${job.jobsServices?.map((e) => e.service?.serviceName).join(', ')}\n${job.isInvoiced == true ? 'Plaćen' : 'Nije plaćen'}"
                        : "Firma: ${job.company?.companyName}\nServis: ${job.jobsServices?.map((e) => e.service?.serviceName).join(', ')}\n${job.isInvoiced == true ? 'Plaćen' : 'Nije plaćen'}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
  
        
          children: [
            job.freelancer != null
                ? const Icon(Icons.construction_outlined, color: Colors.white)
                : const Icon(Icons.business_outlined, color: Colors.white),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () async {
                try{
                   await jobProvider.delete(job.jobId);
                } on Exception catch (e) {
                  if(!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška tokom brisanja posla: ${e.toString()}')));
                }
               
                await _fetchJobsByStatus(jobStatuses[2]);
              },
              tooltip: 'Obriši posao',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    ),
  ),
);


      },
    );
  }
  }
}