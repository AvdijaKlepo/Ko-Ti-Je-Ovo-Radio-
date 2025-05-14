import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/screens/book_job.dart';
import 'package:ko_radio_mobile/screens/confirm_job.dart';
import 'package:provider/provider.dart';

class FreelancerJobsScreen extends StatefulWidget {
  const FreelancerJobsScreen({super.key});

  @override
  State<FreelancerJobsScreen> createState() => _FreelancerJobsScreenState();
}

class _FreelancerJobsScreenState extends State<FreelancerJobsScreen> {
  late JobProvider jobProvider;
  SearchResult<Job>? result;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      jobProvider = context.read<JobProvider>();
      _getServices();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    jobProvider = context.read<JobProvider>();
  }

  _getServices() async {
    var filter = {'FreelancerId': AuthProvider.freelancer?.freelancerId};
    var job = await jobProvider.get(filter: filter);
    setState(() {
      result = job;
    });
  }

  @override
  final DateTime now = DateTime.now();

  Widget build(BuildContext context) {
 
  final filterJob = result?.result.where((element) => element.payEstimate==null && element.jobDate.toIso8601String().split('T')[0]==now.toIso8601String().split('T')[0]).toList();

    return MasterScreen(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(child: Text('Raspored za ${DateFormat('dd.MM.yyyy').format(now)}',style: GoogleFonts.roboto(),)),
          ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: result != null && result!.result.isNotEmpty
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text('Dobrodošli ${AuthProvider.user?.firstName} ${AuthProvider.user?.lastName}',style: Theme.of(context).textTheme.titleMedium,)),
                  Center(child: Text('Ukupno zahtjeva: ${filterJob?.length}',style: Theme.of(context).textTheme.titleMedium,)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filterJob?.length,
                      itemBuilder: (context, index) {
                        final job = filterJob![index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.access_time, color: Colors.blue),
                            title: Text(
                              "Početak: ${job.startEstimate}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: job.endEstimate != null
                                ? Text("Kraj: ${job.endEstimate}")
                                : null,
                            trailing: const Icon(Icons.work_outline),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                
                ],
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Nema terminova za ovaj dan.'),
                   
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
