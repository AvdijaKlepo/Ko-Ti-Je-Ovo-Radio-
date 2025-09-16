
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';

import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';

import 'package:ko_radio_desktop/screens/add_employee_task.dart';
import 'package:ko_radio_desktop/screens/edit_accept_job.dart';
import 'package:ko_radio_desktop/screens/edit_job.dart';
import 'package:provider/provider.dart';

class BookCompanyJobPage extends StatefulWidget {
  const BookCompanyJobPage({required this.job, Key? key}) : super(key: key);

  final Job job;

  @override
  State<BookCompanyJobPage> createState() => _BookCompanyJobPageState();
}

class _BookCompanyJobPageState extends State<BookCompanyJobPage> with TickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _employeeFormKey = GlobalKey<FormBuilderState>();


  late CompanyProvider _companyProvider;
  late JobProvider _jobProvider;
  late CompanyEmployeeProvider _companyEmployeeProvider;
  late CompanyJobAssignmentProvider _companyJobAssignmentProvider;


  SearchResult<Job>? _jobResult;
  SearchResult<CompanyEmployee>? _companyEmployeeResult;
  SearchResult<CompanyJobAssignment>? _companyJobAssignmentResult;
  SearchResult<CompanyJobAssignment>? _companyJobCheck;


  bool _loading = true;
  bool _assignCheckboxTouched = false;
  bool _showEditPanel = false;
  bool _showTaskPanel = false;
  bool _expansionOpen = false;
  bool multiDateJob=false;


  Map<String, dynamic> _initialForm = {};


  File? _image;
  String? _base64Image;
  var daysInRange;


  late final Set<int> _workingDayInts;
  final Map<String, int> _dayStringToInt = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
    'Saturday': DateTime.saturday,
    'Sunday': DateTime.sunday,
  };

  @override
  void initState() {
    super.initState();
    _companyProvider = context.read<CompanyProvider>();
    _jobProvider = context.read<JobProvider>();
    _companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
    _companyJobAssignmentProvider = context.read<CompanyJobAssignmentProvider>();

    _workingDayInts = widget.job.company?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((d) => d != -1)
            .toSet() ??
        {};

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
 
      final futures = await Future.wait([
        _jobProvider.get(filter: {'JobId': widget.job.jobId}),
        _companyEmployeeProvider.get(filter: {'companyId': widget.job.company?.companyId}),
        _companyJobAssignmentProvider.get(filter: {'JobId': widget.job.jobId}),
        _companyJobAssignmentProvider.get(filter: {'DateRange':widget.job.jobDate,'IsFinished':false,'IsCancelled':false}),
        
      ]);

      if (!mounted) return;

      _jobResult = futures[0] as SearchResult<Job>?;
      _companyEmployeeResult = futures[1] as SearchResult<CompanyEmployee>?;
      _companyJobAssignmentResult = futures[2] as SearchResult<CompanyJobAssignment>?;
      _companyJobCheck = futures[3] as SearchResult<CompanyJobAssignment>?;
  

      _prepareInitialForm();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška pri dohvaćanju podataka: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _prepareInitialForm() {

    final assignedIds = _companyJobAssignmentResult?.result
            .map((a) => a.companyEmployee?.companyEmployeeId)
            .whereType<int>()
            .toSet()
            .toList() ??
        [];

    _initialForm = {
      'companyEmployeeId': assignedIds,

    };
  }

  // Helper: format phone
  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    String normalized = phone.replaceFirst(RegExp(r'^\+387'), '0');
    normalized = normalized.replaceAll(RegExp(r'\D'), '');
    if (normalized.length < 9) return normalized;
    String part1 = normalized.substring(0, 3);
    String part2 = normalized.substring(3, 6);
    String part3 = normalized.substring(6, 9);
    return '$part1-$part2-$part3';
  }

  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  Future<void> _openImagePreview(String base64) async {
    if (base64.isEmpty) return;
    final bytes = base64Decode(base64);
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
        title: const Text('Proslijeđena slika', style: TextStyle(color: Colors.white)),
        content: Image.memory(bytes, fit: BoxFit.contain),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Nazad'),
          )
        ],
      ),
    );
  }

  Future<void> _assignSelectedEmployees() async {
    final isValid = _employeeFormKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;

    final form = Map<String, dynamic>.from(_employeeFormKey.currentState?.value ?? {});
    final selectedEmployees = form['companyEmployeeId'] as List<int>; 


  final parts = widget.job.startEstimate!.split(":");
  final parsedTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );

  DateTime normalizeTime(DateTime t) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, t.hour, t.minute, t.second);
  }
  var jobEnd = parseTime(widget.job.endEstimate!);

  DateTime selectedEnd = normalizeTime(jobEnd);
  DateTime newStart = normalizeTime(parsedTime);
  DateTime newEnd = selectedEnd;


  final selectedEmployeeJobs = _companyJobCheck?.result
      .where((e) => selectedEmployees.contains(e.companyEmployeeId) && e.jobId!=widget.job.jobId)
      .toList() ?? [];

  for (var jobCheck in selectedEmployeeJobs) {
    if (jobCheck.job?.startEstimate == null || jobCheck.job?.endEstimate == null) {
      continue;
    }

    final bookedStart = parseTime(jobCheck.job!.startEstimate!);
    final bookedEnd = parseTime(jobCheck.job!.endEstimate!);

    bool overlaps = newStart.isBefore(bookedEnd) && newEnd.isAfter(bookedStart);
    debugPrint(
      'Checking empId=${jobCheck.companyEmployeeId} '
      'booked=($bookedStart - $bookedEnd) new=($newStart - $newEnd) '
      '=> overlaps=$overlaps',
    );

    if (overlaps) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Odabrani radnik je već zauzet u ovom terminu.'),
        ),
      );
      return; 
    }
  }

    if (selectedEmployees!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Niste odabrali radnike.')));
      return;
    }

    setState(() => _loading = true);

    try {
      for (final id in selectedEmployees!) {
        await _companyJobAssignmentProvider.insert({
          'jobId': widget.job.jobId,
          'companyEmployeeId': id,
          'assignedAt': DateTime.now().toIso8601String(),
          'isFinished': false,
        });
      }
      await _loadData(); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zaposlenici uspješno dodani.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška pri dodavanju zaposlenika: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }
 bool checkIfValid(int companyEmployeeId) {
  final values = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});

if (widget.job.startEstimate == null || values['endEstimate'] == null) {
    return false;
  }

    final parts = widget.job.startEstimate?.split(":");
    final parsedTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      int.parse(parts?[0] ?? '0'),
      int.parse(parts?[1] ?? '0'),
    );

    DateTime normalizeTime(DateTime t) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, t.hour, t.minute, t.second);
    }

    DateTime selectedEnd = normalizeTime(values['endEstimate']);
    DateTime newStart = normalizeTime(parsedTime);
    DateTime newEnd = selectedEnd;

    final selectedEmployeeJobs = _companyJobCheck?.result
          .where((e) => e.companyEmployeeId == companyEmployeeId)
            .toList() ??
        [];

    for (var jobCheck in selectedEmployeeJobs) {
      if (jobCheck.job?.startEstimate == null ||
          jobCheck.job?.endEstimate == null) {
        continue;
      }

      final bookedStart = parseTime(jobCheck.job?.startEstimate??'');
      final bookedEnd = parseTime(jobCheck.job?.endEstimate??'');

      bool overlaps =
          newStart.isBefore(bookedEnd) && newEnd.isAfter(bookedStart);

      debugPrint(
        'Checking empId=${jobCheck.companyEmployeeId} '
        'booked=($bookedStart - $bookedEnd) new=($newStart - $newEnd) '
        '=> overlaps=$overlaps',
      );

      if (overlaps) {
        return true; 
      }
    }
    return false; 
  }






  

  Future<void> _submitForm(JobStatus resultingStatus) async {
  final isValid = _formKey.currentState?.saveAndValidate() ?? false;
  if (!isValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Molimo popunite obavezna polja.')),
    );
    return;
  }

  final values = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});
    final selectedEmployees;
    selectedEmployees = _jobResult?.result.first.jobStatus==JobStatus.unapproved ?  values['companyEmployeeId'] as List<int> : null; 

  if(selectedEmployees!=null && selectedEmployees.isNotEmpty){
  final parts = widget.job.startEstimate!.split(":");
  final parsedTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );

  DateTime normalizeTime(DateTime t) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, t.hour, t.minute, t.second);
  }

  DateTime selectedEnd = normalizeTime(values['endEstimate']);
  DateTime newStart = normalizeTime(parsedTime);
  DateTime newEnd = selectedEnd;


  final selectedEmployeeJobs = _companyJobCheck?.result
      .where((e) => selectedEmployees.contains(e.companyEmployeeId))
      .toList() ?? [];

  for (var jobCheck in selectedEmployeeJobs) {
    if (jobCheck.job?.startEstimate == null || jobCheck.job?.endEstimate == null) {
      continue;
    }

    final bookedStart = parseTime(jobCheck.job!.startEstimate!);
    final bookedEnd = parseTime(jobCheck.job!.endEstimate!);

    bool overlaps = newStart.isBefore(bookedEnd) && newEnd.isAfter(bookedStart);
    debugPrint(
      'Checking empId=${jobCheck.companyEmployeeId} '
      'booked=($bookedStart - $bookedEnd) new=($newStart - $newEnd) '
      '=> overlaps=$overlaps',
    );

    if (overlaps) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Odabrani radnik je već zauzet u ovom terminu.'),
        ),
      );
      return; 
    }
  }
  }
                        
                                              
    setState(() => _loading = true);
 
      
    try{
   
      if (values['dateFinished'] is DateTime) {
        values['dateFinished'] = (values['dateFinished'] as DateTime).toIso8601String();
      }
        if (values["endEstimate"] is DateTime) {
            final dateTime = values["endEstimate"] as DateTime;
            final formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
            values["endEstimate"] = formattedTime;
          }

          print(widget.job.jobsServices?.map((e) => e.service?.serviceId ?? 0).toList());

      final jobUpdateRequest = {
        'userId': widget.job.user?.userId,
        'freelancerId': null,
        'companyId': widget.job.company?.companyId,
        'jobTitle': widget.job.jobTitle,
        'isTenderFinalized': false,
        'isFreelancer': false,
        'isInvoiced': false,
        'isRated': false,
        'startEstimate': widget.job.startEstimate,
        'endEstimate': values["endEstimate"],
        'payEstimate': values.containsKey('payEstimate') ? values['payEstimate'] : widget.job.payEstimate,
        'payInvoice': values.containsKey('payInvoice') ? values['payInvoice'] : widget.job.payInvoice,
        'jobDate': widget.job.jobDate.toIso8601String(),
        'dateFinished':values.containsKey('dateFinished') ? values['dateFinished'] : widget.job.dateFinished?.toIso8601String(),
        'jobDescription': widget.job.jobDescription,
        'image': widget.job.image,
        'jobStatus': _jobResult?.result.first.jobStatus==JobStatus.unapproved ? JobStatus.approved.name : JobStatus.finished.name,
        'serviceId': widget.job.jobsServices?.map((e) => e.service?.serviceId).toList() ?? [],

      };


      await _jobProvider.update(widget.job.jobId, jobUpdateRequest);
      

      final selectedEmployeeIds = values['companyEmployeeId'] as List<dynamic>?;
      if (selectedEmployeeIds != null && selectedEmployeeIds.isNotEmpty) {
        for (final employeeId in selectedEmployeeIds) {
          await _companyJobAssignmentProvider.insert({
            'jobId': widget.job.jobId,
            'companyEmployeeId': employeeId,
            'assignedAt': DateTime.now().toIso8601String(),
          });
        }
      }
      

      if (jobUpdateRequest['jobStatus']==JobStatus.finished.name) {
        final assignments = _companyJobAssignmentResult?.result ?? [];
        for (final a in assignments) {
          if (a.companyJobId != null) {
            await _companyJobAssignmentProvider.update(a.companyJobId!, {'isFinished': true});
          }
        }
      }

      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jobUpdateRequest['jobStatus']==JobStatus.unapproved ? 'Posao prihvaćen.' : 'Posao označen kao završen.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška pri slanju. Molimo pokušajte ponovo.')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }
  Future<void> _editJob() async {
    final job = await showDialog<Job>(
      context: context,
      builder: (c) => EditJob(job: widget.job),
    );
    if (job != null) {
      await _loadData();
    }
  }
   Future<void> _editApproveJob() async {
    final job = await showDialog<Job>(
      context: context,
      builder: (c) => EditAcceptJob(job: widget.job),
    );
    if (job != null) {
      await _loadData();
    }
  }


  Future<void> _cancelJob() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Odbaci posao'),
        content: const Text('Jeste li sigurni da želite otkazati ovaj posao?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Ne')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Da')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      final jobUpdateRequest = {
    
        'jobStatus': JobStatus.cancelled.name
      };

      await _jobProvider.update(widget.job.jobId, jobUpdateRequest);
       final assignments = _companyJobAssignmentResult?.result ?? [];
        for (final a in assignments) {
          if (a.companyJobId != null) {
            await _companyJobAssignmentProvider.update(a.companyJobId!, {'isCancelled': true});
          }
        }
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posao otkazan.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // Build helpers
  Widget _sectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color ?? Colors.black)),
    );
  }

  Widget _detailRow(String label, String value, {bool whiteText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold, color: whiteText ? Colors.white : Colors.black))),
          Expanded(flex: 3, child: Text(value, style: TextStyle(color: whiteText ? Colors.white : Colors.black87))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignedNames = _companyJobAssignmentResult?.result
            .map((a) => '${a.companyEmployee?.user?.firstName ?? ''} ${a.companyEmployee?.user?.lastName ?? ''}')
            .where((s) => s.trim().isNotEmpty)
            .toList() ??
        [];

    final availableEmployees = _companyEmployeeResult?.result?.where((e) => e.userId != AuthProvider.user?.userId).toList() ?? [];

    final job = _jobResult?.result.first ?? widget.job;
final dateFormat = DateFormat('dd.MM.yyyy');
 if (job.dateFinished != null) {
    daysInRange = getWorkingDaysInRange(
      jobDate: job.jobDate,
      dateFinished: job.dateFinished!,
      workingDays: job.freelancer?.freelancerId!=null ?
       job.freelancer?.workingDays ?? []:
       job.company?.workingDays ?? [],
    );
  }
  else{
    daysInRange=[];
  }
  
    

    return Scaffold(
      appBar: AppBar(
        title: Text('Posao: ${job.jobTitle ?? ''}'),
       
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 1100;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                 
                      Flexible(
                        flex: 3,
                        child: Card(
                          color: Colors.white,
                          shadowColor: Colors.transparent,
                 
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                       
                                if (job.isEdited == true || job.isWorkerEdited == true)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info),
                                        const SizedBox(width: 8),
                                        const Expanded(child: Text('Ovaj posao je ažuriran.')),
                                        if (job.isEdited == true)
                                          ElevatedButton(
                                            onPressed: () async {
                                              final messenger = ScaffoldMessenger.of(context);
                                              try {
                                                final payload = {
                                                  'userId': job.user?.userId,
                                                  'freelancerId': null,
                                                  'companyId': job.company?.companyId,
                                                  'jobTitle': job.jobTitle,
                                                  'isTenderFinalized': false,
                                                  'isFreelancer': false,
                                                  'isInvoiced': false,
                                                  'isRated': false,
                                                  'startEstimate': null,
                                                  'endEstimate': null,
                                                  'payEstimate': job.payEstimate,
                                                  'payInvoice': null,
                                                  'jobDate': job.jobDate.toIso8601String(),
                                                  'dateFinished': job.dateFinished?.toIso8601String(),
                                                  'jobDescription': job.jobDescription,
                                                  'image': job.image,
                                                  'jobStatus': job.jobStatus.name,
                                                  'serviceId': job.jobsServices?.map((e) => e.service?.serviceId).toList(),
                                                  'isEdited': false,
                                                };
                                 
                                                await _jobProvider.update(job.jobId, payload);
                                                await _loadData();
                                    
                                               
                                                messenger.showSnackBar(
  const SnackBar(content: Text('Posao označen kao pregledan.')),
);
                                                
                                                 
                                              } catch (e) {
                                               
                                                messenger.showSnackBar(
  const SnackBar(content: Text('Greška. Pokušajte ponovo.')),
);
                                                
                                              } 
                                              
                                            
                                          
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                                            child: const Text('Označi kao pregledano'),
                                          )
                                      ],
                                    ),
                                  ),

                                _sectionTitle('Radne specifikacije', color: Colors.black),
                                _detailRow('Posao', job.jobTitle ?? 'Nije dostupan'),
                                _detailRow('Servis', job.jobsServices?.map((e) => e.service?.serviceName).whereType<String>().join(', ') ?? 'N/A'),
                                 _detailRow('Datum početka radova', dateFormat.format(job.jobDate)),
                  if(job.dateFinished!=null)
                  _detailRow('Datum završetka\nradova', dateFormat.format(job.dateFinished!)),
                  if(job.dateFinished!=null)
                 _detailRow('Radni dani',  daysInRange.join(', ')),

                  if(job.dateFinished==null)
                  _detailRow('Vrijeme početka', job.startEstimate.toString().substring(0,5)),
                  if(job.dateFinished==null)
                  _detailRow('Vrijeme završetka',
                 job.endEstimate!=null ?
                      job.endEstimate.toString().substring(0,5) : 'Nije uneseno'),
                      if(job.endEstimate!=null && job.dateFinished!=null)
                  _detailRow('Vremenski', 'Svakim navedenim danom od ${job.startEstimate.toString().substring(0,5)} do ${job.endEstimate.toString().substring(0,5)}'),
                                _detailRow('Opis posla', job.jobDescription),
                                _detailRow('Servis', job.jobsServices?.map((e) => e.service?.serviceName).whereType<String>().join(', ') ?? 'N/A'),

                                if (job.image != null) const SizedBox(height: 8),
                                if (job.image != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: ElevatedButton(
                                      onPressed: () => _openImagePreview(job.image!),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color.fromRGBO(27, 76, 125, 25)),
                                      child: const Text('Otvori sliku'),
                                    ),
                                  ),

                                const Divider(height: 24),

                                if (job.jobStatus == JobStatus.approved || job.jobStatus == JobStatus.finished)
                                  _sectionTitle('Preuzeli dužnost', color: Colors.black),
                                  _detailRow('Radnici','${assignedNames.isNotEmpty ? assignedNames.join(', ') : 'Nema zaposlenika'}'),
                                  Divider(height: 24),

                                // Assignments view and selection
                                if (job.jobStatus == JobStatus.approved)
                                  Card(
                                    color: Colors.grey.shade100,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Radnici: ${assignedNames.isNotEmpty ? assignedNames.join(', ') : 'Nema zaposlenika'}'),
                                          const SizedBox(height: 8),
                                          ExpansionTile(
                                            title: const Text('Dodaj / Uredi radnike'),
                                            initiallyExpanded: false,
                                            onExpansionChanged: (open) => setState(() => _expansionOpen = open),
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: FormBuilder(
                                                  key: _employeeFormKey,
                                                  initialValue: _initialForm,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      FormBuilderCheckboxGroup<int>(
                                                        name: 'companyEmployeeId',
                                                        decoration: const InputDecoration(border: InputBorder.none),
                                                        validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                                        options: availableEmployees.map((e) {
                                                          final name = '${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}';
                                                          return FormBuilderFieldOption(value: e.companyEmployeeId!, child: Text(name));
                                                        }).toList(),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: _assignSelectedEmployees,
                                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color.fromRGBO(27, 76, 125, 25)),
                                                            child: const Text('Uredi radnike'),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          ElevatedButton(
                                                            onPressed: () => setState(() => _showTaskPanel = !_showTaskPanel),
                                                            child: const Text('Dodaj zadatak'),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 12),
                                if(_jobResult?.result.first.jobStatus==JobStatus.approved)
                                const Divider(height: 24),

                                _sectionTitle('Korisnički podaci', color: Colors.black),
                                _detailRow('Ime i prezime', job.user != null ? '${job.user?.firstName ?? ''} ${job.user?.lastName ?? ''}' : 'Nepoznato'),
                                _detailRow('Broj telefona', _formatPhoneNumber(job.user?.phoneNumber ?? 'Nepoznato')),
                                _detailRow('Lokacija', job.user?.location?.locationName ?? 'Nepoznato'),
                                _detailRow('Adresa', job.user?.address ?? 'Nepoznato'),

                                const Divider(height: 24,),
                                _sectionTitle('Podaci Firme', color: Colors.black),
                                _detailRow('Naziv Firme', job.company?.companyName ?? 'Nepoznato'),
                                _detailRow('E-mail', job.company?.email ?? 'Nepoznato'),
                                _detailRow('Telefonski broj', _formatPhoneNumber(job.company?.phoneNumber ?? 'Nepoznato')),

                                const Divider(height: 24,),
                                
                                _sectionTitle('Račun', color: Colors.black),
                                _detailRow('Procijena', (job.payEstimate != null) ? job.payEstimate!.toStringAsFixed(2) : 'Nije unesena'),
                                _detailRow('Konačna cijena', (job.payInvoice != null) ? job.payInvoice!.toStringAsFixed(2) : 'Nije unesena'),
                                if(job.payInvoice!=null)
                                _detailRow('Plaćen', job.isInvoiced == true ? 'Da' : 'Ne'),
                                if (job.jobStatus == JobStatus.cancelled) _detailRow('Otkazan', 'Da'),

                                const SizedBox(height: 12),

                            
                                FormBuilder(
                                  key: _formKey,
                                  initialValue: _initialForm,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (job.jobStatus == JobStatus.unapproved) ...[
                                        const Divider(),
                                       Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Padding(
                   padding: const EdgeInsets.all(  12),
                   child: Text(
                     'Potrebni podaci',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black), 
                   ),
                 ),
                 if(job.jobStatus==JobStatus.unapproved)
              Checkbox(value: multiDateJob,onChanged: (value){
                setState(() {
                  multiDateJob=value!;
                });
              },),
               
           ],
         ),
                                        const SizedBox(height: 8),
                                        if(multiDateJob==true && widget.job.jobStatus==JobStatus.unapproved)
                                        FormBuilderDateTimePicker(
                                          name: 'dateFinished',
                                          inputType: InputType.date,
                                          decoration: const InputDecoration(labelText: 'Kraj radova', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                                          firstDate: job.jobDate,
                                          initialDate: job.jobDate.isAfter(DateTime.now()) ? job.jobDate : DateTime.now(),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                            
                                          ]),
                                          selectableDayPredicate: _isWorkingDay,
                                        ),
                                        const SizedBox(height: 12),
                                        FormBuilderDateTimePicker(name: 'endEstimate',
                                          inputType: InputType.time,
                                          decoration: const InputDecoration(labelText: 'Kraj', border: OutlineInputBorder(), prefixIcon: Icon(Icons.schedule_outlined),
                                          ),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                            
                                           

                                            
                                            
                                          ]),
                                        ),


                                        const SizedBox(height: 12),
                                        FormBuilderTextField(
                                          name: 'payEstimate',
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(labelText: 'Moguća Cijena', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                            FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                                          ]),
                                          valueTransformer: (value) => double.tryParse(value ?? ''),
                                        ),
                                        const SizedBox(height: 12),
                                       FormBuilderCheckboxGroup<int>(
  name: 'companyEmployeeId',
  decoration: const InputDecoration(labelText: 'Zaduženi radnici'),
  options: availableEmployees.map((e) {
    final name = '${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}';
    final isBusy = checkIfValid(e.companyEmployeeId);

    return FormBuilderFieldOption(
      value: e.companyEmployeeId!,

      child: Row(
        children: [
          Icon(isBusy ? Icons.close : Icons.check_circle,
              color: isBusy ? Colors.red : Colors.green),
          const SizedBox(width: 8),
          Text(isBusy ? 'Zauzet' : 'Slobodan'),
          const SizedBox(width: 12),
          Text(name),
        ],
      ),
    );
  }).toList(),
  validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
)

                                      ],

                                      if (job.jobStatus == JobStatus.approved) ...[
                                        const Divider(),
                                        FormBuilderTextField(
                                          name: 'payInvoice',
                                          enabled: _jobResult?.result.first.isEdited==true ||  _jobResult?.result.first.isWorkerEdited==true  ? false : true,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(labelText: 'Finalna cijena', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money),
                                       ),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                            FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                                          ]),
                                          valueTransformer: (value) => double.tryParse(value ?? ''),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Actions
                                if (job.jobStatus != JobStatus.cancelled && job.jobStatus != JobStatus.finished)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        label: const Text('Otkaži', style: TextStyle(color: Colors.red)),
                                        onPressed: _cancelJob,
                                      ),
                                      const SizedBox(width: 12),
                                        TextButton.icon(
                                        icon: const Icon(Icons.edit, color: Colors.amber),
                                        label: const Text('Uredi', style: TextStyle(color: Colors.amber)),
                                        onPressed: _jobResult?.result.first.jobStatus==JobStatus.unapproved ? _editApproveJob : _editJob,
                                      ),
                                      const SizedBox(width: 12),

                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Odobri'),
                                        onPressed: () => _submitForm(JobStatus.approved),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Right side panels (Edit / Task)
                      const SizedBox(width: 16, height: 16),
                      if (isWide)
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              // Task panel
                              if (_jobResult?.result.first.jobStatus==JobStatus.approved)
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.75,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: AddEmployeeTask(job: widget.job),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              // Edit panel
                              if (_showEditPanel)
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: SizedBox(
                                    height: 600,
                                    child: EditJob(job: widget.job),
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
          
                        Column(
                          children: [
                            if (_showTaskPanel) ...[
                              const SizedBox(height: 16),
                              Card(
                                child: Padding(padding: const EdgeInsets.all(8.0), child: AddEmployeeTask(job: widget.job)),
                              ),
                            ],
                            if (_showEditPanel) ...[
                              const SizedBox(height: 16),
                              Card(child: Padding(padding: const EdgeInsets.all(8.0), child: EditJob(job: widget.job))),
                            ]
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
