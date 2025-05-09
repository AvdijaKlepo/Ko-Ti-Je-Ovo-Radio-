import 'package:flutter/material.dart';
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
    return MasterScreen(
        child: Scaffold(
            body: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text("${DateFormat().format(now)}"), Text("Danas")],
        ),
        Column(
          children: [
            ListView.builder(
                itemCount: result!.result.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: ((context, index) {
                  var e = result!.result[index];
                  print(e);
                  return Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Vrijeme'),
                                SizedBox(width: 10),
                                Text('Servis'),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => ConfirmJob(e))),
                                  child: Column(
                                    children: [
                                      Text('Početak: ${e.startEstimate}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('Završetak: ${e.endEstimate}'),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                })),
          ],
        )
      ],
    )));
  }
}
