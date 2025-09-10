import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/approve_job.dart';
import 'package:ko_radio_mobile/screens/job_details.dart';
import 'package:provider/provider.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';


enum JobViewOption { unapproved, approved }

class FreelancerJobsScreen extends StatefulWidget {
  const FreelancerJobsScreen({super.key});

  @override
  State<FreelancerJobsScreen> createState() => _FreelancerJobsScreenState();
}

class _FreelancerJobsScreenState extends State<FreelancerJobsScreen> {
  late final JobProvider _jobProvider;
  late PaginatedFetcher<Job> jobPagination;
  final ScrollController _scrollController = ScrollController();
  SearchResult<Job>? _jobResult;
  DateTime _now = DateTime.now();
  JobViewOption _selectedOption = JobViewOption.unapproved;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

        _jobProvider = context.read<JobProvider>();
        _selectedOption = JobViewOption.unapproved;
      

        jobPagination = PaginatedFetcher<Job>(
          pageSize: 5,
          initialFilter: AuthProvider.selectedRole == "Freelancer" ?
          
           {
            'FreelancerId': AuthProvider.freelancer?.freelancerId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': _selectedOption.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          } : {
            'CompanyEmployeeId': AuthProvider.selectedCompanyEmployeeId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': _selectedOption.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          },
          fetcher: ({
            required int page,
            required int pageSize,
            Map<String, dynamic>? filter,
          }) async {
            final result = await _jobProvider.get(
              page: page,
              pageSize: pageSize,
              filter: filter
            );
            return PaginatedResult(result: result.result, count: result.count);
          },
        )..addListener(() => setState(() {}));

        _scrollController.addListener(() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
              jobPagination.hasNextPage &&
              !jobPagination.isLoading) {
            jobPagination.loadMore();
          }
        });

        _scrollController.addListener(() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
              jobPagination.hasNextPage &&
              !jobPagination.isLoading) {
            jobPagination.loadMore();
          }
        });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading=true;
      });
      await jobPagination.refresh(newFilter:AuthProvider.selectedRole == "Freelancer" ?
          
           {
            'FreelancerId': AuthProvider.freelancer?.freelancerId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': _selectedOption.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          } : {
            'CompanyEmployeeId': AuthProvider.selectedCompanyEmployeeId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': _selectedOption.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          },);
      setState(() {
        _isInitialized = true;
        _isLoading=false;
      });
    });
 
   
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading=true;
    });
    final String jobStatus = _selectedOption == JobViewOption.unapproved
        ? JobStatus.unapproved.name
        : JobStatus.approved.name;
    final filter = {
      'FreelancerId': AuthProvider.freelancer?.freelancerId,
      'JobDate': _now.toIso8601String().split('T')[0],
      'JobStatus': jobStatus,
    };

    try {
      final result = await _jobProvider.get(filter: filter);
      setState(() {
        _jobResult = result;
        _isLoading=false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching jobs: ${e.toString()}')),
        );
      }
    }
  }

  void _onSegmentChanged(JobViewOption option) async {
    if (_selectedOption != option) {
      setState(() {
        _selectedOption = option;
        _isLoading=true;
      });
      await jobPagination.refresh(newFilter:AuthProvider.selectedRole == "Freelancer" ?
          
           {
            'FreelancerId': AuthProvider.freelancer?.freelancerId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': _selectedOption.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          } : {
            'CompanyEmployeeId': AuthProvider.selectedCompanyEmployeeId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': _selectedOption.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          },);
      setState(() {
        _isLoading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
                      if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: 
           Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
  width: double.infinity, // take full width
  height: 100,            // prevent vertical overflow
  child: DatePicker(
    locale: 'bs',
    DateTime.now().subtract(const Duration(days: 2)),
    initialSelectedDate: _now,
    selectionColor: const Color.fromRGBO(27, 76, 125, 1),
    selectedTextColor: Colors.white,
    daysCount: 30,
    onDateChange: (date) async {
      setState(() {
        _now = date;
        _isLoading = true;
      });

      await jobPagination.refresh(newFilter: AuthProvider.selectedRole == "Freelancer"
          ? {
              'FreelancerId': AuthProvider.freelancer?.freelancerId,
              'DateRange': _now.toIso8601String().split('T')[0],
              'JobStatus': _selectedOption.name,
              'isTenderFinalized': false,
              'OrderBy': 'desc',
              'isDeleted': false,
            }
          : {
              'CompanyEmployeeId': AuthProvider.selectedCompanyEmployeeId,
              'DateRange': _now.toIso8601String().split('T')[0],
              'JobStatus': _selectedOption.name,
              'isTenderFinalized': false,
              'OrderBy': 'desc',
              'isDeleted': false,
            });

      setState(() => _isLoading = false);
    },
  ),
),

                SizedBox(height: 10,), 
                Center(
                  child: SegmentedButton<JobViewOption>(
                    
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.white,
                      
                      selectedBackgroundColor: Color.fromRGBO(27, 76, 125, 25),
                      selectedForegroundColor: Colors.white,
                      foregroundColor: Colors.black,
                   
                      
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<JobViewOption>>[
                      ButtonSegment(
                        
                        value: JobViewOption.unapproved,
                        label: Text('Neodobreni'),
                        icon: Icon(Icons.check_box_outline_blank_outlined),
                      
                      ),
                      ButtonSegment(
                        value: JobViewOption.approved,
                        label: Text('Odobreni'),
                        icon: Icon(Icons.check_box_outlined),
                      ),
                    ],
                    selected: <JobViewOption>{_selectedOption},
                    onSelectionChanged: (Set<JobViewOption> newSelection) {
                      _onSegmentChanged(newSelection.first);
                    },
                  ),
                ),
                SizedBox(height: 10,),
                Center(
                  child: Text(
                    'Ukupno: ${jobPagination.items.length}',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                 

                  _isLoading ? 
                  const Center(child: CircularProgressIndicator()) :
                   jobPagination.items.isEmpty ? const Center(child: Text('Nema rezervisanih poslova.')) : 
                  
                   ListView.separated(
                    separatorBuilder: (context, index) => const Divider(height: 35),
                    controller: _scrollController,
                    itemCount: jobPagination.items.length + (jobPagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      
    
                     
                      final job = jobPagination.items[index];
                     

      final isCompanyJob = job.company?.companyId != null;
      final isFreelancerJob = job.freelancer?.freelancerId != null;
      final isUserJob = job.user != null;

      final isDark = job.isEdited == false && job.isWorkerEdited == false;

      final cardColor = isDark
          ? const Color.fromRGBO(27, 76, 125, 1)
          : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black87;
                      return Card(
      color: const Color.fromRGBO(27, 76, 125, 25),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Slidable(
        enabled: job.jobStatus==JobStatus.cancelled || (job.jobStatus==JobStatus.finished && job.isInvoiced==true) || job.jobStatus==JobStatus.approved ? true : false,
        direction: Axis.horizontal,
        key: const ValueKey(0),
        endActionPane: ActionPane(
          motion: const ScrollMotion() ,
          extentRatio: 0.25,
          children: [
           
            if(job.jobStatus==JobStatus.approved)
            SlidableAction(
              onPressed: (_) {},
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: 'Uredi',
            )  ,
          ],
        ),
        child: ListTile(
          onTap: () async {
            AuthProvider.selectedRole == "Freelancer" ?
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ApproveJob(
                  job: job,
                  freelancer: job.freelancer!,
                ),
              ),
            ):
             await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => JobDetails(
                  job: job
                 
                ),
              ),
            )
            ;
            await jobPagination.refresh(newFilter: AuthProvider.selectedRole == "Freelancer" ?
          
           {
            'FreelancerId': AuthProvider.freelancer?.freelancerId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': _selectedOption.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          } : {
            'CompanyEmployeeId': AuthProvider.selectedCompanyEmployeeId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': _selectedOption.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          },);
           
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
                  if (isFreelancerJob && AuthProvider.selectedRole == "User")
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
                  if(job.jobStatus==JobStatus.approved || job.jobStatus==JobStatus.unapproved)
                  Row(
                    children: [
                      Icon(
                        job.jobStatus==JobStatus.approved ?? false ?Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: job.jobStatus==JobStatus.approved ?? false ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.jobStatus==JobStatus.approved ?? false ? "Odobren" : "Nije odobren",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: textColor),
                      ),
                    ],
                  ),
                  if(job.jobStatus==JobStatus.finished)
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
    );;
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }
}



