import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/approve_job.dart';
import 'package:ko_radio_mobile/screens/edit_job.dart';
import 'package:ko_radio_mobile/screens/edit_job_freelancer.dart';
import 'package:ko_radio_mobile/screens/job_details.dart';

import 'package:provider/provider.dart';

class JobList extends StatefulWidget {
  const JobList({super.key});

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> with TickerProviderStateMixin {
  late JobProvider jobProvider;
  late PaginatedFetcher<Job> jobsPagination;
  final ScrollController _scrollController = ScrollController();
  SearchResult<Job>? result;
  int selectedIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  final isUser = AuthProvider.selectedRole=="User";
  final isFreelancer = AuthProvider.selectedRole=="Freelancer";
  final isCompanyEmployee= AuthProvider.selectedRole=="CompanyEmployee";

  final _userId = AuthProvider.user?.userId;
  final _freelancerId = AuthProvider.user?.freelancer?.freelancerId;
  final _companyEmployeeId = AuthProvider.selectedCompanyEmployeeId;
  late JobStatus jobStatus;
  final List<JobStatus> jobStatuses = [
    JobStatus.finished,
    JobStatus.approved,
    JobStatus.unapproved,
    JobStatus.cancelled,

  ];
Map<String, dynamic> filterMap(JobStatus status)  {
  return{

     if(isUser) 'UserId': _userId,
        if(isFreelancer) 'FreelancerId': _freelancerId,
        if(isCompanyEmployee) 'CompanyEmployeeId': _companyEmployeeId,
        
        'JobStatus': jobStatus.name,
        'isTenderFinalized': false,
        'OrderBy': 'desc',
        'isDeleted': false,
  };
}

  @override
  void initState() {
    super.initState();


    jobStatus = jobStatuses[selectedIndex];
    jobProvider = context.read<JobProvider>();

    jobsPagination = PaginatedFetcher<Job>(
      pageSize: 5,
      initialFilter: {
        if(isUser) 'UserId': _userId,
        if(isFreelancer) 'FreelancerId': _freelancerId,
        if(isCompanyEmployee) 'CompanyEmployeeId': _companyEmployeeId,
        
        'JobStatus': jobStatus.name,
        'isTenderFinalized': false,
        'OrderBy': 'desc',
        'isDeleted': false,
  
      },
      fetcher: ({
        required int page,
        required int pageSize,
        Map<String, dynamic>? filter,
      }) async {
        final result = await jobProvider.get(
          page: page,
          pageSize: pageSize,
          filter: filter,
        );
        return PaginatedResult(result: result.result, count: result.count);
      },
    )..addListener(() =>setState(() {
     if(mounted) setState(() {});
    }));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          jobsPagination.hasNextPage &&
          !jobsPagination.isLoading) {
        jobsPagination.loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading=true;
      });
      if(mounted) await jobsPagination.refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
      setState(() {
        _isInitialized = true;
        _isLoading=false;
      });
    });
   }

  @override
  void dispose() {
    _scrollController.dispose();
    
    super.dispose();
  }
     
  
   

  

  Future<void> _fetchJobsByStatus(JobStatus status) async {
    setState(() {
      _isLoading=true;
    });

    final isUser = AuthProvider.selectedRole=="User";
    final filter = <String, dynamic>{
       if(isUser) 'UserId': _userId,
        if(isFreelancer) 'FreelancerId': _freelancerId,
        if(isCompanyEmployee) 'CompanyEmployeeId': _companyEmployeeId,
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
  Widget build(BuildContext context) {
     if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
   
  
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
                    jobStatus = jobStatuses[index];
                    _isLoading=true;
                    
                  });

                
                  
                 
        
                  await jobsPagination.refresh(newFilter: filterMap(jobStatuses[selectedIndex]));

                  setState(() {
                    _isLoading=false;
                  });
                  
         
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
              if(!_isLoading)
              Text(
                'Broj poslova: ${jobsPagination.items.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(), 
                  
                  children: jobStatuses.map((status) {
                     if(_isLoading){
      return const Center(child: CircularProgressIndicator());
    }
                     if (jobsPagination.items.isEmpty) {
      return const Center(
        child: Text('Nema poslova za prikaz.'),
      );
    }
   
                    return _buildJobList(context, jobsPagination.items, status);
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
  if (!_isInitialized) {
    return const Center(child: CircularProgressIndicator());
  }

  return ListView.separated(
    separatorBuilder: (context, index) => const SizedBox(height: 12),
    controller: _scrollController,
    itemCount: jobs.length + (jobsPagination.hasNextPage ? 1 : 0),
    itemBuilder: (context, index) {
      if (index >= jobs.length) return const SizedBox.shrink();

      final job = jobs[index];

      final isCompanyJob = job.company?.companyId != null;
      final isFreelancerJob = job.freelancer?.freelancerId != null;
      final isUserJob = job.user != null;

      final isDark = job.isEdited == false && job.isWorkerEdited == false;

      final cardColor = isDark
          ? const Color.fromRGBO(27, 76, 125, 1)
          : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black87;

      return Card(
        elevation: 3,
        shadowColor: Colors.black26,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Slidable(
          key: ValueKey(job.jobId),
          enabled: (job.jobStatus == JobStatus.cancelled ||
                  (job.jobStatus == JobStatus.finished && job.isInvoiced == true)) ||
              ((job.jobStatus == JobStatus.approved ||
                      job.jobStatus == JobStatus.unapproved) &&
                  AuthProvider.selectedRole == "User") ||
              ((job.jobStatus == JobStatus.approved &&
                  AuthProvider.selectedRole == "Freelancer")),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              if (job.jobStatus == JobStatus.cancelled ||
                  (job.jobStatus == JobStatus.finished &&
                      job.isInvoiced == true))
                SlidableAction(
                  onPressed: (_) => _onLongPress(context, job),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Obriši',
                ),
              if (((job.jobStatus == JobStatus.approved ||
                          job.jobStatus == JobStatus.unapproved) &&
                      AuthProvider.selectedRole == "User") ||
                  (job.jobStatus == JobStatus.approved &&
                      AuthProvider.selectedRole == "Freelancer"))
                SlidableAction(
                  onPressed: (_) async {
                    if (AuthProvider.selectedRole == "User") {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => EditJob(job: job)));
                    } else if (AuthProvider.selectedRole == "Freelancer") {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => EditJobFreelancer(job: job)));
                    }
                    setState(() => _isLoading = true);
                    await jobsPagination
                        .refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
                    setState(() => _isLoading = false);
                  },
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  icon: Icons.edit_outlined,
                  label: 'Uredi',
                ),
            ],
          ),
          child: ListTile(
            onTap: () async {
              final destination =
                  ((status == JobStatus.unapproved &&
                              AuthProvider.selectedRole == "Freelancer") ||
                          (status == JobStatus.approved &&
                              AuthProvider.selectedRole == "Freelancer"))
                      ? ApproveJob(job: job, freelancer: job.freelancer!)
                      : JobDetails(job: job);

              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => destination));

              setState(() => _isLoading = true);
              await jobsPagination
                  .refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
              setState(() => _isLoading = false);
            },
            leading: CircleAvatar(
              backgroundColor: isDark ? Colors.white24 : Colors.grey.shade200,
              child: Icon(
                isCompanyJob
                    ? Icons.business_outlined
                    : Icons.construction_outlined,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            title: Text(
              job.jobTitle!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Datum: ${DateFormat('dd.MM.yyyy').format(job.jobDate)}",
                    style: TextStyle(color: textColor),
                  ),
                  if (isUserJob && AuthProvider.selectedRole == "Freelancer")
                    Text(
                      "Korisnik: ${job.user?.firstName} ${job.user?.lastName}\nAdresa: ${job.user?.address}",
                      style: TextStyle(color: textColor),
                    ),
                  if (isFreelancerJob)
                    Text(
                      "Radnik: ${job.freelancer?.freelancerNavigation?.firstName} ${job.freelancer?.freelancerNavigation?.lastName}\nServis: ${job.jobsServices?.map((e) => e.service?.serviceName).join(', ')}",
                      style: TextStyle(color: textColor),
                    ),
                  if (isCompanyJob)
                    Text(
                      "Firma: ${job.company?.companyName}\nServis: ${job.jobsServices?.map((e) => e.service?.serviceName).join(', ')}",
                      style: TextStyle(color: textColor),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        job.isInvoiced ?? false ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: job.isInvoiced ?? false ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.isInvoiced ?? false ? "Plaćen" : "Nije plaćen",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: textColor),
                      ),
                      if (job.isEdited == true || job.isWorkerEdited == true) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: const Text("Uređen"),
                          backgroundColor: Colors.orange.shade100,
                          labelStyle: const TextStyle(color: Colors.black87),
                          visualDensity: VisualDensity.compact,
                        )
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}


  void _onLongPress(BuildContext context, Job job) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Obriši posao'),

      content: const Text('Jeste li sigurni da želite obrisati ovaj posao?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Ne'),
        ),
        TextButton(
          onPressed: () async {
            try{
               await jobProvider.delete(job.jobId);
            } on Exception catch (e) {
              if(!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška tokom brisanja posla: ${e.toString()}')));
            }
           Navigator.pop(context);
            await jobsPagination.refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
          },
          child: const Text('Da'),
        ),
      ],
    ));
  }
}