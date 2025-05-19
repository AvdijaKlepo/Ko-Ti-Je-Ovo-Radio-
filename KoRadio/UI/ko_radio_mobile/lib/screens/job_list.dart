import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:provider/provider.dart';

class JobList extends StatefulWidget {
const JobList({ super.key}); 

  

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> {
  late JobProvider jobProvider;
  SearchResult<Job>? result;
  int selectedIndex=0;



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
    var filter = {'FreelancerId:':AuthProvider.freelancer?.freelancerId};

    var job = await jobProvider.get(filter: filter);
    setState(() {
      result = job;
    });
  }




  @override
  Widget build(BuildContext context) {  
      final filterJob = result?.result.where((element) =>element.payInvoice!=null).toList();

      return  DefaultTabController(
        length: 3,
        initialIndex: selectedIndex,


        child: Scaffold(
          
        
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: result != null && result!.result.isNotEmpty
                ? 
                
                
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                      TabBar(
                      onTap: (index) => setState(() {
                        selectedIndex = index;
                   
                        print(result?.result.where((element) => element.payEstimate==null && element.payEstimate!=null || element.endEstimate!=null).length);
                      }),
                      indicatorColor: Colors.blue,
  labelColor: Colors.blue,
  unselectedLabelColor: Colors.grey,
          tabs: <Widget>[
            Tab(icon: Icon(Icons.check_circle),text: 'Završeni',),
            Tab(icon: Icon(Icons.hourglass_top),text: 'Trenutni',),
            Tab(icon: Icon(Icons.cancel),text:'Neodobreni'),
          ],
        ),
        SizedBox(height: 15,),
        if(selectedIndex==0)Text('Broj završenih poslova: ${result?.result.where((element) => element.payInvoice!=null).length}',style: Theme.of(context).textTheme.titleMedium,),
        if(selectedIndex==1)Text('Broj poslova u toku: ${result?.result.where((element) => element.payInvoice==null && element.payEstimate!=null).length}',style: Theme.of(context).textTheme.titleMedium,),
        if(selectedIndex==2)Text('Broj neodobrenih poslova: ${result?.result.where((element) => element.payInvoice==null && element.payEstimate==null).length}',style: Theme.of(context).textTheme.titleMedium,),

        
                      const SizedBox(height: 16),
                    
                      Expanded(
                        child: TabBarView(
                          children: [
                     
                            _finishedJobs(context),
                            _jobsInProgress(context),
                            _unapprovedJobs(context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Historija završenih poslova je prazna.')  ,
                        SizedBox(height: 16),
                     
                      ],
                    ),
                  ),
          ),
        ),
      );
  }
  Widget _finishedJobs(BuildContext context) {
  final filterJob = result?.result.where((element) =>element.payInvoice!=null).toList();
  return ListView.builder(
                          itemCount: filterJob?.length,
                          itemBuilder: (context, index) {
                            final job = filterJob?[index];
                       
                            return Card(
                              

                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(

                                leading: const Icon(Icons.access_time, color: Colors.blue),
                                title: Text(
                                  "Datum: ${job?.jobDate.toIso8601String().split('T')[0]}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: job?.user != null
                                    ? Text("Korisnik: ${job?.user?.firstName} ${job?.user?.lastName}")
                                    : null,
                                trailing: const Icon(Icons.work_outline),
          
                              ),
                            );
                          },
                        );
                   
}
Widget _jobsInProgress(BuildContext context) {
  final filterJob = result?.result.where((element) =>element.payInvoice==null && element.payEstimate!=null).toList();
  return ListView.builder(
                          itemCount: filterJob?.length,
                          itemBuilder: (context, index) {
                            final job = filterJob?[index];
                       
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.access_time, color: Colors.blue),
                                title: Text(
                                  "Datum: ${job?.jobDate.toIso8601String().split('T')[0]}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: job?.user != null
                                    ? Text("Korisnik: ${job?.user?.firstName} ${job?.user?.lastName}")
                                    : null,
                                trailing: const Icon(Icons.work_outline),
          
                              ),
                            );
                          },
                        );
                      
}
Widget _unapprovedJobs(BuildContext context) {
  final filterJob = result?.result.where((element) =>element.payEstimate==null && element.endEstimate==null).toList();
  return ListView.builder(
                          itemCount: filterJob?.length,
                          itemBuilder: (context, index) {
                            final job = filterJob?[index];
                       
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.access_time, color: Colors.blue),
                                title: Text(
                                  "Datum: ${job?.jobDate.toIso8601String().split('T')[0]}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: job?.user != null
                                    ? Text("Korisnik: ${job?.user?.firstName} ${job?.user?.lastName}")
                                    : null,
                                trailing: const Icon(Icons.work_outline),
          
                              ),
                            );
                          },
                        );
                    
}
}

