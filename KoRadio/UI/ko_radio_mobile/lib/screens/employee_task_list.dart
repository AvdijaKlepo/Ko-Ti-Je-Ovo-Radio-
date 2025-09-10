import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/employee_task.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/employee_task_provider.dart';
import 'package:provider/provider.dart';

class EmployeeTaskList extends StatefulWidget {
  const EmployeeTaskList({super.key, required this.job});
  final Job job;

  @override
  State<EmployeeTaskList> createState() => _EmployeeTaskListState();
}

class _EmployeeTaskListState extends State<EmployeeTaskList> {
  late EmployeeTaskProvider employeeTaskProvider;
  SearchResult<EmployeeTask>? employeeTaskResult;
  bool _isLoading = false;

  // Use a nullable bool so we can pass directly to API
  bool? _isFinished = false;

  @override
  void initState() {
    super.initState();
    employeeTaskProvider = context.read<EmployeeTaskProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getEmployeeTask();
    });
  }

  Future<void> _getEmployeeTask() async {
    var filter = {
      'CompanyEmployeeId': AuthProvider.selectedCompanyEmployeeId,
      'JobId': widget.job.jobId,
      'isFinished': _isFinished,
    };

    setState(() => _isLoading = true);

    try {
      var fetchedEmployeeTask = await employeeTaskProvider.get(filter: filter);
      setState(() {
        employeeTaskResult = fetchedEmployeeTask;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška. Molim pokušajte ponovo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Pregled zadataka",
          style: TextStyle(
            fontFamily: GoogleFonts.lobster().fontFamily,
            color: const Color.fromRGBO(27, 76, 125, 25),
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔹 SegmentedButton for filtering tasks
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.pending_actions),
                  label: Text("Aktivni"),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.done_all),
                  label: Text("Završeni"),
                ),
              ],
              selected: {_isFinished ?? false},
              onSelectionChanged: (newSelection) async {
                setState(() {
                  _isFinished = newSelection.first;
                });
                await _getEmployeeTask();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color.fromRGBO(27, 76, 125, 1);
                  }
                  return Colors.grey.shade200;
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.white;
                  }
                  return Colors.black87;
                }),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (employeeTaskResult?.result.isEmpty ?? true)
                    ? const Center(child: Text("Nema zadataka"))
                    : ListView.separated(
                        separatorBuilder: (context, index) =>
                            const Divider(height: 35),
                        itemCount: employeeTaskResult!.result.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: EmployeeTaskTile(
                              task: employeeTaskResult!.result[index],
                              employeeTaskProvider: employeeTaskProvider,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}


class EmployeeTaskTile extends StatefulWidget {
  final EmployeeTask task;
  final EmployeeTaskProvider employeeTaskProvider;
  const EmployeeTaskTile({super.key, required this.task, required this.employeeTaskProvider});

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
                  "Datum: ${DateFormat('dd.MM.yyyy').format(widget.task.createdAt!)}",
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
                  "Radnik: ${AuthProvider.user?.firstName} ${AuthProvider.user?.lastName}",
                  style: const TextStyle(color: Colors.white70),
                ),
               
               
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                  ),
                ),
                if(widget.task.isFinished==false)
                 Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    child: ElevatedButton(
                      child: const Text('Završi zadatak'),
                      onPressed: () async {
                        try { 
                          await widget.employeeTaskProvider.update(widget.task.employeeTaskId,
                          {
                            "isFinished": true,
                          });
                          setState(() {
                            
                          });
                        
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Zadatak završen')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Greška. Molim pokušajte ponovo.')),
                          );
                        }
                      },
                    ),
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
