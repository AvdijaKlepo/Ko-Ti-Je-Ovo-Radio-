import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/screens/approve_job.dart';

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
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    jobProvider = context.read<JobProvider>();
  }

  Future<void> _getJobs(var filter) async {
    try {
      var job = await jobProvider.get(filter: filter);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Greška tokom dohvaćanja poslova: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: result != null && result!.result.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Text(
                  'Raspored za ${DateFormat('dd.MM.yyyy').format(now)}',
                )),
                Center(
                  child: SegmentedButton<options>(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(20, 60, 100, 1)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<options>>[
                      ButtonSegment(
                          value: options.Neodobreni,
                          label: Text('Neodobreni'),
                          icon: Icon(Icons.check_box_outline_blank_outlined)),
                      ButtonSegment(
                          value: options.Odobreni,
                          label: Text('Odobreni'),
                          icon: Icon(Icons.check_box_outlined)),
                    ],
                    selected: <options>{view},
                    onSelectionChanged: (Set<options> newSelection) {
                      setState(() {
                        view = newSelection.first;
                        if (view == options.Neodobreni) {
                          var filter = {
                            'FreelancerId':
                                AuthProvider.freelancer?.freelancerId,
                            'JobDate': now.toIso8601String().split('T')[0],
                            'JobStatus': JobStatus.unapproved.name
                          };
                          try {
                            print(DateTime.now());
                            _getJobs(filter);
                          } on Exception catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Greška tokom dohvaćanja poslova: ${e.toString()}')));
                          }
                        } else {
                          var filter = {
                            'FreelancerId':
                                AuthProvider.freelancer?.freelancerId,
                            'JobDate': now.toIso8601String().split('T')[0],
                            'JobStatus': JobStatus.approved.name
                          };
                          try {
                            _getJobs(filter);
                          } on Exception catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Greška tokom dohvaćanja poslova: ${e.toString()}')));
                          }
                        }
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
                        color: const Color.fromRGBO(27, 76, 125, 25),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          onTap: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ApproveJob(
                                    job: job, freelancer: job.freelancer!)));
                          },
                          leading: const Icon(Icons.access_time,
                              color: Colors.white),
                          title: Text(
                            "Datum: ${job.jobDate.toIso8601String().split('T')[0]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          subtitle: job.user != null
                              ? Text(
                                  "Korisnik: ${job.user?.firstName} ${job.user?.lastName}\nAdresa: ${job.user?.address}\n${job.isInvoiced == true ? 'Plaćen' : 'Nije plaćen'}",
                                  style: const TextStyle(color: Colors.white))
                              : null,
                          trailing: const Icon(Icons.work_outline,
                              color: Colors.white),
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                      child: Text(
                    'Raspored za ${DateFormat('dd.MM.yyyy').format(now)}',
                  )),
                  Center(
                    child: SegmentedButton<options>(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(20, 60, 100, 1)),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                      ),
                      showSelectedIcon: false,
                      segments: const <ButtonSegment<options>>[
                        ButtonSegment(
                            value: options.Neodobreni,
                            label: Text('Neodobreni'),
                            icon: Icon(Icons.check_box_outline_blank_outlined)),
                        ButtonSegment(
                            value: options.Odobreni,
                            label: Text('Odobreni'),
                            icon: Icon(Icons.check_box_outlined)),
                      ],
                      selected: <options>{view},
                      onSelectionChanged: (Set<options> newSelection) {},
                    ),
                  ),
                  Text('Nema terminova za ovaj dan.'),
                ],
              ),
            ),
    );
  }
}
