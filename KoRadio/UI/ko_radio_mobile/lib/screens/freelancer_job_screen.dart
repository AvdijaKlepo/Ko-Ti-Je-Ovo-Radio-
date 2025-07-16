import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/screens/approve_job.dart';
import 'package:provider/provider.dart';

enum JobViewOption { unapproved, approved }

class FreelancerJobsScreen extends StatefulWidget {
  const FreelancerJobsScreen({Key? key}) : super(key: key);

  @override
  State<FreelancerJobsScreen> createState() => _FreelancerJobsScreenState();
}

class _FreelancerJobsScreenState extends State<FreelancerJobsScreen> {
  late final JobProvider _jobProvider;
  SearchResult<Job>? _jobResult;
  final DateTime _now = DateTime.now();
  JobViewOption _selectedOption = JobViewOption.unapproved;

  @override
  void initState() {
    super.initState();
    // Ensure the context is available on the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jobProvider = context.read<JobProvider>();
      _fetchJobs();
    });
  }

  Future<void> _fetchJobs() async {
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
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching jobs: ${e.toString()}')),
        );
      }
    }
  }

  void _onSegmentChanged(JobViewOption option) {
    if (_selectedOption != option) {
      setState(() {
        _selectedOption = option;
      });
      _fetchJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _jobResult == null || _jobResult!.count == 0
          ? const Center(child: Text('Nema rezervisanih poslova za danas.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Raspored za ${DateFormat('dd.MM.yyyy').format(_now)}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Center(
                  child: SegmentedButton<JobViewOption>(
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
                    'Ukupno: ${_jobResult!.count}',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _jobResult!.count,
                    itemBuilder: (context, index) {
                      final job = _jobResult!.result[index];
                      return JobCard(job: job);
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Job job;
  const JobCard({required this.job, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(27, 76, 125, 25),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ApproveJob(
                job: job,
                freelancer: job.freelancer!,
              ),
            ),
          );
        },
        leading: const Icon(Icons.access_time, color: Colors.white),
        title: Text(
          "Datum: ${job.jobDate.toIso8601String().split('T')[0]}",
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
        trailing: const Icon(Icons.work_outline, color: Colors.white),
      ),
    );
  }
}
