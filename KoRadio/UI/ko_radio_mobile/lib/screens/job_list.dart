import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
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
    final isUser = AuthProvider.userRoles?.role?.roleName == "User";
    final filter = <String, dynamic>{
      if (isUser) 'UserId': AuthProvider.user?.userId,
      if (!isUser) 'FreelancerId': AuthProvider.freelancer?.freelancerId,
      'JobStatus': status.name,
    };

    final job = await jobProvider.get(filter: filter);
    setState(() {
      result = job;
    });
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
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(icon: Icon(Icons.check_circle), text: 'Završeni'),
                  Tab(icon: Icon(Icons.hourglass_top), text: 'Odobreni'),
                  Tab(icon: Icon(Icons.free_cancellation), text: 'Neodobreni'),
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
    if (jobs.isEmpty) {
      return const Center(
        child: Text('Nema poslova za prikaz.'),
      );
    }

    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            onTap: () {
              final destination = (status == JobStatus.unapproved)
                  ? BookJob(job: job, freelancer: job.freelancer)
                  : JobDetails(job: job);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));
            },
            leading: const Icon(Icons.access_time, color: Colors.blue),
            title: Text(
              "Datum: ${job.jobDate.toIso8601String().split('T')[0]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: job.user != null
                ? Text("Korisnik: ${job.user?.firstName} ${job.user?.lastName}")
                : null,
            trailing: const Icon(Icons.work_outline),
          ),
        );
      },
    );
  }
}

