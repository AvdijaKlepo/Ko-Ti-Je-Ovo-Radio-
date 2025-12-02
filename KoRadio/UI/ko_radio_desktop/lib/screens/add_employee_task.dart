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
enum TaskStatus{finished, inProgress}

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
  TaskStatus _taskStatus = TaskStatus.inProgress;
  bool _isFinished = false;
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
    var filter = {'CompanyId': AuthProvider.selectedCompanyId, 'JobId': widget.job.jobId,
    'IsFinished':_isFinished};
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
        child:  const Text('Dodaj zadatak',
        style: TextStyle(
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
              style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.white,
                      
                      selectedBackgroundColor: const Color.fromRGBO(27, 76, 125, 25),
                      selectedForegroundColor: Colors.white,
                      foregroundColor: Colors.black,
                   
                      
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

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
                labelText: 'Zaposlenik',
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
              validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
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
              validator: hasRolesAssigned ? FormBuilderValidators.required(errorText: 'Obavezno polje') : null,
            ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: "Obavezno polje"),
              FormBuilderValidators.maxLength(100,errorText: 'Maksimalni broj znakova je 100'),
              FormBuilderValidators.minLength(5,errorText: 'Minimalni broj znakova je 5'),
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

  return Column(
    children: [
      Center(
        // FIX 1: Removed the "&& employeeTaskResult!.result.isNotEmpty" check.
        // Now the button stays visible even if the list is empty.
        child: SegmentedButton<TaskStatus>(
          style: SegmentedButton.styleFrom(
            backgroundColor: Colors.white,
            selectedBackgroundColor: const Color.fromRGBO(27, 76, 125, 25),
            selectedForegroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          segments: const <ButtonSegment<TaskStatus>>[
            ButtonSegment<TaskStatus>(
              value: TaskStatus.finished,
              label: Text('Završeni'),
              icon: Icon(Icons.check),
            ),
            ButtonSegment<TaskStatus>(
              value: TaskStatus.inProgress,
              label: Text('U toku'),
              icon: Icon(Icons.content_paste_search_sharp),
            ),
          ],
          selected: {_taskStatus},
          onSelectionChanged: (Set<TaskStatus> newSelection) async {
            setState(() {
              _taskStatus = newSelection.first;
              _isFinished = !_isFinished;
            });
            await _getEmployeeTasks();
          },
        ),
      ),
      const SizedBox(height: 16), // Added spacing between button and list
      
      // FIX 2: Handle empty state OUTSIDE the ListView.
      // If itemCount is 0, ListView builder is never called, so your previous check inside builder wouldn't work.
      if (employeeTaskResult?.result.isEmpty ?? true)
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Center(child: Text("Nema zadataka za prikaz.")),
        )
      else
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: employeeTaskResult!.result.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return EmployeeTaskCard(
              task: employeeTaskResult!.result[index],
              employeeTaskProvider: employeeTaskProvider,
              onDeleted: () {
                setState(() {
                  employeeTaskResult!.result.removeAt(index);
                });
              },
              onEdited: () async {
                await _getEmployeeTasks();
              },
            );
          },
        ),
    ],
  );
}
}

class EmployeeTaskCard extends StatefulWidget {
  final EmployeeTask task;
  final EmployeeTaskProvider employeeTaskProvider;
   final VoidCallback? onDeleted; 
   final VoidCallback? onEdited;
  const EmployeeTaskCard({super.key, required this.task ,required this.employeeTaskProvider, this.onDeleted ,this.onEdited});

  @override
  State<EmployeeTaskCard> createState() => _EmployeeTaskCardState();
}

class _EmployeeTaskCardState extends State<EmployeeTaskCard> {
  bool _isExpanded = false;
  final _formKey = GlobalKey<FormBuilderState>();
  void _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Izbriši zadatak?'),
        content: const Text('Jeste li sigurni da želite izbrisati ovaj zadatak?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Ne')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Da')),
        ],
      ),
    );

    if (confirm != true) return;

   
    try {
      await widget.employeeTaskProvider.delete(widget.task.employeeTaskId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zadatak je izbrisan.')),
      );
      widget.onDeleted?.call(); 
    
    }
    on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška. Molimo pokušajte ponovo.')),
      );
    }
  }

  void _editTask(String task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        surfaceTintColor: Colors.white,
        title:  Container(
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
          
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Uredi zadatak?', style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16)),
              IconButton(onPressed: () {  
              Navigator.of(context, rootNavigator: true).pop();
                
              
              }, icon: const Icon(Icons.close, color: Colors.white)),
            ],
          ),
        ),
        content: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilderTextField(
                name: 'task',
                initialValue: task,
                decoration: const InputDecoration(
                  labelText: 'Opis zadatka',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Obavezno polje'),
                  FormBuilderValidators.maxLength(100,errorText: 'Maksimalni broj znakova je 100'),
                  FormBuilderValidators.minLength(5,errorText: 'Minimalni broj znakova je 5'),
                ]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Nazad')),
          TextButton(onPressed: () async{
            final isValid = _formKey.currentState?.saveAndValidate() ?? false;
            if (!isValid) return;
            _formKey.currentState?.reset();
            final formData = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});
            await widget.employeeTaskProvider.update(widget.task.employeeTaskId, formData);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zadatak je uređen.')),
            );
            widget.onEdited?.call();
            Navigator.of(context).pop();

          }, child: const Text('Prihvati')),
        ],
      ),
    );

    

  }

  @override
  Widget build(BuildContext context) {
    return  Card(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
           
              Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                
                  Chip(
                    label: Text(
                      'Status: ${widget.task.isFinished == false ? 'U toku' : 'Završeni'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: widget.task.isFinished == false
                        ? Colors.blue.shade50
                        : Colors.grey.shade200,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
  widget.task.createdAt != null
      ? 'Dana: ${DateFormat('dd.MM.yyyy').format(widget.task.createdAt!)}'
      : 'Datum nije postavljen',
  style: Theme.of(context)
      .textTheme
      .bodySmall
      ?.copyWith(color: Colors.grey.shade700),
),

          const SizedBox(height: 8),
          Text(
            widget.task.task ?? 'Nema opisa zadatka.',
            style: const TextStyle(fontSize: 14),
            maxLines: _isExpanded ? null : 2,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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

          const SizedBox(height: 12),

          if(widget.task.isFinished==false)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () async {
                  _editTask(widget.task.task ?? '');
                  
                },
                child: const Text('Uredi zadatak'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                   _deleteTask();
                },
                child: const Text('Izbriši zadatak'),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

  }
  

}