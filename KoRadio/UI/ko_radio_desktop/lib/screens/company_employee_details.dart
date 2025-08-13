import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
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

  @override
  void initState() {
    super.initState();
    jobProvider = context.read<JobProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getJob();
    });
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 600,
        height: 500, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: jobResult == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildJobList(jobResult!.result),
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
