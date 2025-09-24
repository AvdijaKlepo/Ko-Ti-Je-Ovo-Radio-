import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
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
  late final FreelancerProvider freelancerProvider;
  late final CompanyProvider companyProvider;
  late PaginatedFetcher<Job> jobPagination;
  final ScrollController _scrollController = ScrollController();
  SearchResult<Job>? _jobResult;
  SearchResult<Freelancer>? _freelancerResult;
  SearchResult<Company>? _companyResult;
  DateTime _now = DateTime.now();
  JobViewOption _selectedOption = JobViewOption.unapproved;
  Set<int> _workingDayInts={};
    
  final Map<String, int> _dayStringToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

        _jobProvider = context.read<JobProvider>();
        freelancerProvider = context.read<FreelancerProvider>();
        companyProvider = context.read<CompanyProvider>();
  
      

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

    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading=true;
      });
      await jobPagination.refresh(
        newFilter:AuthProvider.selectedRole == "Freelancer" ?
          
           {
            'FreelancerId': AuthProvider.user?.freelancer?.freelancerId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': JobStatus.approved.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          } : {
            'CompanyEmployeeId': AuthProvider.selectedCompanyEmployeeId,
            'DateRange': _now.toIso8601String().split('T')[0],
            'JobStatus': JobStatus.approved.name,
            'isTenderFinalized': false,
            'OrderBy': 'desc',
            'isDeleted': false,
          },);
          await _getFreelancers();
          await _getCompanies();
          AuthProvider.selectedRole=="Freelancer" ?
           _workingDayInts = _freelancerResult?.result.first.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {} : _workingDayInts = _companyResult?.result.first.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
      setState(() {
        _isInitialized = true;
        _isLoading=false;
      });
    });
 
   
  }
    bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
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
  Future<void> _getFreelancers() async {
    var filter = {'FreelancerId': AuthProvider.user?.freelancer?.freelancerId};
    try {
      var fetchedFreelancers = await freelancerProvider.get(filter: filter);
      if(!mounted) return;
      setState(() {
        _freelancerResult = fetchedFreelancers;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching freelancers: ${e.toString()}')),
        );
      }
    }
  }
  Future<void> _getCompanies() async {
    try {
      var fetchedCompanies = await companyProvider.get();
      if(!mounted) return;
      setState(() {
        _companyResult = fetchedCompanies;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching companies: ${e.toString()}')),
        );
      }
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
                Text('Raspored radnika'),
                SizedBox(
  width: double.infinity, 
  height: 100,            
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
               'FreelancerId': AuthProvider.user?.freelancer?.freelancerId,
              'DateRange': _now.toIso8601String().split('T')[0],
              'JobStatus': JobStatus.approved.name,
              'isTenderFinalized': false,
              'OrderBy': 'desc',
              'isDeleted': false,
            }
          : {
              'CompanyEmployeeId': AuthProvider.selectedCompanyEmployeeId,
              'DateRange': _now.toIso8601String().split('T')[0],
              'JobStatus': JobStatus.approved.name,
              'isTenderFinalized': false,
              'OrderBy': 'desc',
              'isDeleted': false,
            });

      setState(() => _isLoading = false);
    },
  ),
),

           
              
                Center(
                  child: Text(
                    'Ukupno: ${
                      !_isWorkingDay(_now) ? 0 :
                      jobPagination.items.length}',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                 

                  _isLoading ? 
                  const Center(child: CircularProgressIndicator()) :
                   jobPagination.items.isEmpty
                    ? const Center(child: Text('Nema rezervisanih poslova.')) : 
                      !_isWorkingDay(_now) ? const Center(child: Text('Neradni dan.')) :
                  
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
                      return Container(
                        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(27, 76, 125, 1),Color(0xFF4A90E2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
         borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
                        child: Card(
                              color: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                tileColor: Colors.transparent,

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
                                 'FreelancerId': AuthProvider.user?.freelancer?.freelancerId,
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
                                child: isCompanyJob
                                    ? (job.company != null && job.company!.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                  child: imageFromString(
                                      job.company!.image!,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                    ),
                                )
                                : Icon(
                                    Icons.business_outlined,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ))
                                    : (job.user != null && job.user!.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                  child: imageFromString(
                                      job.user!.image!,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                    ),
                                )
                                : (job.freelancer != null &&
                                        job.freelancer!.freelancerNavigation!.image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                      child: imageFromString(
                                          job.freelancer!.freelancerNavigation!.image!,
                                          height: 40,
                                          width: 40,
                                          fit: BoxFit.cover,
                                        ),
                                    )
                                    : Icon(
                                        Icons.construction_outlined,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ))),
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
                                       
                                        if(job.jobStatus==JobStatus.finished)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                        color: job.isInvoiced == true ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                        job.isInvoiced == true ? 'Plaćen' : 'Nije plaćen',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                           if(job.jobStatus==JobStatus.approved || job.jobStatus==JobStatus.unapproved)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                        color: job.jobStatus==JobStatus.approved ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                        job.jobStatus==JobStatus.approved ? 'U toku' : 'Neodobren',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                           if(job.jobStatus==JobStatus.cancelled)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                        color:  Colors.red,
                        borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                        'Otkazan',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                                            ),
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



