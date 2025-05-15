import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/screens/book_job.dart';
import 'package:provider/provider.dart';

enum options { Neodobreni, Odobreni }

class FreelancerJobsScreen extends StatefulWidget {
  const FreelancerJobsScreen({super.key});

  @override
  State<FreelancerJobsScreen> createState() => _FreelancerJobsScreenState();
}

options view = options.Neodobreni;

class _FreelancerJobsScreenState extends State<FreelancerJobsScreen> {
  late JobProvider jobProvider;
  SearchResult<Job>? result;
  List<Job>? filterJob;
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
      filterJob = job.result
          .where((element) =>
              element.payEstimate == null &&
              element.jobDate.toIso8601String().split('T')[0] ==
                  now.toIso8601String().split('T')[0])
          .toList();
    });
  }

  @override
  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
              child: Text(
            'Dobrodošli ${AuthProvider.user?.firstName} ${AuthProvider.user?.lastName}',
            style: Theme.of(context).textTheme.titleLarge,
          )),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: result != null && result!.result.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Text(
                      'Raspored za ${DateFormat('dd.MM.yyyy').format(now)}',
                      style: GoogleFonts.roboto(),
                    )),
                    Center(
                      child: SegmentedButton<options>(
                        showSelectedIcon: false,
                        segments: const <ButtonSegment<options>>[
                          ButtonSegment(
                              value: options.Neodobreni,
                              label: Text('Neodobreni'),
                              icon:
                                  Icon(Icons.check_box_outline_blank_outlined)),
                          ButtonSegment(
                              value: options.Odobreni,
                              label: Text('Odobreni'),
                              icon: Icon(Icons.check_box_outlined)),
                        ],
                        selected: <options>{view},
                        onSelectionChanged: (Set<options> newSelection) {
                          setState(() {
                            view = newSelection.first;
                            final filtered = result?.result
                                .where((element) =>
                                    (view == options.Neodobreni &&
                                        element.payEstimate == null &&
                                        element.jobDate
                                                .toIso8601String()
                                                .split('T')[0] ==
                                            now
                                                .toIso8601String()
                                                .split('T')[0]) ||
                                    (view == options.Odobreni &&
                                        element.payEstimate != null &&
                                        element.jobDate
                                                .toIso8601String()
                                                .split('T')[0] ==
                                            now
                                                .toIso8601String()
                                                .split('T')[0]) && element.payInvoice==null)
                                .toList();
                            filterJob = filtered;
                          });
                        },
                      ),
                    ),
                    Center(
                        child: Text(
                      'Ukupno zahtjeva: ${filterJob?.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
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
                              onTap: () =>
                              
                               Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => BookJob(job:job))),



                              leading: const Icon(Icons.access_time,
                                  color: Colors.blue),
                              title: Text(
                                "Početak termina: ${job.startEstimate.toString().substring(0, 5)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: job.endEstimate != null
                                  ? Text(
                                      "Kraj: ${job.endEstimate.toString().substring(0, 5)}")
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
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nema terminova za ovaj dan.'),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
