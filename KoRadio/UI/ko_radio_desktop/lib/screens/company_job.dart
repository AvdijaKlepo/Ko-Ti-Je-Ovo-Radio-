import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/book_company_job.dart';
import 'package:provider/provider.dart';

class CompanyJob extends StatefulWidget {
  const CompanyJob({super.key});

  @override
  State<CompanyJob> createState() => _CompanyJobState();
}

class _CompanyJobState extends State<CompanyJob> {
late JobProvider jobProvider;
  late PaginatedFetcher<Job> jobsPagination;
  final ScrollController _scrollController = ScrollController();
  SearchResult<Job>? result;
  int selectedIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
 

  late JobStatus jobStatus;
  final List<JobStatus> jobStatuses = [
    JobStatus.finished,
    JobStatus.approved,
    JobStatus.unapproved,
    JobStatus.cancelled,

  ];
Map<String, dynamic> filterMap(JobStatus status)  {
  return{

        'CompanyId': AuthProvider.selectedCompanyId,
        
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
        'CompanyId': AuthProvider.selectedCompanyId,
        
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
              Center(
                child: Text(
                'Broj poslova: ${jobsPagination.items.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ), 
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

  if (jobs.isEmpty) {
    return const Center(child: Text('Nema poslova za prikaz.'));
  }

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: jobs.length + (jobsPagination.hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if(index < jobs.length){
          final job = jobs[index];
          return _jobCard(context, job);
          }
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
      
          await jobsPagination.refresh(newFilter: filterMap(jobStatuses[selectedIndex]));

         
       
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
