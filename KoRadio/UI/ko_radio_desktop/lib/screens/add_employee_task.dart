import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/company_role.dart';
import 'package:ko_radio_desktop/models/employee_task.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_role_provider.dart';
import 'package:ko_radio_desktop/providers/employee_task_provider.dart';
import 'package:provider/provider.dart';

class AddEmployeeTask extends StatefulWidget {
  const AddEmployeeTask({ required this.job, super.key});
  final Job job;

  @override
  State<AddEmployeeTask> createState() => _AddEmployeeTaskState();
}

class _AddEmployeeTaskState extends State<AddEmployeeTask> {
   final _formKey = GlobalKey<FormBuilderState>();
   final _formKeyRole = GlobalKey<FormBuilderState>();
   late CompanyEmployeeProvider companyEmployeeProvider;
   late EmployeeTaskProvider employeeTaskProvider;
   late CompanyRoleProvider companyRoleProvider;
   SearchResult<CompanyEmployee>? companyEmployeeResult;
   SearchResult<CompanyRole>? companyRoleResult;
   SearchResult<EmployeeTask>? employeeTaskResult;
   bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    companyEmployeeProvider = context.read<CompanyEmployeeProvider>();
    employeeTaskProvider = context.read<EmployeeTaskProvider>();
    companyRoleProvider = context.read<CompanyRoleProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getCompanyEmployees();
      await _getCompanyRoles();
      await _getEmployeeTasks();
    });
  }
  Future<void> _getEmployeeTasks() async {
    setState(() {
      _isLoading = true;
    });
    var filter = {'CompanyId': AuthProvider.selectedCompanyId,
    'JobId': widget.job.jobId};
    try {
      var fetchedEmployeeTasks = await employeeTaskProvider.get(filter: filter);
      setState(() {
        employeeTaskResult = fetchedEmployeeTasks;
        _isLoading = false;
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  Future<void> _getCompanyRoles() async {
    var filter = {'companyId': AuthProvider.selectedCompanyId};
    try {
      var fetchedCompanyRoles = await companyRoleProvider.get(filter: filter);
      setState(() {
        companyRoleResult = fetchedCompanyRoles;
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  Future<void> _getCompanyEmployees() async {
    var filter = {'CompanyId': AuthProvider.selectedCompanyId};
    try {
      var fetchedCompanyEmployees = await companyEmployeeProvider.get(filter: filter);
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

  @override
Widget build(BuildContext context) {
  final filterLoggedInUser = companyEmployeeResult?.result
      .where((element) => element.userId != AuthProvider.user?.userId)
      .toList();



  return Dialog(
    insetPadding: const EdgeInsets.all(24),
    child: Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTaskForm(filterLoggedInUser, _formKey),
            _buildRoleForm(filterLoggedInUser),
            _buildEmployeeTask( employeeTaskResult),
            
          ],
        ),
      ),
    ),
  );
}

Widget _buildTaskForm(List<CompanyEmployee>? filterLoggedInUser, GlobalKey<FormBuilderState> formKey) {
  return FormBuilder(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 6),
        FormBuilderDropdown(
          name: 'CompanyEmployeeId',
          decoration: const InputDecoration(
            labelText: 'Zaposleni',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          items: filterLoggedInUser
                  ?.map(
                    (item) => DropdownMenuItem(
                      value: item.companyEmployeeId,
                      child: Text('${item.user?.firstName} ${item.user?.lastName}'),
                    ),
                  )
                  .toList() ??
              [],
          validator: FormBuilderValidators.required(),
        ),
        const SizedBox(height: 15),
        FormBuilderTextField(
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: "Obavezno polje"),
          ]),
          name: "task",
          decoration: const InputDecoration(
            labelText: 'Zadatak',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 15),
        FormBuilderDateTimePicker(
          name: 'createdAt',
          initialDate: DateTime.now(),
          inputType: InputType.date,
          initialValue: DateTime.now(),
          firstDate: DateTime.now(),
          format: DateFormat('dd-MM-yyyy'),
          decoration: const InputDecoration(
            labelText: 'Datum',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => _save(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            "Sačuvaj",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
Widget _buildRoleForm(List<CompanyEmployee>? filterLoggedInUser) {
return FormBuilder(
    key: _formKeyRole,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 6),
        FormBuilderDropdown(
          name: 'companyRoleId',
          decoration: const InputDecoration(
            labelText: 'Uloge',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.sticky_note_2_sharp),
          ),
          items: companyRoleResult?.result
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.companyRoleId,
                      child: Text('${item.roleName}'),
                    ),
                  )
                  .toList() ??
              [],
          validator: FormBuilderValidators.required(),
        ),
        const SizedBox(height: 15),
        FormBuilderTextField(
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: "Obavezno polje"),
          ]),
          name: "task",
          decoration: const InputDecoration(
            labelText: 'Zadatak',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 15),
        FormBuilderDateTimePicker(
          name: 'createdAt',
          initialDate: DateTime.now(),
          inputType: InputType.date,
          initialValue: DateTime.now(),
          firstDate: DateTime.now(),
          format: DateFormat('dd-MM-yyyy'),
          decoration: const InputDecoration(
            labelText: 'Datum',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => _saveRole(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            "Sačuvaj",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
Widget _buildEmployeeTask(SearchResult<EmployeeTask>? employeeTaskResult) {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (employeeTaskResult?.result.isEmpty ?? true) {
    return const Center(child: Text("Nema zadataka"));
  }

  return ListView.separated(
    shrinkWrap: true, // Important inside SingleChildScrollView
    physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling
    itemCount: employeeTaskResult!.result.length,
    separatorBuilder: (context, index) => const Divider(height: 35),
    itemBuilder: (context, index) {
      return EmployeeTaskTile(task: employeeTaskResult.result[index]);
    },
  );
}



Future<void> _saveRole() async {
    final isValid = _formKeyRole.currentState?.saveAndValidate() ?? false;

    if (!isValid) {
      return;
    }
    var formData = Map<String, dynamic>.from(_formKeyRole.currentState?.value ?? {});

      if (formData["createdAt"] is DateTime) {
                  formData["createdAt"] =
                      (formData["createdAt"] as DateTime).toIso8601String();
                }
                formData["jobId"] = widget.job.jobId;
                formData["companyId"] = AuthProvider.selectedCompanyId;
   
  
   var matchingEmployees = companyEmployeeResult?.result
      .where((element) =>
    element.companyRoleId == formData["companyRoleId"])
      .toList();

  var employeeIds = matchingEmployees?.map((e) => e.companyEmployeeId).toList() ?? [];
  print("Form data: $formData");
print("Matching employees: $matchingEmployees");
print("Employee IDs: $employeeIds");

   try{
    for (var employeeId in employeeIds) {
      var singleInsert = Map<String, dynamic>.from(formData);
      singleInsert["companyEmployeeId"] = employeeId; 
      await employeeTaskProvider.insert(singleInsert);
    }
     _formKeyRole.currentState?.reset();
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text("Zadatak dodan")),
     );
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }



  Future<void> _save() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;

    if (!isValid) {
      return;
    }
    var formData = Map<String, dynamic>.from(_formKey.currentState?.value ?? {});
      if (formData["createdAt"] is DateTime) {
                  formData["createdAt"] =
                      (formData["createdAt"] as DateTime).toIso8601String();
                }
                formData["jobId"] = widget.job.jobId;
                formData["companyId"] = AuthProvider.selectedCompanyId;
    try {
      await employeeTaskProvider.insert(formData);
      _formKey.currentState?.reset();
      
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
}
class EmployeeTaskTile extends StatefulWidget {
  final EmployeeTask task;
  const EmployeeTaskTile({super.key, required this.task});

  @override
  State<EmployeeTaskTile> createState() => _EmployeeTaskTileState();
}

class _EmployeeTaskTileState extends State<EmployeeTaskTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Card(
        color: const Color.fromRGBO(27, 76, 125, 25),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  "Datum: ${widget.task.createdAt.toString().split('T')[0]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                // Task text
                Text(
                  widget.task.task ?? '',
                  style: const TextStyle(color: Colors.white),
                  maxLines: _expanded ? null : 2,
                  overflow:
                      _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Worker name
                Text(
                  "Radnik: ${widget.task.companyEmployee?.user?.firstName ?? ''} ${widget.task.companyEmployee?.user?.lastName ?? ''}",
                  style: const TextStyle(color: Colors.white70),
                ),

                // Expand/collapse icon
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
