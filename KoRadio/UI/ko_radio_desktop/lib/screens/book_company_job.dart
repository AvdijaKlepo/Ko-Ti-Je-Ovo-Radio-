// book_company_job_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/add_employee_task.dart';
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

  // Providers
  late CompanyProvider _companyProvider;
  late JobProvider _jobProvider;
  late CompanyEmployeeProvider _companyEmployeeProvider;
  late CompanyJobAssignmentProvider _companyJobAssignmentProvider;

  // Results
  SearchResult<Job>? _jobResult;
  SearchResult<CompanyEmployee>? _companyEmployeeResult;
  SearchResult<CompanyJobAssignment>? _companyJobAssignmentResult;

  // UI state
  bool _loading = true;
  bool _assignCheckboxTouched = false;
  bool _showEditPanel = false;
  bool _showTaskPanel = false;
  bool _expansionOpen = false;

  // Form initial values
  Map<String, dynamic> _initialForm = {};

  // Image handling
  File? _image;
  String? _base64Image;

  // Working days mapping
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
      // Parallel fetch
      final futures = await Future.wait([
        _jobProvider.get(filter: {'JobId': widget.job.jobId}),
        _companyEmployeeProvider.get(filter: {'companyId': widget.job.company?.companyId}),
        _companyJobAssignmentProvider.get(filter: {'JobId': widget.job.jobId}),
      ]);

      if (!mounted) return;

      _jobResult = futures[0] as SearchResult<Job>?;
      _companyEmployeeResult = futures[1] as SearchResult<CompanyEmployee>?;
      _companyJobAssignmentResult = futures[2] as SearchResult<CompanyJobAssignment>?; // assignments

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
    // Build initial selected employee IDs from assignments
    final assignedIds = _companyJobAssignmentResult?.result
            .map((a) => a.companyEmployee?.companyEmployeeId)
            .whereType<int>()
            .toSet()
            .toList() ??
        [];

    _initialForm = {
      'companyEmployeeId': assignedIds,
      // add other default fields if needed
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
    final List<dynamic>? selected = form['companyEmployeeId'] as List<dynamic>? ?? [];

    if (selected!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Niste odabrali radnike.')));
      return;
    }

    setState(() => _loading = true);

    try {
      for (final id in selected!) {
        await _companyJobAssignmentProvider.insert({
          'jobId': widget.job.jobId,
          'companyEmployeeId': id,
          'assignedAt': DateTime.now().toIso8601String(),
          'isFinished': false,
        });
      }
      await _loadData(); // refresh assignments & job
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zaposlenici uspješno dodani.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška pri dodavanju zaposlenika: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _submitForm(JobStatus resultingStatus) async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Molimo popunite obavezna polja.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final values = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});

      // Normalize values
      if (values['dateFinished'] is DateTime) {
        values['dateFinished'] = (values['dateFinished'] as DateTime).toIso8601String();
      }

      final jobUpdateRequest = {
        'userId': widget.job.user?.userId,
        'freelancerId': null,
        'companyId': widget.job.company?.companyId,
        'jobTitle': widget.job.jobTitle,
        'isTenderFinalized': false,
        'isFreelancer': false,
        'isInvoiced': false,
        'isRated': false,
        'startEstimate': null,
        'endEstimate': null,
        'payEstimate': values.containsKey('payEstimate') ? values['payEstimate'] : widget.job.payEstimate,
        'payInvoice': values.containsKey('payInvoice') ? values['payInvoice'] : widget.job.payInvoice,
        'jobDate': widget.job.jobDate.toIso8601String(),
        'dateFinished': values['dateFinished'],
        'jobDescription': widget.job.jobDescription,
        'image': widget.job.image ?? _base64Image,
        'jobStatus': _jobResult?.result.first.jobStatus==JobStatus.unapproved ? JobStatus.approved.name : JobStatus.finished.name,
        'serviceId': widget.job.jobsServices?.map((e) => e.service?.serviceId).toList(),
      };

      await _jobProvider.update(widget.job.jobId, jobUpdateRequest);

      // Assign employees if provided
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

      // If finishing a job, mark assignments finished
      if (resultingStatus == JobStatus.finished) {
        final assignments = _companyJobAssignmentResult?.result ?? [];
        for (final a in assignments) {
          if (a.companyJobId != null) {
            await _companyJobAssignmentProvider.update(a.companyJobId!, {'isFinished': true});
          }
        }
      }

      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultingStatus == JobStatus.approved ? 'Posao prihvaćen.' : 'Posao označen kao završen.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška pri slanju: $e')));
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
        'userId': widget.job.user?.userId,
        'freelancerId': null,
        'companyId': widget.job.company?.companyId,
        'jobTitle': widget.job.jobTitle,
        'isTenderFinalized': false,
        'isFreelancer': false,
        'isInvoiced': false,
        'isRated': false,
        'startEstimate': null,
        'endEstimate': null,
        'payEstimate': null,
        'payInvoice': null,
        'jobDate': widget.job.jobDate.toIso8601String(),
        'dateFinished': widget.job.dateFinished?.toIso8601String(),
        'jobDescription': widget.job.jobDescription,
        'image': widget.job.image,
        'jobStatus': JobStatus.cancelled.name,
        'serviceId': widget.job.jobsServices?.map((e) => e.service?.serviceId).toList(),
      };

      await _jobProvider.update(widget.job.jobId, jobUpdateRequest);
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
                      // Left/main panel
                      Flexible(
                        flex: 3,
                        child: Card(
                          
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Alert banner if edited
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
                                _detailRow('Datum', DateFormat('dd-MM-yyyy').format(job.jobDate)),
                                _detailRow('Datum završetka', job.dateFinished != null ? DateFormat('dd-MM-yyyy').format(job.dateFinished!) : 'Nije dostupan'),
                                _detailRow('Opis posla', job.jobDescription ?? 'Nije dostupan'),

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

                                // Assignments view and selection
                                if (job.jobStatus == JobStatus.approved || job.jobStatus == JobStatus.finished)
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
                                const Divider(height: 24),

                                _sectionTitle('Korisnički podaci', color: Colors.black),
                                _detailRow('Ime i prezime', job.user != null ? '${job.user?.firstName ?? ''} ${job.user?.lastName ?? ''}' : 'Nepoznato'),
                                _detailRow('Broj telefona', _formatPhoneNumber(job.user?.phoneNumber ?? 'Nepoznato')),
                                _detailRow('Lokacija', job.user?.location?.locationName ?? 'Nepoznato'),
                                _detailRow('Adresa', job.user?.address ?? 'Nepoznato'),

                                const SizedBox(height: 12),
                                _sectionTitle('Podaci Firme', color: Colors.black),
                                _detailRow('Naziv Firme', job.company?.companyName ?? 'Nepoznato'),
                                _detailRow('E-mail', job.company?.email ?? 'Nepoznato'),
                                _detailRow('Telefonski broj', _formatPhoneNumber(job.company?.phoneNumber ?? 'Nepoznato')),

                                const SizedBox(height: 12),
                                _sectionTitle('Račun', color: Colors.black),
                                _detailRow('Procijena', (job.payEstimate != null) ? job.payEstimate!.toStringAsFixed(2) : 'Nije unesena'),
                                _detailRow('Konačna cijena', (job.payInvoice != null) ? job.payInvoice!.toStringAsFixed(2) : 'Nije unesena'),
                                _detailRow('Plaćen', job.isInvoiced == true ? 'Da' : 'Ne'),
                                if (job.jobStatus == JobStatus.cancelled) _detailRow('Otkazan', 'Da'),

                                const SizedBox(height: 12),

                                // Form for approving / finishing etc.
                                FormBuilder(
                                  key: _formKey,
                                  initialValue: _initialForm,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (job.jobStatus == JobStatus.unapproved) ...[
                                        const Divider(),
                                        _sectionTitle('Potrebni podaci', color: Colors.black),
                                        const SizedBox(height: 8),
                                        FormBuilderDateTimePicker(
                                          name: 'dateFinished',
                                          inputType: InputType.date,
                                          decoration: const InputDecoration(labelText: 'Kraj radova', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                                          firstDate: job.jobDate,
                                          initialDate: job.jobDate.isAfter(DateTime.now()) ? job.jobDate : DateTime.now(),
                                          validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                          selectableDayPredicate: _isWorkingDay,
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
                                            return FormBuilderFieldOption(value: e.companyEmployeeId!, child: Text(name));
                                          }).toList(),
                                        ),
                                      ],

                                      if (job.jobStatus == JobStatus.approved) ...[
                                        const Divider(),
                                        FormBuilderTextField(
                                          name: 'payInvoice',
                                          enabled: _jobResult?.result.first.isEdited==true ||  _jobResult?.result.first.isWorkerEdited==true  ? false : true,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(labelText: 'Finalna cijena', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
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
                                        onPressed: _editJob,
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
