

import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';

String formatDateTime(DateTime? date) {
  if (date == null) return "";
  return "${date.day}.${date.month}.${date.year}";
}

List<String> getWorkingDaysInRange({
  required DateTime jobDate,
  required DateTime dateFinished,
  required List<String> workingDays,
}) {

  final normalized =  workingDays.map((d) => d.toLowerCase()).toSet();

  final result = <String>[];
  DateTime current = jobDate;

  while (!current.isAfter(dateFinished)) {
    final dayName = _dayName(current.weekday); 
    if (normalized.contains(dayName.toLowerCase())) {
      result.add(dayName);
    }
    current = current.add(const Duration(days: 1));
  }

  return localizeWorkingDays(result);
}

String _dayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return "Monday";
    case DateTime.tuesday:
      return "Tuesday";
    case DateTime.wednesday:
      return "Wednesday";
    case DateTime.thursday:
      return "Thursday";
    case DateTime.friday:
      return "Friday";
    case DateTime.saturday:
      return "Saturday";
    case DateTime.sunday:
      return "Sunday";
    default:
      return "";
  }
}




Image imageFromString(String input, {double? width, double? height, BoxFit? fit = BoxFit.cover, }) {
  return Image.memory(base64Decode(input), width: width, height: height,fit:fit,);
}

AppBar appBar({required String title,   Widget? actions, required bool automaticallyImplyLeading, bool centerTitle = true}) {
  return AppBar(
    scrolledUnderElevation: 0,
    title: Text(title,style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromRGBO(27, 76, 125, 25),fontFamily: GoogleFonts.lobster().fontFamily,letterSpacing: 1.2),),
    centerTitle: centerTitle,
    automaticallyImplyLeading: automaticallyImplyLeading,

   
  
  );
}





class FormBuilderCustomTimePicker extends FormBuilderField<TimeOfDay> {
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final TimeOfDay now;
  final DateTime? jobDate;
  final List<Job>? bookedJobs;
  final Function? onChange;
  @override
  final ValueChanged<TimeOfDay?>? onChanged;



  FormBuilderCustomTimePicker({
    super.key,
    required super.name,
    required this.minTime,
    required this.maxTime,
    required this.now,
    required this.jobDate,
    required this.bookedJobs,
    this.onChange,
    this.onChanged,

    super.validator,
    super.initialValue,
    super.enabled = true,

  }) : super(
          builder: (FormFieldState<TimeOfDay?> field) {
          bool outOfWorkHours=false;
           
          
          
           return GestureDetector(
  onTap: () async {
                  final picked = await showTimePicker(
                    context: field.context,
                    initialTime: jobDate?.toIso8601String().split('T')[0]!=DateTime.now().toIso8601String().split('T')[0] ? field.value ?? minTime : field.value ?? now,
                    
                    
                  );
                  
  
          
        
             
 if (picked == null) return;

                // Time-based validation
                final isBeforeMin = picked.hour < minTime.hour ||
                    (picked.hour == minTime.hour &&
                        picked.minute < minTime.minute);
                final isAfterMax = picked.hour > maxTime.hour ||
                    (picked.hour == maxTime.hour &&
                        picked.minute > maxTime.minute);

                final isToday = jobDate?.year == DateTime.now().year &&
                    jobDate?.month == DateTime.now().month &&
                    jobDate?.day == DateTime.now().day;

                final isBeforeTimeNow = isToday &&
                    (picked.hour < now.hour ||
                        (picked.hour == now.hour &&
                            picked.minute < now.minute));

                final isDuringBookedJob = bookedJobs?.any((job) {
                      final startParts = job.startEstimate?.split(':');
                      final endParts = job.endEstimate?.split(':');
                      if (startParts == null || endParts == null) return false;

                      final startTime = TimeOfDay(
                          hour: int.tryParse(startParts[0]) ?? 0,
                          minute: int.tryParse(startParts[1]) ?? 0);
                      final endTime = TimeOfDay(
                          hour: int.tryParse(endParts[0]) ?? 0,
                          minute: int.tryParse(endParts[1]) ?? 0);

                      final pickedMinutes = picked.hour * 60 + picked.minute;
                      final startMinutes =
                          startTime.hour * 60 + startTime.minute;
                      final endMinutes = endTime.hour * 60 + endTime.minute;

                      return pickedMinutes >= startMinutes &&
                          pickedMinutes < endMinutes;
                    }) ??
                    false;

                if (isDuringBookedJob) {
                  ScaffoldMessenger.of(field.context).showSnackBar(
                    const SnackBar(
                        content: Text('Termin zauzet. Referencijate prema terminima iznad.')),
                  );
                  return;
                }

                if (isBeforeTimeNow) {
                  ScaffoldMessenger.of(field.context).showSnackBar(
                    const SnackBar(
                        content: Text('Radnik ne posjeduje mogućnost putovanja kroz vrijeme.')),
                  );
                  return;
                }

                if (isBeforeMin || isAfterMax) {
                  ScaffoldMessenger.of(field.context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Radno vrijeme je između ${minTime.format(field.context)} i ${maxTime.format(field.context)}')),
                  );
                  return;
                }
                field.didChange(picked);
                    if(onChanged != null)
                    {
                      onChanged(picked);
                    }
                },
  child: InputDecorator(
    decoration: InputDecoration(
      border: const OutlineInputBorder(),
      prefixIcon: const Icon(Icons.schedule),
      labelText: field.value!=null ? 'Vrijeme početka' : '',
      errorText: field.errorText,
    ),
    // this makes the inside text look like a standard input
    child: Text(
      field.value?.format(field.context) ?? 'Vrijeme početka',
      style: Theme.of(field.context).textTheme.bodyMedium,
    ),
  ),
);

          },
        );
}
 DateTime parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }
     parseTimeString(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
bool isOverlapping(DateTime selected, List<Map<String, DateTime>> jobs) {
  for (final job in jobs) {
    final start = job["start"]!;
    final end = job["end"]!;
    if (selected.isAfter(start) && selected.isBefore(end)) {
      return true;
    }
  }
  return false;
}
bool validateAccountStatus(User user) {
  if (user.isDeleted == true && AuthProvider.selectedRole == "User") {
    return false;
  }

  final freelancer = user.freelancer;
  if (freelancer != null) {
    if (freelancer.isDeleted! && AuthProvider.selectedRole == "Freelancer") {
      return false;
    }
    if (freelancer.isApplicant! && AuthProvider.selectedRole == "Freelancer") {
      return false;
    }
  }

  final companyEmployees = user.companyEmployees ?? [];
  for (final ce in companyEmployees) {
    if (ce.isDeleted == true && AuthProvider.selectedRole == "CompanyEmployee") {
      return false;
    }
    if (ce.isApplicant == true && AuthProvider.selectedRole == "CompanyEmployee") {
      return false;
    }
  }

  return true; 
}
String capitalize(String? s) {
  if (s == null || s.isEmpty) {
    return '';
  }
  // Make sure the rest of the string is not capitalized.
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}



List<String> localizeWorkingDays(List<dynamic>? days) {
  if (days == null) return [];

  const dayNamesHR = [
    "Nedjelja",
    "Ponedjeljak",
    "Utorak",
    "Srijeda",
    "Četvrtak",
    "Petak",
    "Subota"
  ];

  const mapping = {
    "Sunday": "Nedjelja",
    "Monday": "Ponedjeljak",
    "Tuesday": "Utorak",
    "Wednesday": "Srijeda",
    "Thursday": "Četvrtak",
    "Friday": "Petak",
    "Saturday": "Subota"
  };

  return days.map((d) {
    if (d is int && d >= 0 && d <= 6) return dayNamesHR[d];
    if (d is String) return mapping[d] ?? d;
    return d.toString();
  }).toList();
}


  
String formatJobRange(DateTime start, DateTime end) {
  final dateFmt = DateFormat('dd.MM.yyyy');
  final timeFmt = DateFormat('HH:mm');

  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    // Same day
    return "${dateFmt.format(start)} ${timeFmt.format(start)} – ${timeFmt.format(end)}";
  } else {
    // Multi-day
    return "${dateFmt.format(start)} ${timeFmt.format(start)} – "
           "${dateFmt.format(end)} ${timeFmt.format(end)}";
  }
}
String? formatTimeOnly(dynamic value) {
  if (value == null) return null;

  if (value is DateTime) {
    return "${value.hour.toString().padLeft(2, '0')}:"
           "${value.minute.toString().padLeft(2, '0')}:"
           "${value.second.toString().padLeft(2, '0')}";
  }

  if (value is TimeOfDay) {
    return "${value.hour.toString().padLeft(2, '0')}:"
           "${value.minute.toString().padLeft(2, '0')}:00";
  }

  if (value is String) {
    // if already formatted correctly, just return it
    final regex = RegExp(r'^\d{2}:\d{2}(:\d{2})?$');
    if (regex.hasMatch(value)) {
      return value.length == 5 ? "$value:00" : value;
    }
  }

  return null;
}






Future<T?> handleRequest<T>(
  BuildContext context,
  Future<T> Function() action,
) async {
  try {
    return await action();
  } catch (e) {
    final message = e.toString().replaceFirst("Exception: ", "");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }
}


typedef PaginatedDataFetcher<T> = Future<PaginatedResult<T>> Function({
  required int page,
  required int pageSize,
  Map<String, dynamic>? filter,
});

class PaginatedResult<T> {
  final List<T> result;
  final int count;

  PaginatedResult({required this.result, required this.count});
}

class PaginatedFetcher<T> extends ChangeNotifier {
  final PaginatedDataFetcher<T> fetcher;
  final int pageSize;
  final Map<String, dynamic>? initialFilter;

  List<T> items = [];
  int _page = 1;
  bool isLoading = false;
  bool hasNextPage = true;

  Map<String, dynamic>? _activeFilter; 

  PaginatedFetcher({
    required this.fetcher,
    this.pageSize = 20,
    this.initialFilter,
  }) {
    _activeFilter = initialFilter; 
  }

  Future<void> refresh({Map<String, dynamic>? newFilter}) async {
    _page = 1;
    hasNextPage = true;
    items.clear();

    _activeFilter = newFilter ?? initialFilter; 
    await _fetchPage(filter: _activeFilter);
  }

  Future<void> loadMore() async {
    if (isLoading || !hasNextPage) return;
    _page++;
    await _fetchPage(filter: _activeFilter); 
  }

  Future<void> _fetchPage({Map<String, dynamic>? filter}) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await fetcher(
        page: _page,
        pageSize: pageSize,
        filter: _activeFilter,
      );
      items.addAll(result.result);
      if (items.length >= result.count) {
        hasNextPage = false;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}


  void _showMessage(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}