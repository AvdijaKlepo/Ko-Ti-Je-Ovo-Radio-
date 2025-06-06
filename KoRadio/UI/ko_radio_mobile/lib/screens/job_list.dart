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

class _JobListState extends State<JobList> {
  late JobProvider jobProvider;
  SearchResult<Job>? result;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      jobProvider = context.read<JobProvider>();
      AuthProvider.userRoles?.role?.roleName == "User" ?
      _getServices() :
      _getFreelancerServices();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    jobProvider = context.read<JobProvider>();
  }

  _getServices() async {
    var filter = {'FreelancerId:': AuthProvider.freelancer?.freelancerId};

    var job = await jobProvider.get(filter: filter);
    setState(() {
      result = job;
    });
  }
   _getFreelancerServices() async {
    var filter = {'UserId:': AuthProvider.user?.userId};

    var job = await jobProvider.get(filter: filter);
    setState(() {
      result = job;
    });
  }

  @override
  Widget build(BuildContext context) {
    result?.result.where((element) => element.payInvoice != null).toList();

    return DefaultTabController(
      length: 3,
      initialIndex: selectedIndex,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      onTap: (index) => setState(() {
                        selectedIndex = index;

                     
                      }),
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      tabs: const <Widget>[
                        Tab(
                          icon: Icon(Icons.check_circle),
                          text: 'Završeni',
                        ),
                        Tab(
                          icon: Icon(Icons.hourglass_top),
                          text: 'Trenutni',
                        ),
                        Tab(icon: Icon(Icons.cancel), text: 'Neodobreni'),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (selectedIndex == 0)
                      Text(
                        'Broj završenih poslova: ${result?.result.where((element) => element.jobStatus==JobStatus.finished).length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    if (selectedIndex == 1)
                      Text(
                        'Broj poslova u toku: ${result?.result.where((element) => element.jobStatus == JobStatus.approved).length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    if (selectedIndex == 2)
                      Text(
                        'Broj neodobrenih poslova: ${result?.result.where((element) => element.jobStatus == JobStatus.unapproved).length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _finishedJobs(context),
                          _jobsInProgress(context),
                          _unapprovedJobs(context),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              
        ),
      ),
    );
  }

  Widget _finishedJobs(BuildContext context) {
    final filterJob =
        result?.result.where((element) => element.jobStatus==JobStatus.finished).toList();
    return filterJob !=null ? ListView.builder(
      itemCount: filterJob.length,
      itemBuilder: (context, index) {
        final job = filterJob[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            onTap:()=> Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  JobDetails(job: job,))),
            leading: const Icon(Icons.access_time, color: Colors.blue),
            title: Text(
              "Datum: ${job.jobDate.toIso8601String().split('T')[0]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: job.user != null
                ? Text(
                    "Korisnik: ${job.user?.firstName} ${job.user?.lastName}")
                : null,
            trailing: const Icon(Icons.work_outline),
          ),
        );
      },
    ) : const Center( child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Historija završenih poslova je prazna.'),
                      SizedBox(height: 16),
                    ],
                  ),
                );
  }

  Widget _jobsInProgress(BuildContext context) {
    final filterJob = result?.result
        .where((element) =>
            element.jobStatus == JobStatus.approved)
        .toList();
    return filterJob !=null ? ListView.builder(
      itemCount: filterJob.length,
      itemBuilder: (context, index) {
        final job = filterJob[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            onTap:()=> Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  BookJob(job: job,freelancer: job.freelancer,))),

            leading: const Icon(Icons.access_time, color: Colors.blue),
            title: Text(
              "Datum: ${job.jobDate.toIso8601String().split('T')[0]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: job.user != null
                ? Text(
                    "Korisnik: ${job.user?.firstName} ${job.user?.lastName}")
                : null,
            trailing: const Icon(Icons.work_outline),
          ),
        );
      },
    ) : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Historija poslova u toku je prazna.'),
                      SizedBox(height: 16),
                    ],
                  ),
                )
    ;
  }

  Widget _unapprovedJobs(BuildContext context) {
    final filterJob = result?.result
        .where((element) =>
           element.jobStatus == JobStatus.unapproved)
        .toList();
    return filterJob !=null ? ListView.builder(
      itemCount: filterJob.length,
      itemBuilder: (context, index) {
        final job = filterJob[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            onTap:()=> Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  BookJob(job: job,freelancer: job.freelancer,))),

            leading: const Icon(Icons.access_time, color: Colors.blue),
            title: Text(
              "Datum: ${job.jobDate.toIso8601String().split('T')[0]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: job.user != null
                ? Text(
                    "Korisnik: ${job.user?.firstName} ${job.user?.lastName}")
                : null,
            trailing: const Icon(Icons.work_outline),
          ),
        );
      },
    ): 
    const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Historija neodobrenih poslova je prazna.'),
                      SizedBox(height: 16),
                    ],
                  ),
                )
    ;
  }
}
