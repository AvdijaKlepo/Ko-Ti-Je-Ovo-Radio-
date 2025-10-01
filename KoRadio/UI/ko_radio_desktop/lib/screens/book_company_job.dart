
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';

import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';

import 'package:ko_radio_desktop/screens/add_employee_task.dart';
import 'package:ko_radio_desktop/screens/edit_accept_job.dart';
import 'package:ko_radio_desktop/screens/edit_job.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
  DateTime? _dateFinishedValue;
  DateTime? _dateEndValue;
  DateTime? jobDate;


  Map<String, dynamic> _initialForm = {};


  File? _image;
  String? _base64Image;
  var daysInRange;
  List<int> selectedIds=[];


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
      _companyJobAssignmentProvider.get(
  filter: _dateFinishedValue == null
      ? {
          'JobDate': widget.job.jobDate,
          'IsFinished': false,
          'IsCancelled': false,
        }
      : {
          'JobDate': widget.job.jobDate,
          'DateRange': _dateFinishedValue!.toIso8601String(),
          'IsFinished': false,
          'IsCancelled': false,
        },
),
        
      ]);
      print(_jobResult?.result.first.jobDate);

      if (!mounted) return;

      _jobResult = futures[0] as SearchResult<Job>?;
      _companyEmployeeResult = futures[1] as SearchResult<CompanyEmployee>?;
      _companyJobAssignmentResult = futures[2] as SearchResult<CompanyJobAssignment>?;
      _companyJobCheck = futures[3] as SearchResult<CompanyJobAssignment>?;
      final dateCheckFuture;

      _prepareInitialForm();
      if(widget.job.jobDate!=_jobResult?.result.first.jobDate)
      {
         dateCheckFuture = await Future.wait([
        _companyJobAssignmentProvider.get(
  filter: _dateFinishedValue == null
      ? {
          'JobDate': _jobResult?.result.first.jobDate,
          'IsFinished': false,
          'IsCancelled': false,
        }
      : {
          'JobDate': _jobResult?.result.first.jobDate,
          'DateRange': _dateFinishedValue!.toIso8601String(),
          'IsFinished': false,
          'IsCancelled': false,
        },
)]);
 _companyJobCheck = dateCheckFuture[0] as SearchResult<CompanyJobAssignment>?;
 _prepareInitialForm();
      }

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
final currentValues = _formKey.currentState?.value ?? {};
    _initialForm = {
      ...currentValues,
      'companyEmployeeId': assignedIds,

    };
  }


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
  
      _employeeFormKey.currentState?.invalidateField(name: 'companyEmployeeId',errorText: 'Odabrani radnik je zauzet u ovom terminu.');
      
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zaposlenici uspješno uređeni.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška pri dodavanju zaposlenika: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }
 bool checkIfValid(int companyEmployeeId) {
 if (widget.job.startEstimate == null || _dateEndValue == null) {
    return false;
  }
  final parts = _jobResult?.result.first.startEstimate!.split(":");
  final parsedTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    int.parse(parts![0]),
    int.parse(parts[1]),
  );

  DateTime normalizeTime(DateTime t) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, t.hour, t.minute, t.second);
  }
 

  final newStart = normalizeTime(parsedTime);
  final newEnd = widget.job.dateFinished== null ? normalizeTime(_dateEndValue!) : normalizeTime(widget.job.dateFinished!);

  final selectedEmployeeJobs = _companyJobCheck?.result
          .where((e) => e.companyEmployeeId == companyEmployeeId && e.jobId!=widget.job.jobId)
          .toList() ??
      [];

  for (var jobCheck in selectedEmployeeJobs) {
    if (jobCheck.job?.startEstimate == null ||
        jobCheck.job?.endEstimate == null) {
      continue;
    }

    final bookedStart = parseTime(jobCheck.job!.startEstimate!);
    final bookedEnd = parseTime(jobCheck.job!.endEstimate!);

    if (newStart.isBefore(bookedEnd) && newEnd.isAfter(bookedStart)) {
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
  
      _formKey.currentState?.invalidateField(name: 'companyEmployeeId',errorText: 'Odabrani radnik je zauzet u ovom terminu.');
      
      return; 
    }
  }
  }
                        
                                              
    
 
      
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
        'pin': values.containsKey('pin') ? values['pin'] :null,
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

  
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posao uspješno ažuriran.')));
      await _loadData();
    }
    on UserException catch (e) {
      if (!mounted) return;
      _formKey.currentState?.invalidateField(name: 'pin',errorText: e.exMessage);
      return;
    }

    
    catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Greška pri slanju. Molimo pokušajte ponovo.')));
    } finally {
      if (!mounted) return;
        
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

      await _loadData();
    
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
  Widget _buildImageRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,
       
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
            ),
          ),
          Expanded(flex:3,child: value),
        ],
      ),
    );
  }
    _openImageDialog() {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
  surfaceTintColor: Colors.white,
  insetPadding: const EdgeInsets.all(24),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),

       
        width: double.infinity,
        child: const Text('Proslijeđena slika',style: TextStyle(color: Colors.white),)),
      content: imageFromString(_jobResult?.result.first.image??''),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),))
      ],
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
        title: Text('Posao: ${job.jobTitle ?? ''}',style: TextStyle(color:const Color.fromRGBO(27, 76, 125, 1),letterSpacing: 1.2,fontFamily: GoogleFonts.lobster().fontFamily,fontSize: 30),),
        centerTitle: true,
        scrolledUnderElevation: 0,
       
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 1100;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                   
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                 
                      Flexible(
                    
                        flex: 3,
                        child: Column(
                          children: [
                             Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Detalji posla',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            Card(
                              color: Colors.white,
                              surfaceTintColor: Colors.white,
                            
                             
                                             
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
                                    job.image!=null ?
                        _buildImageRow(
                                  'Slika',
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(context: context, builder: (context) => _openImageDialog());
                                    
                                    
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child:  const Text(
                                      'Otvori sliku',
                                      style: TextStyle(
                                          color:
                                              Colors.white),
                                    ),
                                  ))
                              : _detailRow('Slika','Nije unesena'),
                            
                                    const Divider(height: 24),
                            
                                    if (job.jobStatus == JobStatus.approved || job.jobStatus == JobStatus.finished)
                                      _sectionTitle('Preuzeli dužnost', color: Colors.black),
                                      _detailRow('Radnici','${assignedNames.isNotEmpty ? assignedNames.join(', ') : 'Nisu uneseni'}'),
                                   
                            
                                 if (job.jobStatus == JobStatus.approved)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Radnici: ${assignedNames.isNotEmpty ? assignedNames.length : 'Nema zaposlenika'}',
        style: const TextStyle(color: Colors.white),
      ),
      const SizedBox(height: 8),
    
      ExpansionTile(
    
        collapsedIconColor: Colors.black,
        iconColor: Colors.black,
       
        title: Container(
           width: double.infinity,
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
  ),
          child: const Text(
            'Dodaj / Uredi radnike',
            style: TextStyle(color: Colors.white),
          ),
        ),
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
                  FormBuilderField<List<int>>(
                    name: 'companyEmployeeId',
                    validator: FormBuilderValidators.required(
                      errorText: 'Obavezno polje',
                    ),
                    builder: (field) {
                      selectedIds = field.value ?? [];
    
                
    
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Uredi radnike',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_add),
                            ),
                            items: availableEmployees.map((e) {
                              final isBusy =
                                  checkIfValid(e.companyEmployeeId);
                              return DropdownMenuItem<int>(
                                value: e.companyEmployeeId,
                               
                                child: Row(
                                  children: [
                                    isBusy
                                        ? const Icon(Icons.close,
                                            color: Colors.red)
                                        : const Icon(Icons.check,
                                            color: Colors.green),
                                    const SizedBox(width: 6),
                                    Text(
                                        '${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}'),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: 
                                (value) {
                                    if (value != null &&
                                        !selectedIds.contains(value)) {
                                      field.didChange(
                                          [...selectedIds, value]);
                                    }
                                  }
                                ,
                          ),
    
                          const SizedBox(height: 8),
    
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedIds.map((id) {
                              final employee = availableEmployees
                                  .firstWhere(
                                    (e) => e.companyEmployeeId == id,
                                    orElse: () => availableEmployees.first,
                                  );
    
                              return Chip(
                                label: Text(
                                    '${employee.user?.firstName ?? ''} ${employee.user?.lastName ?? ''}'),
                                avatar: checkIfValid(id)
                                    ? const Icon(Icons.close,
                                        color: Colors.red, size: 16)
                                    : const Icon(Icons.check,
                                        color: Colors.green, size: 16),
                                deleteIcon: const Icon(Icons.clear),
                                onDeleted: () {
                                  field.didChange(selectedIds
                                      .where((x) => x != id)
                                      .toList());
                                },
                              );
                            }).toList(),
                          ),
    
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                field.errorText ?? '',
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
    
                  const SizedBox(height: 8),
    
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _assignSelectedEmployees,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
                       
                              
                        ),
                        child: const Text('Uredi radnike', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                     
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  ),

                            
                                    
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
                            
                                
                                  
                                  ],
                                ),
                              ),
                            ),
                            if(job.jobStatus!=JobStatus.finished && job.jobStatus!=JobStatus.cancelled)
                              Container(
                                decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                                child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Potrebni podaci',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FormBuilder(
                                              key: _formKey,
                                              initialValue: _initialForm,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (job.jobStatus == JobStatus.unapproved) ...[
                                                  
                                                   Row(
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children: [
                                               
                                                     if(job.jobStatus==JobStatus.unapproved)
                                                  Row(
                                                    children: [
                                                      const Text('Posao traje više dana?',style: TextStyle(fontWeight: FontWeight.bold),),
                                                      Checkbox(value: multiDateJob,onChanged: (value){
                                                        setState(() {
                                                          multiDateJob=value!;
                                                        });
                                                      },),
                                                    ],
                                                  ),
                                                   
                                               ],
                                             ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                         if(multiDateJob==true && widget.job.jobStatus==JobStatus.unapproved)
                                                    Expanded(
                                                      flex: 1,
                                                      child: FormBuilderDateTimePicker(
                                                        key: const ValueKey('dateFinished'),
                                                        name: 'dateFinished',
                                                        initialValue: _dateFinishedValue,
                                                        inputType: InputType.date,
                                                        locale: const Locale('bs'),
                                                        decoration: const InputDecoration(labelText: 'Datum završetka', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                                                        firstDate: job.jobDate,
                                                        initialDate: job.jobDate.isAfter(DateTime.now()) ? job.jobDate : DateTime.now(),
                                                        validator: FormBuilderValidators.compose([
                                                          FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                                          
                                                        ]),
                                                        selectableDayPredicate: _isWorkingDay,
                                                        onChanged: (value) async {
                                                      
                                                         _dateFinishedValue = value;
                                                         _dateFinishedValue!.toIso8601String();
                                                         
                                                        
                                                          
                                                          await _loadData();
                                                          print(_companyJobCheck?.count);
                                                        },
                                                      ),
                                                    ),
                                                    if(multiDateJob==true)
                                                   const SizedBox(width: 12,),
                                                 
                                                    Expanded(
                                                      key: const ValueKey('endEstimate'),
                                                      child: FormBuilderDateTimePicker(name: 'endEstimate',
                                                      initialValue: _dateEndValue,
                                                      locale: const Locale('bs'),
                                                        inputType: InputType.time,
                                                        decoration: const InputDecoration(labelText: 'Vrijeme završetka', border: OutlineInputBorder(), prefixIcon: Icon(Icons.schedule_outlined),
                                                        ),
                                                        validator: FormBuilderValidators.compose([
                                                          FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                                          (value) {
                                                                                                if (value == null) return null;
                                                                    
                                                                                                final startOfShift = widget.job.company!.startTime; 
                                                                                                final endOfShift = widget.job.company!.endTime;   
                                                                    
                                                                                                final formatter = DateFormat('HH:mm:ss');
                                                                    
                                                                                                final baseDate = DateTime(value.year, value.month, value.day);
                                                                    
                                                                                                final start = baseDate.add(formatter.parse(startOfShift)
                                                                                                    .difference(DateTime(1970))); 
                                                                                                final end = baseDate.add(formatter.parse(endOfShift)
                                                                                                    .difference(DateTime(1970)));
                                                                    
                                                                                                if (value.isBefore(start)) {
                                                                                                  return 'Smijena počinje u ${startOfShift.substring(0, 5)}';
                                                                                                }
                                                                                                if (value.isAfter(end)) {
                                                                                                  return 'Smijena završava u ${endOfShift.substring(0, 5)}';
                                                                                                }
                                                                    
                                                                                                return null;
                                                                                              },
                                                        
                                                                    
                                                          
                                                          
                                                        ]),
                                                        onChanged: (value) async {
                                                        
                                                         setState(() {
                                                           _dateEndValue = value;
                                                         });
                                                       
                                                       
                                                        },
                                                      ),
                                                    ),
                        
                                                      ],
                                                    ),
                                                   
                                                                  
                                                                  
                                                    const SizedBox(height: 12),
                                                   Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pay estimate input
                            Expanded(
                              flex: 1,
                              child: FormBuilderTextField(
                                name: 'payEstimate',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Procijena finalne cijene',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                  FormBuilderValidators.numeric(errorText: 'Numerička vrijednost.'),
                                ]),
                                valueTransformer: (value) => double.tryParse(value ?? ''),
                              ),
                            ),
                            const SizedBox(width: 12),
                        
                          
                          ValueListenableBuilder<DateTime?>(
  valueListenable: ValueNotifier(_dateEndValue),
  builder: (context, endValue, _) {
    final canSelectEmployees = 
        (_dateEndValue != null && endValue != null) || 
        (endValue != null && _dateEndValue == null);

    return Expanded(
      child: FormBuilderField<List<int>>(
        name: 'companyEmployeeId',
        enabled: canSelectEmployees,
        validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
        builder: (field) {
          selectedIds = field.value ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(
                message: canSelectEmployees
                    ? 'Odaberite radnika'
                    : 'Prvo unesite datum početka i završetka (ili samo početni datum za jednodnevni posao).',
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Dodaj radnika',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_add),
                    // Subtle helper text when disabled
                    helperText: canSelectEmployees
                        ? null
                        : 'Onemogućeno dok ne unesete datume',
                  ),
                  items: availableEmployees.map((e) {
                    final isBusy = checkIfValid(e.companyEmployeeId);
                    return DropdownMenuItem<int>(
                      value: e.companyEmployeeId,
                      child: Row(
                        children: [
                          isBusy
                              ? const Icon(Icons.close, color: Colors.red)
                              : const Icon(Icons.check, color: Colors.green),
                          const SizedBox(width: 6),
                          Text('${e.user?.firstName ?? ''} ${e.user?.lastName ?? ''}'),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: canSelectEmployees
                      ? (value) {
                          if (value != null && !selectedIds.contains(value)) {
                            field.didChange([...selectedIds, value]);
                          }
                        }
                      : null,
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedIds.map((id) {
                  final employee = availableEmployees.firstWhere(
                    (e) => e.companyEmployeeId == id,
                    orElse: () => availableEmployees.first,
                  );

                  return Chip(
                    label: Text('${employee.user?.firstName ?? ''} ${employee.user?.lastName ?? ''}'),
                    avatar: checkIfValid(id)
                        ? const Icon(Icons.close, color: Colors.red, size: 16)
                        : const Icon(Icons.check, color: Colors.green, size: 16),
                    deleteIcon: const Icon(Icons.clear),
                    onDeleted: () {
                      field.didChange(selectedIds.where((x) => x != id).toList());
                    },
                  );
                }).toList(),
              ),

              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    field.errorText ?? '',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  },
)

                          ],
                        ),
                        
                                                   
                                                                  
                                                                  
                                                  ],
                                                                  
                                                  if (job.jobStatus == JobStatus.approved) ...[
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                         Expanded(
                                                          flex: 1,
                                                           child: FormBuilderTextField(
                                                                                                                 name: 'pin',
                                                                                                                 enabled: _jobResult?.result.first.isEdited==true ||  _jobResult?.result.first.isWorkerEdited==true  ? false : true,
                                                                                                                 keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                                                                                                 decoration: const InputDecoration(labelText: 'PIN', border: OutlineInputBorder(), prefixIcon: Icon(Icons.pin),
                                                                                                              ),
                                                                                                                 validator: FormBuilderValidators.compose([
                                                                                                                   FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                                                                                                  
                                                                                                                 ]),
                                                                                                                
                                                                                                               ),
                                                         ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      flex: 1,
                                                      child: FormBuilderTextField(
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
                                                    ),
                                                      ],
                                                    ),
                                                   
                                                    
                                                      
                                                
                                                  ],
                                                ],
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            
                                    const SizedBox(height: 16),
                            
                                    // Actions
                                    if (job.jobStatus != JobStatus.cancelled && job.jobStatus != JobStatus.finished)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.cancel, color: Colors.red),
                                            label: const Text('Otkaži', style: TextStyle(color: Colors.red)),
                                            onPressed: _cancelJob,
                                          ),
                                          const SizedBox(width: 12),
                                            ElevatedButton.icon(
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

                   
                      const SizedBox(width: 16, height: 16),
                      const VerticalDivider(thickness: 1),
                      if (isWide)
                      
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                            if (_jobResult?.result.isNotEmpty == true &&
    _jobResult!.result.first.jobStatus == JobStatus.unapproved)
  SizedBox(
    height: MediaQuery.of(context).size.height * 0.75,
    child: Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child:  Text(
            _dateFinishedValue==null ?
            'Raspored radnika za ${DateFormat('dd.MM.yyyy').format(_jobResult!.result.first.jobDate)}'
            : 'Raspored radnika od ${DateFormat('dd.MM.yyyy').format(_jobResult!.result.first.jobDate)} do ${DateFormat('dd.MM.yyyy').format(_dateFinishedValue!)}',
            style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          ),
      ),
          
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: availableEmployees.length,
              itemBuilder: (context, index) {
                final employee = availableEmployees[index];

      
                final companyJobs = _companyJobCheck?.result
                        .where((e) =>
                            e.companyEmployeeId == employee.companyEmployeeId)
                        .toList() ??
                    [];

                return Card(
                  elevation: 2,
                  surfaceTintColor: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${employee.user?.firstName ?? ''} ${employee.user?.lastName ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                 
                        if (companyJobs.isEmpty)
                          Text(
                            'Slobodan',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: companyJobs.map((job) {
                              final start = job.job?.startEstimate ?? 'Nema';
                              final end = job.job?.endEstimate ?? 'Nema';
                              DateTime date = job.job!.jobDate;
                              DateTime? dateFinished = job.job!.dateFinished;
                              String title = job.job!.jobTitle!;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: job.job?.dateFinished==null ? Text('Posao: $title\n${DateFormat('dd.MM.yyyy').format(date)}\nOd: ${start.substring(0,5)}   Do: ${end.substring(0,5)}'):
                                 Text('Posao: $title\n${DateFormat('dd.MM.yyyy').format(date)} do ${DateFormat('dd.MM.yyyy').format(dateFinished!)}\nOd: ${start.substring(0,5)}   Do: ${end.substring(0,5)}'),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),


                             
                              if (_jobResult?.result.first.jobStatus==JobStatus.approved)
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AddEmployeeTask(job: widget.job),
                                  ),
                                ),
                              const SizedBox(height: 12),
                        
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
