import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/employee_task.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/employee_task_provider.dart';
import 'package:provider/provider.dart';

class EmployeeTaskList extends StatefulWidget {
  const EmployeeTaskList({super.key});

  @override
  State<EmployeeTaskList> createState() => _EmployeeTaskListState();
}

class _EmployeeTaskListState extends State<EmployeeTaskList> {
  late EmployeeTaskProvider employeeTaskProvider;
  SearchResult<EmployeeTask>? employeeTaskResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    employeeTaskProvider = context.read<EmployeeTaskProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getEmployeeTask();
    });
  }

  Future<void> _getEmployeeTask() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var fetchedEmployeeTask = await employeeTaskProvider.get();
      setState(() {
        employeeTaskResult = fetchedEmployeeTask;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (employeeTaskResult?.result.isEmpty ?? true)
                ? const Center(child: Text("Nema zadataka"))
                : ListView.separated(
                    separatorBuilder: (context, index) =>
                        const Divider(height: 35),
                    itemCount: employeeTaskResult!.result.length,
                    itemBuilder: (context, index) {
                      return EmployeeTaskTile(
                        task: employeeTaskResult!.result[index],
                      );
                    },
                  ),
      ),
    );
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
