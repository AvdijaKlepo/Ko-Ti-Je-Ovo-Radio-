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

  final _userId = AuthProvider.user?.userId;
  final _freelancerId = AuthProvider.user?.freelancer?.freelancerId;
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
        if(!isUser) 'FreelancerId': _freelancerId,
        
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
        if(!isUser) 'FreelancerId': _freelancerId,
        
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
    )..addListener(() => setState(() {
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
      await jobsPagination.refresh();
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

                    
                  });

                  setState(() {
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
       if(!_isInitialized) return const Center(child: CircularProgressIndicator());

    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(height: 35),
      controller: _scrollController,
      itemCount: jobs.length + (jobsPagination.hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
         
   
    
        if(index < jobs.length){
        final job = jobs[index];

   return Card(
          color: job.isEdited==false ? const Color.fromRGBO(27, 76, 125, 25) : const Color(0xFFFFF3CD),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child:
             
           Slidable(
            enabled: 
            (job.jobStatus==JobStatus.cancelled || (job.jobStatus==JobStatus.finished && job.isInvoiced==true)) ||
            
           (job.jobStatus==JobStatus.approved || job.jobStatus==JobStatus.unapproved) ? true : false,
            
            direction: Axis.horizontal,

            key: const ValueKey(0),
            
            endActionPane: ActionPane(

              motion: const ScrollMotion() ,

              
              extentRatio: 0.25,
              children: [

                if(job.jobStatus==JobStatus.cancelled || (job.jobStatus==JobStatus.finished && job.isInvoiced==true))
                SlidableAction(

                  onPressed: (_) => _onLongPress(context, job),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Obriši',
                )  ,

                if((job.jobStatus==JobStatus.approved || job.jobStatus==JobStatus.unapproved)) 
                 SlidableAction(
                  onPressed: (_) async 
                  {

                   await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditJob(job: job)));
                   setState(() {
                     _isLoading=true;
                   });
                   await jobsPagination.refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
                   setState(() {
                     _isLoading=false;
                   });
                   
                   },
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_outlined,
                  label: 'Uredi',
                )  ,
              ],
            ),
            child: ListTile(
             
            
            onLongPress: () async {
               if(job.isEdited==true)
    {
        var jobInsertRequest = {
                  "userId": job.user?.userId,
                  "freelancerId": job.freelancer?.freelancerId,
                  "companyId": job.company?.companyId,
                  "jobTitle": job.jobTitle,
                  "isTenderFinalized": false,
                  "isFreelancer": true,
                  "isInvoiced": false,
                  "isRated": false,
                  "startEstimate": job.startEstimate,
                  "endEstimate": job.endEstimate,
                  "payEstimate": job.payEstimate,
                  "payInvoice": null,
                  "jobDate": job.jobDate.toIso8601String(),
                  "dateFinished": null,
                  "jobDescription": job.jobDescription,
                  "image": job.image,
                  "jobStatus": job.jobStatus.name,
                  "serviceId": job.jobsServices
                          ?.map((e) => e.service?.serviceId)
                          .toList(),
                  "isEdited":false,
                };
      
      await jobProvider.update(job.jobId,
      jobInsertRequest);
    }
    await jobsPagination.refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
            },
              
            
            onTap: () async {
              final destination = ((status == JobStatus.unapproved && AuthProvider.selectedRole == "Freelancer") ||
                         (status == JobStatus.approved && AuthProvider.selectedRole == "Freelancer"))
                  ?   ApproveJob(job: job, freelancer: job.freelancer!)  
                  :  JobDetails(job: job);
            
            final updated = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));
            
            
                if(updated==true)
                {
            
                await jobsPagination.refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
                }
                else{
                  setState(() {
                    
                  });
                }
              
              
            
             
             
              
              
            },
            
              leading:  Icon(Icons.info_outline, color: job.isEdited==false ? Colors.white : Colors.black),
              title: Text(
                "Datum: ${DateFormat('dd.MM.yyyy').format(job.jobDate)}",
                style:  TextStyle(fontWeight: FontWeight.bold,color: job.isEdited==false ? Colors.white : Colors.black),
              ),
              subtitle: job.user != null && AuthProvider.selectedRole=="Freelancer"
                  ? Text("Korisnik: ${job.user?.firstName} ${job.user?.lastName}\nAdresa: ${job.user?.address}\n${job.isInvoiced==true?'Plaćen':'Nije plaćen'}",style:  TextStyle(color: job.isEdited==false ? Colors.white : Colors.black))
                  : job.freelancer?.freelancerId !=null ? Text("Radnik: ${job.freelancer?.freelancerNavigation?.firstName} ${job.freelancer?.freelancerNavigation?.lastName}\nServis: ${job.jobsServices?.map((e) => e.service?.serviceName).join(', ')}\n${job.isInvoiced==true?'Plaćen':'Nije plaćen\n${job.isEdited==true?'Uređen':''}'}",style:  TextStyle(color: job.isEdited==false ? Colors.white : Colors.black))
                  : Text('Firma: ${job.company?.companyName}\nServis: ${job.jobsServices?.map((e) => e.service?.serviceName).join(', ')}\n${job.isInvoiced==true?'Plaćen':'Nije plaćen\n${job.isEdited==true?'Uređen':''}'}',style:  TextStyle(color: job.isEdited==false ? Colors.white : Colors.black)),
              trailing: job.freelancer!= null ?  Icon(Icons.construction_outlined,color: job.isEdited==false ? Colors.white : Colors.black) :  Icon(Icons.business_outlined,color: job.isEdited==false ? Colors.white : Colors.black),
            
                    ),
          ));


      }
        return null;},
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