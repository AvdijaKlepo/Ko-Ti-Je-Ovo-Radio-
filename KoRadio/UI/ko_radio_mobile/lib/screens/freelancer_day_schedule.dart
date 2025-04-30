import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/screens/book_job.dart';
import 'package:provider/provider.dart';

class FreelancerDaySchedule extends StatefulWidget {
  FreelancerDaySchedule(this.selectedDay, this.freelancerId, {super.key});
  DateTime selectedDay;
  final int? freelancerId;

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
    var freelancer = await jobProvider.get();
    setState(() {
      result = freelancer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: Scaffold(
        body: result == null
            ? Center(child: CircularProgressIndicator())
            : (result!.result.isEmpty
                ? Center(
                    child: ElevatedButton(
                      child: Text('Rezerviši'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookJob(selectedDay:  widget.selectedDay,freelancerId: widget.freelancerId,),
                          ),
                        );
                      },
                    ),
                  )
                : ListView.builder(
                    itemCount: result!.result.length,
                    itemBuilder: (context, index) {
                      var e = result!.result[index];

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
                                    Column(
                                      children: [
                                        Text('Početak: ${e.startEstimate}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text('Završetak: ${e.endEstimate}'),
                                      ],
                                    ),
                                  ],
                                ),
                                  
                              ],

                            ),
                          ),
                          
                        ],
                        
                      );
                      
                    },
                    
                    
                  )),
                  
                  floatingActionButton:   ElevatedButton(
                              child: Text('Rezerviši'),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookJob(selectedDay: widget.selectedDay,),
                                  ),
                                );
                              },
                            ),
                            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                          
      ),
    );
  }
}
