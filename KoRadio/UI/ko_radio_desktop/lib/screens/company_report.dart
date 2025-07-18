import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fl_chart/fl_chart.dart';

class CompanyReport extends StatefulWidget {
  const CompanyReport({super.key});

  @override
  State<CompanyReport> createState() => _CompanyReportState();
}

class _CompanyReportState extends State<CompanyReport> {
  late CompanyProvider companyProvider;
  late CompanyEmployeeProvider companyEmployeeProvider;
  late JobProvider jobProvider;
  SearchResult<CompanyEmployee>? companyEmployeeResult;
  SearchResult<Job>? jobResult;
  SearchResult<Company>? companyResult;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      companyProvider = context.read<CompanyProvider>();
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
      jobProvider = context.read<JobProvider>();
     await _getCompanyEmployees();
     await _getJobs();
     await _getCompanies();
    });
  }

  Future<void> _getCompanies() async {
    var filter = {'CompanyId':AuthProvider.selectedCompanyId};
    try {
      final fetchedCompanies = await companyProvider.get(filter: filter);
      setState(() {
        companyResult = fetchedCompanies;
      });
    } catch (e) {
      if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
    }
  }

  Future<void> _getCompanyEmployees() async {
    var filter = {'CompanyId':AuthProvider.selectedCompanyId};
    try {
      final fetchedCompanyEmployees = await companyEmployeeProvider.get(filter:   filter);
      setState(() {
        companyEmployeeResult = fetchedCompanyEmployees;
      });
    } catch (e) {
      if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
    }
  }

  Future<void> _getJobs() async {
    var filter = {'CompanyId':AuthProvider.selectedCompanyId};
    try {
      final fetchedJobs = await jobProvider.get(filter: filter);
      setState(() {
        jobResult = fetchedJobs;
      });
    } catch (e) {
      if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
    }
  }
   Future<void> _generatePdf() async {
    final summedInvoice = (jobResult?.result ?? [])
    .where((e) => e.jobStatus == JobStatus.finished)
    .fold<double>(0, (sum, e) => sum + (e.payInvoice ?? 0));

   
    final pdf = pw.Document();
  final fontData = await rootBundle.load("assets/fonts/Roboto-VariableFont_wdth,wght.ttf");
  final ttf = pw.Font.ttf(fontData);

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
                
                pw.Text('Broj završenih poslova: ${jobResult?.result.where((element) => element.jobStatus==JobStatus.finished).length ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
                      pw.Text('Broj poslova u toku: ${jobResult?.result.where((element) => element.jobStatus==JobStatus.approved).length ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
                    pw.Text('Broj ne prihvaćenih poslova: ${jobResult?.result.where((element) => element.jobStatus==JobStatus.unapproved).length ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
                      pw.Text('Broj otkazanih poslova: ${jobResult?.result.where((element) => element.jobStatus==JobStatus.cancelled).length ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
                     pw.Text('Ukupna zarada: ${summedInvoice ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
                pw.Text(
                    'Stopa otkazivanja poslova: ${formatNumber(stopaOtkazivanja)}%',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
                pw.Text('Ukupan broj poslova: ${jobResult?.count ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
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
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izvještaj uspješno sačuvan')),
      );
    } on Exception catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
     final summedInvoice = (jobResult?.result ?? [])
    .where((e) => e.jobStatus == JobStatus.finished)
    .fold<double>(0, (sum, e) => sum + (e.payInvoice ?? 0));


    return Scaffold(
 
      body: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
   
    
        children: [
          Text('Pregled statistike za kompaniju ${companyResult?.result.first.companyName}',style: TextStyle(fontSize: 35,fontFamily: GoogleFonts.lobster().fontFamily),),
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
                        const Icon(Icons.person_4_outlined, size: 50),
                        const SizedBox(height: 16),
                        ListTile(
                          
                          title:const Text(
                          'Broj aktivnih zaposlenika firme',
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
                              'Ukupna zarada',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${summedInvoice ?? 0}',
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
          
           const SizedBox(height: 10,),
          

           _buildStats(),
                const SizedBox(height: 10,),
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

 
  List<Job> jobsList = jobResult!.result
      .where((element) => element.jobStatus != JobStatus.cancelled && element.jobStatus==JobStatus.finished)
      .toList();

  List<int> jobsPerMonth = List.filled(12, 0);
  for (var job in jobsList) {
    int monthIndex = job.jobDate.month - 1; 
    jobsPerMonth[monthIndex]++;
  }


  List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];


  List<FlSpot> spots = List.generate(
    12,
    (index) => FlSpot(index.toDouble(), jobsPerMonth[index].toDouble()),
  );

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
                    gridData: const FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false),
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