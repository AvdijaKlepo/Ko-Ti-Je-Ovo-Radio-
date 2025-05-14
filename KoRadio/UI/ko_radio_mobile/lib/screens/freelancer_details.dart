import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/freelancer_day_schedule.dart';
import 'package:table_calendar/table_calendar.dart';

class FreelancerDetails extends StatefulWidget {
  FreelancerDetails(this.e, {super.key});
  Freelancer e;
  
  @override
  State<FreelancerDetails> createState() => _FreelancerDetailsState();
}

class _FreelancerDetailsState extends State<FreelancerDetails> {
  late DateTime _focusedDay;
  late DateTime? _selectedDay;

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
  _focusedDay = DateTime.now();
    _selectedDay=_focusedDay;
    _workingDayInts = widget.e.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
  }
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  
    if(_selectedDay!=null){
       _selectedDay = _focusedDay;
    }
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
            Row(
                
                    children: [
                     
                         widget.e.user.image != null
                            ?  Padding(
                                  child: imageFromString(widget.e.user.image!,height: 100,width: 100),
                                  padding: EdgeInsets.all(10),
                                )
                             
                            : Image.network(
                                "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png",
                                width: 100,
                                height: 100,
                              ),
                    
                    
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                       
                        children: [
                          Text('${widget.e.user.firstName} ${widget.e.user.lastName}'),
                          Text('Iskustvo: ${widget.e.experianceYears} godina'),
                          Text('Ocjena: ${widget.e.rating != 0 ? widget.e.rating : 'Neocijenjen'}'),
                          Text('Lokacija: ${widget.e.location}')
                         
                       
                         
                        ],
                      )
                    ],
                  ),
            const SizedBox(height: 20),
            const Text('Kalendar dostupnosti'),
            Expanded(
              child: TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime(2035),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      availableGestures: AvailableGestures.all,
      enabledDayPredicate: _isWorkingDay,
      onDaySelected: (selectedDay, focusedDay)  async{
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
       });

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FreelancerDaySchedule(selectedDay, widget.e),
        )); 
      },
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        selectedDecoration: BoxDecoration(
          color: const Color.fromRGBO(27, 76, 125, 1),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          border: Border.all(color: const Color.fromRGBO(27, 76, 125, 1), width: 2),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(color: Colors.black),
        weekendTextStyle: const TextStyle(color: Colors.black54),
        outsideDaysVisible: false,
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
            ),
          ],
        ),
      ),
    );
  }
}
