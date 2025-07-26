import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/screens/approve_job.dart';
import 'package:ko_radio_mobile/screens/book_job.dart';
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
      'JobStatus': status.name,"isTenderFinalized":false
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
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];

        return Card(
          color: const Color.fromRGBO(27, 76, 125, 25),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(

          onTap: () async {
  final destination = ((status == JobStatus.unapproved && AuthProvider.selectedRole == "Freelancer") ||
                       (status == JobStatus.approved && AuthProvider.selectedRole == "Freelancer"))
      ? ApproveJob(job: job, freelancer: job.freelancer!)  
      :  JobDetails(job: job);

 final updated = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));

  if(updated==true){
    await _fetchJobsByStatus(jobStatuses[1]);
  }
  else if(updated==false){
    await _fetchJobsByStatus(jobStatuses[3]);
  }
  else{
     setState(() {
     
   });
  }
  
},

            leading: const Icon(Icons.access_time, color: Colors.white),
            title: Text(
              "Datum: ${DateFormat('dd.MM.yyyy').format(job.jobDate)}",
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
            subtitle: job.user != null && AuthProvider.selectedRole=="Freelancer"
                ? Text("Korisnik: ${job.user?.firstName} ${job.user?.lastName}\nAdresa: ${job.user?.address}\n${job.isInvoiced==true?'Plaćen':'Nije plaćen'}",style: const TextStyle(color: Colors.white))
                : job.freelancer?.freelancerId !=null ? Text("Radnik: ${job.freelancer?.freelancerNavigation?.firstName} ${job.freelancer?.freelancerNavigation?.lastName}\nServis: ${job.jobsServices?.map((e) => e.service?.serviceName).join(', ')}\n${job.isInvoiced==true?'Plaćen':'Nije plaćen'}",style: const TextStyle(color: Colors.white))
                : Text('Firma: ${job.company?.companyName}\nServis: ${job.jobsServices?.map((e) => e.service?.serviceName).join(', ')}\n${job.isInvoiced==true?'Plaćen':'Nije plaćen'}',style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.work_outline,color: Colors.white),
          ),
        );
      },
    );
  }
  }
}