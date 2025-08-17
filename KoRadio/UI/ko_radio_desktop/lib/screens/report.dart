import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/freelancer.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/store.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:ko_radio_desktop/providers/user_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';


class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  late UserProvider userProvider;
  late FreelancerProvider freelancerProvider;
  late CompanyProvider companyProvider;
  late StoreProvider storeProvider;
  late CompanyEmployeeProvider companyEmployeeProvider;
  late JobProvider jobProvider;
  SearchResult<User>? userResult;
  SearchResult<Company>? companyResult;
  SearchResult<Store>? storeResult;
  SearchResult<CompanyEmployee>? companyEmployeeResult;
  SearchResult<Freelancer>? freelancerResult;
  SearchResult<Job>? jobResult;
  @override 
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {  
        userProvider = context.read<UserProvider>();
        freelancerProvider = context.read<FreelancerProvider>();
        companyProvider = context.read<CompanyProvider>();
        storeProvider = context.read<StoreProvider>();
        companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
        jobProvider = context.read<JobProvider>();
     await _loadUsers();
     await _loadCompanies();
     await _loadStores();
     await _loadCompanyEmployees();
     await _loadFreelancers();
     await _loadJobs();
    });

 

  }
  Future<void> _loadJobs() async {
  try {
    final fetchedJobs = await jobProvider.get();
    if (!mounted) return;
    setState(() {
      jobResult = fetchedJobs;
    });
  } on Exception catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}

Future<void> _loadCompanies() async {
  try {
    final fetchedCompanies = await companyProvider.get();
    if (!mounted) return;
    setState(() {
      companyResult = fetchedCompanies;
    });
  } on Exception catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}

Future<void> _loadStores() async {
  try {
    final fetchedStores = await storeProvider.get();
    if (!mounted) return;
    setState(() {
      storeResult = fetchedStores;
    });
  } on Exception catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}

Future<void> _loadCompanyEmployees() async {
  try {
    final fetchedCompanyEmployees = await companyEmployeeProvider.get();
    if (!mounted) return;
    setState(() {
      companyEmployeeResult = fetchedCompanyEmployees;
    });
  } on Exception catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}

Future<void> _loadFreelancers() async {
  try {
    final fetchedFreelancers = await freelancerProvider.get();
    if (!mounted) return;
    setState(() {
      freelancerResult = fetchedFreelancers;
    });
  } on Exception catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}

Future<void> _loadUsers() async {
  try {
    final fetchedUsers = await userProvider.get();
    if (!mounted) return;
    setState(() {
      userResult = fetchedUsers;
    });
  } on Exception catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}
  Future<void> _generatePdf() async {
  final pdf = pw.Document();

  var otkazane = (jobResult?.result ?? [])
      .where((e) => e.jobStatus == JobStatus.cancelled)
      .length;
  var ukupno = (jobResult?.result ?? []).length;
  var stopaOtkazivanja = ukupno > 0 ? (otkazane / ukupno) * 100 : 0;
  try {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Broj korisnika aplikacije: ${userResult?.count ?? 0}',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.Text('Broj radnika: ${freelancerResult?.count ?? 0}',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.Text('Broj firma: ${companyResult?.count ?? 0}',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.Text(
                  'Stopa otkazivanja poslova: ${formatNumber(stopaOtkazivanja)}%',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.Text('Ukupan broj poslova: ${jobResult?.count ?? 0}',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final vrijeme = DateTime.now();
    String path =
        '${dir.path}/Izvjestaj-Dana-${formatDate(vrijeme.toString())}.pdf';
    File file = File(path);
    file.writeAsBytes(await pdf.save());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Izvještaj uspješno sačuvan')),
    );
  } on Exception catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
 
      body: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
   
    
        children: [
          Text('Pregled statistike aplikacije',style: TextStyle(fontSize: 35,fontFamily: GoogleFonts.lobster().fontFamily),),
          const SizedBox(height: 200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
             
                color: Colors.white,
                
                
                child: SizedBox(
                  width: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.person_outline, size: 50),
                        const SizedBox(height: 16),
                        ListTile(
                          
                          title:const Text(
                          'Broj aktivnih korisnika',
                          style: TextStyle(fontSize: 16),
                  
                        ),
                        
                        subtitle: Center(
                          child: Text(
                            '${userResult?.count}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ),
                      
                      ]
                    ),
                                ),
                ),
            ),
           Card(
             
                color: Colors.white,
                
                
                child: SizedBox(
                  width: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.construction_outlined, size: 50),
                        const SizedBox(height: 16),
                        ListTile(
                          
                          title:const Text(
                          'Broj aktivnih radnika',
                          style: TextStyle(fontSize: 16),
                  
                        ),
                        subtitle: Center(
                          child: Text(
                            '${freelancerResult?.count}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ),
                      
                      ]
                    ),
                                ),
                ),
            ),
           Card(
             
                color: Colors.white,
                
                
                child: SizedBox(
                  width: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.business_outlined, size: 50),
                        const SizedBox(height: 16),
                        ListTile(
                          
                          title:const Text(
                          'Broj aktivnih kompanija',
                          style: TextStyle(fontSize: 16),
                  
                        ),
                        subtitle: Center(
                          child: Text(
                            '${companyResult?.count}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ),
                      
                      ]
                    ),
                                ),
                ),
            ),
           Card(
             
                color: Colors.white,
                
                
                child: SizedBox(
                  width: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.person_4_outlined, size: 50),
                        const SizedBox(height: 16),
                        ListTile(
                          
                          title:const Text(
                          'Broj aktivnih zaposlenika firma',
                          style: TextStyle(fontSize: 16),
                  
                        ),
                        subtitle: Center(
                          child: Text(
                            '${companyEmployeeResult?.count}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ),
                      
                      ]
                    ),
                                ),
                ),
            ),
             Card(
             
                color: Colors.white,
                
                
                child: SizedBox(
                  width: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.store_outlined, size: 50),
                        const SizedBox(height: 16),
                        ListTile(
                          
                          title:const Text(
                          'Broj aktivnih trgovina',
                          style: TextStyle(fontSize: 16),
                  
                        ),
                        subtitle: Center(
                          child: Text(
                            '${storeResult?.count}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ),
                      
                      ]
                    ),
                                ),
                ),
            ),
            ],
            
          ),
          const SizedBox(height: 20,),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
               Card(
                 
                    color: Colors.white,
                    
                    
                    child: SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.work_outline, size: 50),
                            const SizedBox(height: 16),
                            ListTile(
                              
                              title:const Text(
                              'Broj obrađenih poslova',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${jobResult?.result.where((element) => element.jobStatus==JobStatus.finished).length}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ),
                          
                          ]
                        ),
                                    ),
                    ),
                ),
                  Card(
                 
                    color: Colors.white,
                    
                    
                    child: SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.work_outline, size: 50),
                                Icon(Icons.construction, size: 50),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            ListTile(
                              
                              title:const Text(
                              'Broj obrađenih poslova od radnika',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${jobResult?.result.where((element) => element.jobStatus==JobStatus.finished && element.freelancer?.freelancerId!=null).length}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ),
                          
                          ]
                        ),
                                    ),
                    ),
                ),
                   Card(
                 
                    color: Colors.white,
                    
                    
                    child: SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.work_outline, size: 50),
                                Icon(Icons.business_outlined, size: 50),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              
                              title:const Text(
                              'Broj obrađenih poslova od firma',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${jobResult?.result.where((element) => element.jobStatus==JobStatus.finished && element.company?.companyId!=null).length}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ),
                          
                          ]
                        ),
                                    ),
                    ),
                ),
                 Card(
                 
                    color: Colors.white,
                    
                    
                    child: SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.work_history_outlined, size: 50),
                            const SizedBox(height: 16),
                            ListTile(
                              
                              title:const Text(
                              'Broj poslova u toku',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${jobResult?.result.where((element) => element.jobStatus==JobStatus.approved).length}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ),
                          
                          ]
                        ),
                                    ),
                    ),
                ),
               
                  Card(
                 
                    color: Colors.white,
                    
                    
                    child: SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.work_off_outlined, size: 50),
                            const SizedBox(height: 16),
                            ListTile(
                              
                              title:const Text(
                              'Broj otkazanih poslova',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${jobResult?.result.where((element) => element.jobStatus==JobStatus.cancelled).length}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ),
                          
                          ]
                        ),
                                    ),
                    ),
                ),
                
             ],
           ),
           SizedBox(height: 10,),
          

           _buildStats(),
                SizedBox(height: 10,),
            Center(
            child:  ElevatedButton(onPressed: (){
             _generatePdf();
           }, child: const Text('Generiši izvještaj',style: TextStyle(color: Colors.white),),
           
           style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B4C7D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
           ),
          ),
            ),
          
        ],
      )
    );
  }
   Widget _buildStats() {
  if (jobResult == null || jobResult!.result.isEmpty) {
    return const Center(
      child: Text(
        'Trenutno nema podataka za prikazati',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  // Filter only valid jobs (exclude cancelled if needed)
  List<Job> jobsList = jobResult!.result
      .where((element) => element.jobStatus != JobStatus.cancelled)
      .toList();

  // Count jobs per month based on jobDate
  List<int> jobsPerMonth = List.filled(12, 0);
  for (var job in jobsList) {
    int monthIndex = job.jobDate.month - 1; // 0-based index
    jobsPerMonth[monthIndex]++;
  }

  // Define months
  List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  // Generate chart points
  List<FlSpot> spots = List.generate(
    12,
    (index) => FlSpot(index.toDouble(), jobsPerMonth[index].toDouble()),
  );

  // Calculate max Y (rounded up to next multiple of 5)
  double maxValue = jobsPerMonth.isNotEmpty
      ? jobsPerMonth.reduce((a, b) => a > b ? a : b).toDouble()
      : 1;
  double maxY = ((maxValue ~/ 5) + 1) * 5;

  return Padding(
    padding: const EdgeInsets.all(15),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: const Color(0xFF1B4C7D),
        width: double.infinity,
        height: 600,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Broj poslova po mjesecima ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        color: Colors.white,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            if (value % 5 == 0) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white),
                              );
                            }
                            return Container();
                          },
                        ),
                        axisNameWidget: const Text(
                          "Broj poslova",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        axisNameSize: 30,
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 && value < months.length) {
                              return Text(
                                months[value.toInt()],
                                style: const TextStyle(color: Colors.white),
                              );
                            }
                            return Container();
                          },
                        ),
                        axisNameWidget: const Text(
                          "Mjesec",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        axisNameSize: 30,
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}