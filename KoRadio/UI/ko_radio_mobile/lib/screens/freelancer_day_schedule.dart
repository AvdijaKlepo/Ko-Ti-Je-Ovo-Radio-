import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
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
  SearchResult<Job>? jobResult;
  bool _isLoading = false;
  bool _userMadeJobs = false;
 
  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading=true;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      jobProvider = context.read<JobProvider>();
        await _getJobs();
      await _getServices();
    
      setState(() {
        _isLoading=false;
      });
        if(jobResult?.result.any((element) => element.user?.userId == AuthProvider.user?.userId)==true
                      || result?.result.any((element) => element.user?.userId==AuthProvider.user?.userId)==true)
                      {
                        setState(() {
                          _userMadeJobs=true;
                        });
                     
                      }
    });
   
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    jobProvider = context.read<JobProvider>();
  }


 Future<void> _getServices() async {
    setState(() {
      _isLoading=true;
    });
    var filter={'FreelancerId':widget.freelancerId?.freelancerId,'DateRange':widget.selectedDay.toIso8601String().split('T')[0],
    'JobStatus':JobStatus.approved.name
    
    };

   
    var freelancer = await jobProvider.get(filter: filter);
  
    setState(() {
      result = freelancer;
      _isLoading=false;
    });
  }
   Future<void> _getJobs() async {
    setState(() {
      _isLoading=true;
    });
    var filter={'FreelancerId':widget.freelancerId?.freelancerId,'DateRange':widget.selectedDay.toIso8601String().split('T')[0],
    'JobStatus':JobStatus.unapproved.name
    
    };

   
    var freelancer = await jobProvider.get(filter: filter);
  
    setState(() {
      jobResult = freelancer;
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
    
  

  ),body: 
  
   _isLoading ? const Center(child: CircularProgressIndicator())
   : result!.result.isEmpty==true ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ 
                     _userMadeJobs==true ?
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Padding(
                         padding: const EdgeInsets.all(15.0),
                         child: Center(child: Text('Već ste napravili zahtjev za posao sa ovim radnikom. Ako trebate nove usluge, molimo uredite već postojeći posao.',style: TextStyle(fontFamily: GoogleFonts.robotoCondensed().fontFamily,color: Colors.black),)),
                       ),
                     ):
                
                     
                     
                       Text('Raspored slobodan za ${DateFormat('dd-MM-yyyy').format(widget.selectedDay)}.',style: TextStyle(fontFamily: GoogleFonts.robotoCondensed().fontFamily,color: Colors.black),),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        
                        style: ElevatedButton.styleFrom(backgroundColor: _userMadeJobs==false ? Color.fromRGBO(27, 76, 125, 1): Colors.grey,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
                        onPressed: () => 
                        _userMadeJobs==false ?
                        
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookJob(
                              selectedDay: widget.selectedDay,
                              freelancer: widget.freelancerId
                       
                            ),
                          ),
                        ) : null,
                        icon: const Icon(Icons.add,color: Colors.white,),
                        label: const Text('Rezerviši',style: TextStyle(color: Colors.white),),
                      )
                    ],
                  ),
                )
   
    : SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                   
                    children:<Widget> [
                      Center(
                        child:   Text(
                        "${DateFormat('dd-MM-yyyy').format(widget.selectedDay)}",
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Color.fromRGBO(27, 76, 125, 1),fontFamily: GoogleFonts.lobster().fontFamily,letterSpacing: 1.2),
                      ),
                      ),
                     Center(
                      child: Text(
                        "Broj termina: ${result?.result.length ?? 0}",
                        style: TextStyle(fontSize: 16),
                      ) ,
                     )
                     ,
                      const SizedBox(height: 16),
                    
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          
      
                          separatorBuilder: (context, index) => const Divider(height: 35),
                          itemCount: result?.result.length ?? 0,
                          itemBuilder: (context, index) {
                            final job = result!.result[index];
                            return Card(
      
                              color: const Color.fromRGBO(27, 76, 125, 25),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.info_outline, color: Colors.white),
                                title: Text(
                                  "Početak: ${job.startEstimate.toString().substring(0,5)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                                ),
                                subtitle: job.endEstimate != null
                                    ? Text("Kraj: ${job.endEstimate.toString().substring(0,5)}",style: const TextStyle(color: Colors.white),)
                                    : null,
                                trailing: const Icon(Icons.construction_outlined,color: Colors.white),
      
                              ),
      
      
                            );
                          },
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
                          label: const Text('Rezerviši termin',style:TextStyle( color: Colors.white),),
                        ),
                      ),
                      
             











                    ],
                  ),
              ),
    )
           
      );
 
}
}