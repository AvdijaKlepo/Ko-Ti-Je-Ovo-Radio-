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
import 'package:provider/provider.dart';

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
  final DateTime _now = DateTime.now();
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
          initialFilter: {
            'FreelancerId': AuthProvider.freelancer?.freelancerId,
            'JobDate': _now.toIso8601String().split('T')[0],
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
              filter: filter,
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
      await jobPagination.refresh();
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
      await jobPagination.refresh(newFilter: {
        'FreelancerId': AuthProvider.freelancer?.freelancerId,
        'JobDate': _now.toIso8601String().split('T')[0],
        'JobStatus': _selectedOption.name,
        'isTenderFinalized': false,
        'OrderBy': 'desc',
        'isDeleted': false,
      });
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
                Center(
                  child: Text(
                    'Raspored za ${DateFormat('dd.MM.yyyy').format(_now)}',
                  
                  ),
                ),
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
                   jobPagination.items.isEmpty ? const Center(child: Text('Nema rezervisanih poslova za danas.')) : 
                  
                   ListView.separated(
                    separatorBuilder: (context, index) => const Divider(height: 35),
                    controller: _scrollController,
                    itemCount: jobPagination.items.length + (jobPagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
    
                     
                      final job = jobPagination.items[index];
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
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ApproveJob(
                  job: job,
                  freelancer: job.freelancer!,
                ),
              ),
            );
            await jobPagination.refresh(newFilter: {
              'FreelancerId': AuthProvider.freelancer?.freelancerId,
              'JobDate': _now.toIso8601String().split('T')[0],
              'JobStatus': _selectedOption.name,
              'isTenderFinalized': false,
              'OrderBy': 'desc',
              'isDeleted': false,
            });
           
          },
          leading: const Icon(Icons.info_outline, color: Colors.white),
          title: Text(
            "Datum: ${DateFormat('dd-MM-yyyy').format(job.jobDate)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: job.user != null
              ? Text(
                  "Korisnik: ${job.user?.firstName} ${job.user?.lastName}\nAdresa: ${job.user?.address}\n${job.isInvoiced == true ? 'Plaćen' : 'Nije plaćen'}",
                  style: const TextStyle(color: Colors.white),
                )
              : null,
          trailing: const Icon(Icons.construction_outlined, color: Colors.white),
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



