import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/book_job.dart';
import 'package:provider/provider.dart';

class FreelancerDaySchedule extends StatefulWidget {
  FreelancerDaySchedule(this.selectedDay, this.freelancerId, {super.key});
  DateTime selectedDay;
  final Freelancer? freelancerId;
  


  @override
  State<FreelancerDaySchedule> createState() => _FreelancerDayScheduleState();
}

class _FreelancerDayScheduleState extends State<FreelancerDaySchedule> {
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
    var filter={'FreelancerId':widget.freelancerId?.freelancerId,'JobDate':widget.selectedDay.toIso8601String().split('T')[0],
    };

   
    var freelancer = await jobProvider.get(filter: filter);
  
    setState(() {
      result = freelancer;
    });
  }

  @override
Widget build(BuildContext context) { 
  final filterJob = result?.result.where((element) => element.payEstimate!=null).toList();
  return Scaffold(appBar: appBar(title: 'Raspored ${widget.freelancerId!.user.firstName}a', automaticallyImplyLeading: true),body:   Padding(
        padding: const EdgeInsets.all(16.0),
        child: result != null && result!.result.isNotEmpty
            ? Scaffold(
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ukupno termina: ${filterJob!.length}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filterJob.length,
                        itemBuilder: (context, index) {
                          final job = filterJob[index];
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
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookJob(
                              selectedDay: widget.selectedDay,
                              freelancer: widget.freelancerId,
                              bookedJobs: filterJob
                            
                       
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Dodaj termin'),
                      ),
                    ),
                  ],
                ),
            )
            : Scaffold(
              body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Nema termina za ovaj dan.'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookJob(
                              selectedDay: widget.selectedDay,
                              freelancer: widget.freelancerId
                       
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Rezerviši'),
                      )
                    ],
                  ),
                ),
            ),
      ));
 
}
}