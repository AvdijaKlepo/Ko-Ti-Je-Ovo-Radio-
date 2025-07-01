import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/screens/book_company_job.dart';
import 'package:provider/provider.dart';

class CompanyJob extends StatefulWidget {
  const CompanyJob({super.key});

  @override
  State<CompanyJob> createState() => _CompanyJobState();
}

class _CompanyJobState extends State<CompanyJob> {
  late JobProvider jobProvider;
  final _companyId = AuthProvider.selectedCompanyId;
  final Map<JobStatus, List<Job>> jobMap = {};

  final List<JobStatus> jobStatuses = [
    JobStatus.finished,
    JobStatus.approved,
    JobStatus.unapproved,
    JobStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    jobProvider = context.read<JobProvider>();
    _loadAllJobs();
  }

  Future<void> _loadAllJobs() async {
    for (final status in jobStatuses) {
      final filter = {
        'companyId': _companyId,
        'JobStatus': status.name,
      };

      try {
        final result = await jobProvider.get(filter: filter);
        setState(() {
          jobMap[status] = result.result;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška prilikom učitavanja poslova: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < jobStatuses.length; i++) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildJobStatusColumn(jobStatuses[i]),
              ),
            ),
            // Add a vertical divider between columns, except after the last one
            if (i != jobStatuses.length - 1) ...[
              const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),
              const VerticalDivider(width: 1, thickness: 1, color: Colors.black12),
            ]
          ],
        ],
      ),
    );
  }

  Widget _buildJobStatusColumn(JobStatus status) {
    final jobs = jobMap[status] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _statusHeader(status),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTableHeader(),
        const Divider(),
        Expanded(
          child: jobs.isEmpty
              ? const Center(child: Text('Nema poslova.', style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) => _buildJobRow(jobs[index]),
                ),
        ),
      ],
    );
  }

  String _statusHeader(JobStatus status) {
    switch (status) {
      case JobStatus.finished:
        return "Završeni";
      case JobStatus.approved:
        return "Odobreni";
      case JobStatus.unapproved:
        return "Neodobreni";
      case JobStatus.cancelled:
        return "Otkazani";
      default:
        return "Poslovi";
    }
  }

  Widget _buildTableHeader() {
    return Row(
      children:  [
        Expanded(flex: 2, child: Text("Posao", style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 2, child: Text("Korisnik", style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 3, child: Text("Datum", style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 3, child: IconButton(icon: Icon(Icons.arrow_right), onPressed: () {})),
      ],
    );
  }

  Widget _buildJobRow(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: 
  
        Row(
          children: [
            Expanded(flex: 2, child: Text("Posao #${job.jobId}")),
            Expanded(flex: 2, child: Text('${job.user?.firstName ?? ''} ${job.user?.lastName ?? ''}')),
            Expanded(flex: 3, child: Text(job.jobDate.toLocal().toString().split(' ').first)),
            Expanded(flex: 3, child: IconButton(icon: const Icon(Icons.arrow_right), onPressed: () {
              showDialog(
  context: context,
  barrierDismissible: true, 
  builder: (context) => BookCompanyJob(job),

);
_loadAllJobs();

            })),
          ],
        ),
      
    );
  }
}
