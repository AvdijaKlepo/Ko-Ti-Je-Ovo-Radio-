import 'dart:io';

import 'package:flutter/material.dart';
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

extension NumFormatter on num {
  String format() => this.toInt().toString();
}

class CompanyReport extends StatefulWidget {
  const CompanyReport({super.key});

  @override
  State<CompanyReport> createState() => _CompanyReportState();
}

class _CompanyReportState extends State<CompanyReport> {
  late CompanyProvider companyProvider;
  late CompanyEmployeeProvider companyEmployeeProvider;
  late JobProvider jobProvider;

  SearchResult<Company>? companyResult;
  SearchResult<CompanyEmployee>? companyEmployeeResult;
  SearchResult<Job>? jobResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      companyProvider = context.read<CompanyProvider>();
      companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
      jobProvider = context.read<JobProvider>();
      await _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadCompanies(),
      _loadCompanyEmployees(),
      _loadJobs(),
    ]);
  }

  Future<void> _loadCompanies() async => _loadData(
        () => companyProvider.get(filter: {'CompanyId': AuthProvider.selectedCompanyId}),
        (res) => companyResult = res,
      );

  Future<void> _loadCompanyEmployees() async => _loadData(
        () => companyEmployeeProvider.get(filter: {'CompanyId': AuthProvider.selectedCompanyId}),
        (res) => companyEmployeeResult = res,
      );

  Future<void> _loadJobs() async => _loadData(
        () => jobProvider.get(filter: {'CompanyId': AuthProvider.selectedCompanyId}),
        (res) => jobResult = res,
      );

  Future<void> _loadData<T>(
      Future<SearchResult<T>> Function() fetch, Function(SearchResult<T>) onSet) async {
    try {
      final result = await fetch();
      if (!mounted) return;
      setState(() => onSet(result));
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: ${e.toString()}")));
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final otkazane = (jobResult?.result ?? []).where((e) => e.jobStatus == JobStatus.cancelled).length;
    final ukupno = (jobResult?.result ?? []).length;
    final stopaOtkazivanja = ukupno > 0 ? (otkazane / ukupno) * 100 : 0;
    final ukupnaZarada = (jobResult?.result ?? [])
        .where((e) => e.jobStatus == JobStatus.finished)
        .fold<double>(0, (sum, e) => sum + (e.payInvoice ?? 0));

    try {
      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Column(children: [
          pw.Text('Broj zaposlenika: ${companyEmployeeResult?.count ?? 0}', style: const pw.TextStyle(fontSize: 18)),
          pw.Text('Ukupan broj poslova: ${jobResult?.count ?? 0}', style: const pw.TextStyle(fontSize: 18)),
          pw.Text('Završeni poslovi: ${jobResult?.result.where((e) => e.jobStatus == JobStatus.finished).length ?? 0}', style: const pw.TextStyle(fontSize: 18)),
          pw.Text('Poslovi u toku: ${jobResult?.result.where((e) => e.jobStatus == JobStatus.approved).length ?? 0}', style: const pw.TextStyle(fontSize: 18)),
          pw.Text('Otkazani poslovi: ${otkazane}', style: const pw.TextStyle(fontSize: 18)),
          pw.Text('Ukupna zarada: ${ukupnaZarada}', style: const pw.TextStyle(fontSize: 18)),
          pw.Text('Stopa otkazivanja: ${stopaOtkazivanja.toStringAsFixed(2)}%', style: const pw.TextStyle(fontSize: 18)),
        ]),
      ));

      final dir = await getApplicationDocumentsDirectory();
      final vrijeme = DateTime.now();
      final path = '${dir.path}/Izvjestaj-Firme-${formatDate(vrijeme.toString())}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izvještaj uspješno sačuvan')));
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Izvještaj firme',
                style: TextStyle(fontSize: 36, fontFamily: GoogleFonts.lobster().fontFamily),
              ),
              const SizedBox(height: 20),

              // Grid dashboard
              LayoutBuilder(builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth ~/ 280;
                return Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _dashboardCard('Zaposlenici', Icons.person_4_outlined, companyEmployeeResult?.count ?? 0, Colors.purpleAccent),
                    _dashboardCard('Završeni poslovi', Icons.work_outline,
                        jobResult?.result.where((e) => e.jobStatus == JobStatus.finished).length ?? 0, Colors.indigo),
                    _dashboardCard('Poslovi u toku', Icons.work_history_outlined,
                        jobResult?.result.where((e) => e.jobStatus == JobStatus.approved).length ?? 0, Colors.deepOrange),
                    _dashboardCard('Otkazani poslovi', Icons.work_off_outlined,
                        jobResult?.result.where((e) => e.jobStatus == JobStatus.cancelled).length ?? 0, Colors.redAccent),
                  ],
                );
              }),

              const SizedBox(height: 30),
              _buildJobsChart(),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _generatePdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4C7D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  ),
                  child: const Text('Generiši izvještaj', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard(String title, IconData icon, int value, Color color) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            
            children: [
              CircleAvatar(backgroundColor: color, radius: 30, child: Icon(icon, color: Colors.white, size: 30)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value.format(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobsChart() {
    if (jobResult == null || jobResult!.result.isEmpty) {
      return const Center(child: Text('Trenutno nema podataka za prikazati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)));
    }

    List<Job> jobsList = jobResult!.result.where((e) => e.jobStatus != JobStatus.cancelled).toList();
    List<int> jobsPerMonth = List.filled(12, 0);
    for (var job in jobsList) {
      jobsPerMonth[job.jobDate.month - 1]++;
    }

    List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    List<FlSpot> spots = List.generate(12, (i) => FlSpot(i.toDouble(), jobsPerMonth[i].toDouble()));
    double maxY = ((jobsPerMonth.reduce((a, b) => a > b ? a : b) ~/ 5) + 1) * 5.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: const Color(0xFF1B4C7D),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Broj poslova po mjesecima', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 2.5,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(0.3)),
                      dotData: const FlDotData(show: true),
                    )
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 5, getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: const TextStyle(color: Colors.white))),
                      axisNameWidget: const Text('Broj poslova', style: TextStyle(color: Colors.white, fontSize: 14)),
                      axisNameSize: 30,
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, meta) => Text(months[v.toInt()], style: const TextStyle(color: Colors.white))),
                      axisNameWidget: const Text('Mjesec', style: TextStyle(color: Colors.white, fontSize: 14)),
                      axisNameSize: 30,
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
