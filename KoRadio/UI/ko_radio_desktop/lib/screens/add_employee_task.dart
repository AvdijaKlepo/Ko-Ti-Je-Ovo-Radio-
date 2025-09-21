import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/models/company_role.dart';
import 'package:ko_radio_desktop/models/employee_task.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/company_role_provider.dart';
import 'package:ko_radio_desktop/providers/employee_task_provider.dart';
import 'package:provider/provider.dart';

enum AssignmentType { employee, role }

class AddEmployeeTask extends StatefulWidget {
  const AddEmployeeTask({required this.job, super.key});
  final Job job;

  @override
  State<AddEmployeeTask> createState() => _AddEmployeeTaskState();
}

class _AddEmployeeTaskState extends State<AddEmployeeTask> {
  final _formKey = GlobalKey<FormBuilderState>();
  late CompanyEmployeeProvider companyEmployeeProvider;
  late EmployeeTaskProvider employeeTaskProvider;
  late CompanyRoleProvider companyRoleProvider;
  late CompanyJobAssignmentProvider companyJobAssignmentProvider;
  late CompanyProvider companyProvider;
  SearchResult<CompanyEmployee>? companyEmployeeResult;
  SearchResult<CompanyRole>? companyRoleResult;
  SearchResult<EmployeeTask>? employeeTaskResult;
  SearchResult<CompanyJobAssignment>? companyJobAssignmentResult;
  bool _isLoading = false;
  AssignmentType _assignmentType = AssignmentType.employee;
  late Set<int> _workingDayInts;
  final Map<String, int> _dayStringToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };


  @override
  void initState() {
    super.initState();
    companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
    employeeTaskProvider = context.read<EmployeeTaskProvider>();
    companyRoleProvider = context.read<CompanyRoleProvider>();
    companyJobAssignmentProvider = context.read<CompanyJobAssignmentProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchData();
      _workingDayInts = widget.job.company?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.wait([
        _getCompanyEmployees(),
        _getCompanyRoles(),
        _getEmployeeTasks(),
        _getCompanyJobAssignments(),

      ]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
   bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }

  Future<void> _getCompanyJobAssignments() async {
    var filter = {'JobId': widget.job.jobId};
    var fetchedCompanyJobAssignments = await companyJobAssignmentProvider.get(filter: filter);
    if (!mounted) return;
    setState(() {
      companyJobAssignmentResult = fetchedCompanyJobAssignments;
    });
  }

  Future<void> _getEmployeeTasks() async {
    var filter = {'CompanyId': AuthProvider.selectedCompanyId, 'JobId': widget.job.jobId};
    var fetchedEmployeeTasks = await employeeTaskProvider.get(filter: filter);
    if (!mounted) return;
    setState(() {
      employeeTaskResult = fetchedEmployeeTasks;
    });
  }

  Future<void> _getCompanyRoles() async {
    var filter = {'CompanyId': AuthProvider.selectedCompanyId};
    var fetchedCompanyRoles = await companyRoleProvider.get(filter: filter);
    if (!mounted) return;
    setState(() {
      companyRoleResult = fetchedCompanyRoles;
    });
  }

  Future<void> _getCompanyEmployees() async {
    var filter = {'CompanyId': AuthProvider.selectedCompanyId};
    var fetchedCompanyEmployees = await companyEmployeeProvider.get(filter: filter);
    if (!mounted) return;
    setState(() {
      companyEmployeeResult = fetchedCompanyEmployees;
    });
  }
  

  Future<void> _saveTask() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;

    final formData = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});

    if (formData["createdAt"] is DateTime) {
      formData["createdAt"] = (formData["createdAt"] as DateTime).toIso8601String();
    }
    formData["jobId"] = widget.job.jobId;
    formData["companyId"] = AuthProvider.selectedCompanyId;

    try {
      if (_assignmentType == AssignmentType.role) {
        var matchingEmployees = companyEmployeeResult?.result
            .where((element) => element.companyRoleId == formData["companyRoleId"])
            .toList();
        var employeeIds = matchingEmployees?.map((e) => e.companyEmployeeId).toList() ?? [];

        if (employeeIds.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Nema radnika sa odabranom ulogom.")),
          );
          return;
        }

        for (var employeeId in employeeIds) {
          var singleInsert = Map<String, dynamic>.from(formData);
          singleInsert["companyEmployeeId"] = employeeId;
          await employeeTaskProvider.insert(singleInsert);
        }
      } else {
        await employeeTaskProvider.insert(formData);
      }
      _formKey.currentState?.reset();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zadatak uspješno dodan!")),
      );
      await _getEmployeeTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterLoggedInUser = companyJobAssignmentResult?.result
        .where((assignment) => assignment.jobId == widget.job.jobId)
        .map((assignment) => assignment.companyEmployee)
        .whereType<CompanyEmployee>()
        .toList();

    return Scaffold(
    
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
        child:  Text('Dodaj zadatak',
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),),
            
          ),
      

              const SizedBox(height: 24),
              _buildTaskForm(filterLoggedInUser),
              const SizedBox(height: 24),
              _buildEmployeeTaskList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskForm(List<CompanyEmployee>? filteredEmployees) {
    final hasRolesAssigned = filteredEmployees != null &&
        filteredEmployees.any((e) => e.companyRoleId != null);
    final rolesAvailable = filteredEmployees
        ?.where((e) => e.companyRoleId != null)
        .map((e) => e.companyRoleId!)
        .toSet()
        .map((roleId) => companyRoleResult?.result.firstWhere((role) => role.companyRoleId == roleId))
        .whereType<CompanyRole>()
        .toList() ?? [];

    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SegmentedButton<AssignmentType>(
              segments: const <ButtonSegment<AssignmentType>>[
                ButtonSegment<AssignmentType>(
                  value: AssignmentType.employee,
                  label: Text('Radnik'),
                  icon: Icon(Icons.person),
                ),
                ButtonSegment<AssignmentType>(
                  value: AssignmentType.role,
                  label: Text('Uloga'),
                  icon: Icon(Icons.group),
                ),
              ],
              selected: {_assignmentType},
              onSelectionChanged: (Set<AssignmentType> newSelection) {
                setState(() {
                  _assignmentType = newSelection.first;
                  _formKey.currentState?.fields['companyEmployeeId']?.reset();
                  _formKey.currentState?.fields['companyRoleId']?.reset();
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          if (_assignmentType == AssignmentType.employee)
            FormBuilderDropdown<int>(
              name: 'companyEmployeeId',
              decoration: const InputDecoration(
                labelText: 'Zaposleni',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: filteredEmployees
                  ?.map(
                    (item) => DropdownMenuItem(
                      value: item.companyEmployeeId,
                      child: Text('${item.user?.firstName} ${item.user?.lastName}'),
                    ),
                  )
                  .toList() ?? [],
              validator: FormBuilderValidators.required(),
            ),
          if (_assignmentType == AssignmentType.role)
            FormBuilderDropdown<int>(
              name: 'companyRoleId',
              enabled: hasRolesAssigned,
              decoration: InputDecoration(
                labelText: 'Uloga',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.group_outlined),
                errorText: !hasRolesAssigned ? "Nema dodijeljenih uloga." : null,
              ),
              items: rolesAvailable
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.companyRoleId,
                      child: Text(item.roleName ?? ''),
                    ),
                  )
                  .toList(),
              validator: hasRolesAssigned ? FormBuilderValidators.required() : null,
            ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "Obavezno polje"),
            ]),
            name: "task",
            decoration: const InputDecoration(
              labelText: 'Zadatak',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_outlined),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          FormBuilderDateTimePicker(
            name: 'createdAt',
            initialDate: widget.job.jobDate,
            inputType: InputType.date,
            initialValue: widget.job.jobDate,
            firstDate: widget.job.jobDate,
            lastDate: widget.job.dateFinished ?? widget.job.jobDate,
            selectableDayPredicate: _isWorkingDay,
            format: DateFormat('dd.MM.yyyy'),
            decoration: const InputDecoration(
              labelText: 'Datum',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Dodaj zadatak"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeTaskList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (employeeTaskResult?.result.isEmpty ?? true) {
      return const Center(child: Text("Nema zadataka za prikaz."));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employeeTaskResult!.result.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return EmployeeTaskCard(task: employeeTaskResult!.result[index]);
      },
    );
  }
}

class EmployeeTaskCard extends StatefulWidget {
  final EmployeeTask task;
  const EmployeeTaskCard({super.key, required this.task});

  @override
  State<EmployeeTaskCard> createState() => _EmployeeTaskCardState();
}

class _EmployeeTaskCardState extends State<EmployeeTaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.assignment, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Zadatak za: ${widget.task.companyEmployee?.user?.firstName ?? ''} ${widget.task.companyEmployee?.user?.lastName ?? ''}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      widget.task.companyEmployee?.companyRoleName ?? 'Zaposlenik nema uloge',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: widget.task.companyEmployee?.companyRoleName != null ? Colors.blue.shade50 : Colors.grey.shade200,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Datum: ${DateFormat('dd.MM.yyyy').format(widget.task.createdAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                widget.task.task ?? 'Nema opisa zadatka.',
                style: const TextStyle(fontSize: 14),
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              if ((widget.task.task ?? '').length > 50)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Prikaži manje' : 'Prikaži više',
                      style: const TextStyle(color: Colors.blue),
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