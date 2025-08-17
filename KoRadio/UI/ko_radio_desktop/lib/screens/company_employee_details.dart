import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class CompanyEmployeeDetails extends StatefulWidget {
  const CompanyEmployeeDetails({required this.companyEmployee, super.key});
  final CompanyEmployee companyEmployee;

  @override
  State<CompanyEmployeeDetails> createState() => _CompanyEmployeeDetailsState();
}

class _CompanyEmployeeDetailsState extends State<CompanyEmployeeDetails> {
  late JobProvider jobProvider;
  SearchResult<Job>? jobResult;
  SearchResult<Job>? jobOldResult;
  late PaginatedFetcher<Job> jobPagination;
  late PaginatedFetcher<Job> oldJobPagination;
  late final ScrollController _scrollController;
  late final ScrollController _oldJobScrollController;
  bool _isInitialized = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    jobPagination = PaginatedFetcher<Job>(
      pageSize: 0,
      initialFilter: {},
      fetcher: ({
        required int page,
        required int pageSize,
        Map<String, dynamic>? filter,
      }) async {
        return PaginatedResult(result: [], count: 0);
      },
    );

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_isInitialized) return; 

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          jobPagination.hasNextPage &&
          !jobPagination.isLoading) {
        jobPagination.loadMore();
      }
    });
     _oldJobScrollController = ScrollController();
    _oldJobScrollController.addListener(() {
      if (!_isInitialized) return; 

      if (_oldJobScrollController.position.pixels >=
              _oldJobScrollController.position.maxScrollExtent - 100 &&
          oldJobPagination.hasNextPage &&
          !oldJobPagination.isLoading) {
        oldJobPagination.loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      jobProvider = context.read<JobProvider>();
      jobPagination = PaginatedFetcher<Job>(
        pageSize: 20,
        initialFilter: {
          'CompanyEmployeeId': widget.companyEmployee.companyEmployeeId,
          'JobStatus': JobStatus.approved.name,
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
      )..addListener(() => setState(() {}));
      oldJobPagination = PaginatedFetcher<Job>(
        pageSize: 20,
        initialFilter: {
          'CompanyEmployeeId': widget.companyEmployee.companyEmployeeId,
          'JobStatus': JobStatus.finished.name,
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
      )..addListener(() => setState(() {}));


      await jobPagination.refresh(newFilter: {
        'CompanyEmployeeId': widget.companyEmployee.companyEmployeeId,
        'JobStatus': JobStatus.approved.name,
      });
       await oldJobPagination.refresh(newFilter: {
        'CompanyEmployeeId': widget.companyEmployee.companyEmployeeId,
        'JobStatus': JobStatus.finished.name,
      });

      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
    });

    @override
    void dispose() {
      jobPagination.dispose();
      _scrollController.dispose();
      super.dispose();
    }




    

    
  }

  Future<void> _getJob() async {
    var filter = {'CompanyEmployeeId': widget.companyEmployee.companyEmployeeId,
    'JobStatus': JobStatus.approved.name};
    try {
      var fetchedJob = await jobProvider.get(filter: filter);
      if (!mounted) return;
      setState(() {
        jobResult = fetchedJob;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  Future<void> _getOldJob() async {
    var filter = {'CompanyEmployeeId': widget.companyEmployee.companyEmployeeId,
    'JobStatus': JobStatus.finished.name};
    try {
      var fetchedJob = await jobProvider.get(filter: filter);
      if (!mounted) return;
      setState(() {
        jobOldResult = fetchedJob;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
 
    
    if(!_isInitialized) return const Center(child: CircularProgressIndicator());
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 600,
        height: double.maxFinite, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  child:ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                  widget.companyEmployee.user?.image != null ?
                   imageFromString(widget.companyEmployee.user?.image ?? ''):
                   Image(image: AssetImage('assets/images/Sample_User_Icon.png'),fit: BoxFit.cover,),

                ) ,
                ),

                
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Ime: ${widget.companyEmployee.user?.firstName ?? ''} ${widget.companyEmployee.user?.lastName ?? ''} '),
                    ),
                     Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Telefonski broj: ${widget.companyEmployee.user?.phoneNumber ?? ''} '),
                    ),
                      Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Uloga: ${widget.companyEmployee.companyRoleName ?? ''} '),
                    ),
                     Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Zaposlen: ${DateFormat('dd-MM-yyyy').format(widget.companyEmployee.dateJoined ?? DateTime.now())} '),
                    ),
                  ],
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Radnik ${widget.companyEmployee.user?.firstName ?? ''} '
                '${widget.companyEmployee.user?.lastName ?? ''} '
                'je trenutno angažovan na slijedećim poslovima.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded( 
              child: jobPagination.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildJobList(jobPagination.items),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Radnik ${widget.companyEmployee.user?.firstName ?? ''} '
                '${widget.companyEmployee.user?.lastName ?? ''} '
                'je bio angažovan slijedećim poslovima.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded( 
              child: jobPagination.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildOldJobList(oldJobPagination.items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return const Center(child: Text('Nema poslova za prikaz.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      controller: jobPagination.items.isEmpty ? null : _scrollController,
      shrinkWrap: true,
      itemCount: jobPagination.items.length + (jobPagination.hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        return _jobCard(jobs[index]);
      },
    );
  }
  Widget _buildOldJobList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return const Center(child: Text('Nema poslova za prikaz.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return _jobCard(jobs[index]);
      },
    );
  }
  

  Widget _jobCard(Job job) {
    return Card(
      color: const Color.fromRGBO(27, 76, 125, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                    "Datum: ${DateFormat('dd-MM-yyyy').format(job.jobDate)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Korisnik: ${job.user?.firstName ?? ''} ${job.user?.lastName ?? ''}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Telefonski broj: ${job.user?.phoneNumber ?? ''}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Adresa: ${job.user?.address ?? ''}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Posao: ${job.jobTitle ?? ''}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Opis: ${job.jobDescription ?? ''}",
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
    );
  }
}
