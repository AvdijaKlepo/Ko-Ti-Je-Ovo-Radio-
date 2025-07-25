import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';

import 'package:ko_radio_mobile/screens/book_job.dart';

import 'package:provider/provider.dart';
import 'package:ko_radio_mobile/models/job_status.dart';

class FreelancerDaySchedule extends StatefulWidget {
  const FreelancerDaySchedule(this.selectedDay, this.freelancerId, {super.key});
  final DateTime selectedDay;
  final Freelancer? freelancerId;

  


  @override
  State<FreelancerDaySchedule> createState() => _FreelancerDayScheduleState();
}

class _FreelancerDayScheduleState extends State<FreelancerDaySchedule> {
  late JobProvider jobProvider;
  SearchResult<Job>? result;
  bool _isLoading = false;
 
  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading=true;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      jobProvider = context.read<JobProvider>();
      _getServices();
      setState(() {
        _isLoading=false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    jobProvider = context.read<JobProvider>();
  }

  _getServices() async {
    setState(() {
      _isLoading=true;
    });
    var filter={'FreelancerId':widget.freelancerId?.freelancerId,'JobDate':widget.selectedDay.toIso8601String().split('T')[0],
    'JobStatus':JobStatus.approved.name
    
    };

   
    var freelancer = await jobProvider.get(filter: filter);
  
    setState(() {
      result = freelancer;
      _isLoading=false;
    });
  }
  @override 
  void dispose() {
    super.dispose();
  }

  @override
Widget build(BuildContext context) { 

  return Scaffold(appBar: AppBar(
    scrolledUnderElevation: 0,
    centerTitle: true,
    title:Text( 'Raspored ${widget.freelancerId!.freelancerNavigation?.firstName}a',style: TextStyle(color: Color.fromRGBO(27, 76, 125, 1),fontFamily: GoogleFonts.lobster().fontFamily),),
  

  ),body:   Padding(
        padding: const EdgeInsets.all(16.0),
        child: result != null && result!.result.isNotEmpty
            ? Scaffold(
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ukupno termina: ${result! .result.length}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: result?.result.length,
                        itemBuilder: (context, index) {
                          final job = result!.result[index];
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
                        style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(27, 76, 125, 1),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookJob(
                              selectedDay: widget.selectedDay,
                              freelancer: widget.freelancerId,
                              bookedJobs: result!.result,
                            
                       
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add,color: Colors.white,),
                        label: const Text('Dodaj termin',style:TextStyle( color: Colors.white),),
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
                       Text('Nema termina za ovaj dan.',style: TextStyle(fontFamily: GoogleFonts.robotoCondensed().fontFamily),),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(27, 76, 125, 1),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
                        onPressed: () => 
                        
                        
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookJob(
                              selectedDay: widget.selectedDay,
                              freelancer: widget.freelancerId
                       
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add,color: Colors.white,),
                        label: const Text('Rezerviši',style: TextStyle(color: Colors.white),),
                      )
                    ],
                  ),
                ),
            ),
      ));
 
}
}