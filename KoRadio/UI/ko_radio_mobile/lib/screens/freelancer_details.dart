
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/screens/freelancer_day_schedule.dart';
import 'package:table_calendar/table_calendar.dart';

class FreelancerDetails extends StatefulWidget {
  FreelancerDetails(this.e, {super.key});
  Freelancer e;

  @override
  State<FreelancerDetails> createState() => _FreelancerDetailsState();
}

class _FreelancerDetailsState extends State<FreelancerDetails> {
   DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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

    // Convert working day strings to weekday integers
    _workingDayInts = widget.e.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
  }

  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }

  @override
  Widget build(BuildContext context) {
    
    return MasterScreen(
      
      child: Scaffold(
        body: Column(
          children: [
            Text("${widget.e.user.firstName} ${widget.e.user.lastName}"),
            Text("${widget.e.location}"),
            Text("${widget.e.hourlyRate} KM/h"),
            Text("⭐ ${widget.e.rating}"),
            Text("${widget.e.bio}"),
            const SizedBox(height: 20),
            Expanded(
              child: TableCalendar(
                firstDay: DateTime(2025),
                lastDay: DateTime(2035),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                enabledDayPredicate: (day) => _workingDayInts.contains(day.weekday),
                
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                 
                    _selectedDay = selectedDay;
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>FreelancerDaySchedule()));
                    
                
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) {
                    final isWorking = _isWorkingDay(day);
                    
                    return Container(
                      decoration: BoxDecoration(
                       
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      
                        
                        child: MouseRegion(
                      
                        child: 
                       Text(
                        '${day.day}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          

                        ),
                      ),
                        )
                    );
                  },
                  todayBuilder: (context, day, _) {
                    final isWorking = _isWorkingDay(day);
                    return Container(
                      decoration: BoxDecoration(
                  
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
