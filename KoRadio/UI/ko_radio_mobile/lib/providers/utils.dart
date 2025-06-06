

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';





Image imageFromString(String input, {double? width, double? height, BoxFit? fit = BoxFit.cover, }) {
  return Image.memory(base64Decode(input), width: width, height: height,fit:fit,);
}

AppBar appBar({required String title,   Widget? actions, required bool automaticallyImplyLeading, bool centerTitle = true}) {
  return AppBar(
    title: Text(title),
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




  FormBuilderCustomTimePicker({
    super.key,
    required super.name,
    required this.minTime,
    required this.maxTime,
    required this.now,
    required this.jobDate,
    required this.bookedJobs,

    super.validator,
    super.initialValue,
    super.enabled = true,

  }) : super(
          builder: (FormFieldState<TimeOfDay?> field) {
            return InputDecorator(
              decoration: InputDecoration(
         
                errorText: field.errorText,
              ),
              child: ListTile(
                title: Text(field.value?.format(field.context) ?? 'Odaberi vrijeme'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: field.context,
                    initialTime: jobDate?.toIso8601String().split('T')[0]!=DateTime.now().toIso8601String().split('T')[0] ? field.value ?? minTime : field.value ?? now,
                    
                  );


                  
             

                  if (picked != null) {
                    final isBeforeMin = picked.hour < minTime.hour ||
                        (picked.hour == minTime.hour && picked.minute < minTime.minute);
                    final isAfterMax = picked.hour > maxTime.hour ||
                        (picked.hour == maxTime.hour && picked.minute > maxTime.minute);
                  final isToday = jobDate?.year == DateTime.now().year &&
                jobDate?.month == DateTime.now().month &&
                jobDate?.day == DateTime.now().day;

final isBeforeTimeNow = isToday && 
    (picked.hour < now.hour || (picked.hour == now.hour && picked.minute < now.minute));

                    final isDuringBookedJob = bookedJobs?.any((job) {
                          final startParts = job.startEstimate.split(':');
                          final endParts = job.endEstimate?.split(':');

                          final startHour = int.tryParse(startParts[0]) ?? 0;
                          final startMinute = int.tryParse(startParts[1]) ?? 0;
                          final endHour = int.tryParse(endParts![0]) ?? 0;
                          final endMinute = int.tryParse(endParts[1]) ?? 0;

                          final startTime =
                              TimeOfDay(hour: startHour, minute: startMinute);
                          final endTime =
                              TimeOfDay(hour: endHour, minute: endMinute);

                          final pickedMinutes =
                              picked.hour * 60 + picked.minute;
                          final startMinutes =
                              startTime.hour * 60 + startTime.minute;
                          final endMinutes = endTime.hour * 60 + endTime.minute;

                          return pickedMinutes >= startMinutes &&
                              pickedMinutes < endMinutes;
                        }) ??
                        false;

                    if (isDuringBookedJob && bookedJobs?.any != null) {
                      ScaffoldMessenger.of(field.context).showSnackBar(
                        const SnackBar(
                            content: Text('Termin zauzet. Referencijate prema terminima iznad.')),
                      );
                      return;
                    }
              
        
              
                    

                    if ((!isBeforeMin && !isAfterMax) && !isBeforeTimeNow) {  
                      field.didChange(picked);
                    
                    }
                   
                    else if(isBeforeTimeNow){
                      ScaffoldMessenger.of(field.context).showSnackBar(
                        const SnackBar(content: Text('Radnik ne posjeduje mogućnost putovanja kroz vrijeme.')),
                      );
                     }
                 
                    
               
                     else {
                      ScaffoldMessenger.of(field.context).showSnackBar(
                        SnackBar(content: Text('Radno vrijeme je između ${minTime.format(field.context)} i ${maxTime.format(field.context)}')),
                      );
                    }

                  
                  }
                },
              ),
            );
          },
        );
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




