import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/approve_job.dart';
import 'package:ko_radio_mobile/screens/edit_job.dart';
import 'package:ko_radio_mobile/screens/edit_job_freelancer.dart';
import 'package:ko_radio_mobile/screens/job_details.dart';

import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
 import 'package:intl/date_symbol_data_local.dart';

class JobList extends StatefulWidget {
  const JobList({super.key});

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> with TickerProviderStateMixin {
  late JobProvider jobProvider;
  late PaginatedFetcher<Job> jobsPagination;
  late FreelancerProvider freelancerProvider;
  late CompanyProvider companyProvider;
  SearchResult<Freelancer>? freelancer;
  SearchResult<Company>? _companyResult;
  final ScrollController _scrollController = ScrollController();
  SearchResult<Job>? result;
  int selectedIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  DateTime _focusedDay = DateTime.now();
DateTime? _selectedDay;
Map<DateTime, List<Job>> jobsByDate = {};
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



  final isUser = AuthProvider.selectedRole=="User";
  final isFreelancer = AuthProvider.selectedRole=="Freelancer";
  final isCompanyEmployee= AuthProvider.selectedRole=="CompanyEmployee";

  final _userId = AuthProvider.user?.userId;
  final _freelancerId = AuthProvider.user?.userId;
  final _companyEmployeeId = AuthProvider.selectedCompanyEmployeeId;
  late JobStatus jobStatus;
  final List<JobStatus> jobStatuses = [
    JobStatus.finished,
    JobStatus.approved,
    JobStatus.unapproved,
    JobStatus.cancelled,

  ];
Map<String, dynamic> filterMap(JobStatus status,{DateTime? date})  {

  final Map<String, dynamic> filter = {
 if(isUser) 'UserId': _userId,
        if(isFreelancer) 'FreelancerId': _freelancerId,
        if(isCompanyEmployee) 'CompanyEmployeeId': _companyEmployeeId,
        
        'JobStatus': status.name,
        'isTenderFinalized': false,
        'OrderBy': 'desc',
        'isDeleted': false,
      
  };
   if (date != null) {
    filter['DateRange'] = date.toIso8601String().split('T')[0];
  } else {
    filter['JobStatus'] = status.name;
  }
  return filter;
}
 void _clearDateFilter() async {
    setState(() {
      _selectedDay = null;

      _isLoading = true;
    });
    await jobsPagination.refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _fetchFreelancers() async {
    try {
      var filter ={'FreelancerId':AuthProvider.user?.freelancer?.freelancerId};
  final result = await freelancerProvider.get(filter: filter);
  if (!mounted) return;
  setState(() {
    freelancer = result;
  });
}  catch (e) {
  
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
bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
}


void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
  final navigator = Navigator.of(context);
    final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (!isSameDay(_selectedDay, normalizedSelectedDay) && mounted) {
      setState(() {
        _selectedDay = normalizedSelectedDay;
        _focusedDay = focusedDay;
       
        _isLoading = true;
      });
     await jobsPagination.refresh(newFilter: filterMap(
  jobStatuses[selectedIndex],
  date: normalizedSelectedDay,


      ));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    navigator.pop();
  }

  @override
  void initState() {
    super.initState();

       initializeDateFormatting('bs', null);
    jobStatus = jobStatuses[selectedIndex];
    jobProvider = context.read<JobProvider>();
    freelancerProvider = context.read<FreelancerProvider>();
    companyProvider = context.read<CompanyProvider>();
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
    );
    jobsPagination.addListener(() {
      if (mounted) setState(() {});
    });




      await jobsPagination.refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
       if(!mounted) return;
      setState(() {
        _isInitialized = true;
        _isLoading=false;
      });

     await _fetchFreelancers();
     await _getCompanies();
     if(AuthProvider.selectedRole=="Freelancer")
     {
 
           _workingDayInts = freelancer?.result.first.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ?? {};
     
     } else if(AuthProvider.selectedRole=="CompanyEmployee")
     {
      _workingDayInts = _companyResult?.result.first.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ?? {};
     }
     else{
      _workingDayInts = {1,2,3,4,5,6,7};
     }
          await _loadJobs();
      
      
    });
   }

  @override
  void dispose() {
    _scrollController.dispose();
    
    super.dispose();
  }
     
  
  Future<void> _loadJobs() async {
  final result = await jobProvider.get(filter: filterMap(JobStatus.approved));

  if (!mounted) return;

  setState(() {
    jobsByDate.clear();

    for (var job in result.result) {
      final start = DateTime(job.jobDate.year, job.jobDate.month, job.jobDate.day);

      if (job.dateFinished != null) {
        final end = DateTime(job.dateFinished!.year, job.dateFinished!.month, job.dateFinished!.day);

        for (var date = start;
            !date.isAfter(end);
            date = date.add(const Duration(days: 1))) {
          
          
          if (_isWorkingDay(date)) {
            jobsByDate.putIfAbsent(date, () => []).add(job);
          }
        }
      } else {

        if (_isWorkingDay(start)) {
          jobsByDate.putIfAbsent(start, () => []).add(job);
        }
      }
    }

    _isInitialized = true;
    _isLoading = false;
  });
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
                     if(_selectedDay!=null) _clearDateFilter();
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
              if (_selectedDay != null)
                            Align(
                              alignment: Alignment.topLeft,
                              child: TextButton.icon(
                                icon: const Icon(Icons.close),
                                label: const Text('Poništi aktivni filter datuma'),
                                onPressed: _clearDateFilter,
                              ),
                            ),
              if(!_isLoading)
              SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                           
                  children:[
                    _selectedDay==null ?
                     Text(
                    'Broj poslova: ${jobsPagination.items.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ) : Text(
                    'Broj poslova  ${DateFormat.yMMMMd('bs').format(_selectedDay!)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                    
                 
                  IconButton(onPressed: () async{
                    await showModalBottomSheet(context: context,isScrollControlled: true, builder: (context) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                        
                           
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color.fromRGBO(27, 76, 125, 1),Color(0xFF4A90E2)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Kalendar',style: TextStyle(color: Colors.white),),
                                  IconButton(onPressed: (){
                                    Navigator.pop(context);
                                  }, icon: const Icon(Icons.close,color: Colors.white,),),
                                ],
                              ),
                            ),
                             SizedBox(
                                             
                        
                                          child: TableCalendar(
                            
                              shouldFillViewport: false,
                              locale: 'bs',
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                             onDaySelected: _onDaySelected,
                             enabledDayPredicate: (day) => _isWorkingDay(day),
                              
                              availableCalendarFormats: const {
                                CalendarFormat.month: 'Mjesec',
                                             
                              },
                              calendarFormat: CalendarFormat.month,
                             
                              onPageChanged: (focusedDay) {
                                _focusedDay = focusedDay;
                              },
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: true,
                                titleCentered: true,
                              ),
                              calendarStyle: const CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: Color.fromRGBO(27, 76, 125, 0.2),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Color.fromRGBO(27, 76, 125, 1),
                                  shape: BoxShape.circle,
                                ),
                                rangeStartDecoration: BoxDecoration(
                                  color: Color.fromRGBO(27, 76, 125, 1),
                                  shape: BoxShape.circle,
                                ),
                                rangeEndDecoration: BoxDecoration(
                                  color: Color.fromRGBO(27, 76, 125, 1),
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: TextStyle(color: Colors.white),
                              ),
                              eventLoader: (day) {
                                if(jobStatuses[selectedIndex]==JobStatus.approved)
                                {
                                final normalized = DateTime(day.year, day.month, day.day);
                                return jobsByDate[normalized] ?? [];
                                }else{
                                  return [];
                                }
                              },
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, day, events) {
                                  if (events.isNotEmpty) {
                                    return Positioned(
                                      bottom: 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${events.length}',
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                            
                          ]
                        ),
                      );
                    });
                    
                  }, icon: 
                  const Icon(Icons.calendar_month,color: Colors.black,),),
                            ]),
              ),
              const SizedBox(height: 16),
         

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
   
                    return 
                    
                    
                    _buildJobList(context, jobsPagination.items, status);
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
    itemCount: jobs.length + (jobsPagination.hasNextPage ? 1 : 0) +1,
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

      return  Container(
               width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                 colors: job.isEdited==false && job.isWorkerEdited==false ?
                                        [Color.fromRGBO(27, 76, 125, 1),Color(0xFF4A90E2)] :
                                        [Colors.blue,Colors.amberAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
               borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Card(
                elevation: 3,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  tileColor: Colors.transparent,
                  
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
                        
                    if(!mounted) return;
                    setState(() => _isLoading = true);
                    await jobsPagination
                        .refresh(newFilter: filterMap(jobStatuses[selectedIndex]));
                    await _loadJobs();
                    if(!mounted) return;
                    setState(() => _isLoading = false);
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
            : (!isUser && job.user != null && job.user!.image != null
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
                          "Datum početka: ${DateFormat('dd.MM.yyyy').format(job.jobDate)}",
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
                             Row(
                                                  children: [
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
                                                     SizedBox(width: 10,),
                                                    if(job.isEdited==true || job.isWorkerEdited==true)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                              color:  Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: const Text(
                              'Izmjenjen',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                                                  ),
                                                ),
                                                  ],
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
      );
            
            
        
    },
  );
}


  
}