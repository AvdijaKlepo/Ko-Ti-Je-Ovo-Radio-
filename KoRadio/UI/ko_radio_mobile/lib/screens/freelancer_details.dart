import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/book_company_job.dart';
import 'package:ko_radio_mobile/screens/freelancer_day_schedule.dart';
import 'package:ko_radio_mobile/screens/freelancer_list.dart';
import 'package:table_calendar/table_calendar.dart';

class FreelancerDetails extends StatefulWidget {
  final Freelancer? freelancer;
  final Company? company;

  const FreelancerDetails({super.key, this.freelancer, this.company});

  @override
  State<FreelancerDetails> createState() => _FreelancerDetailsState();
}

class _FreelancerDetailsState extends State<FreelancerDetails> {
  late DateTime _focusedDay;
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

  List<String>? workingDays = widget.freelancer?.workingDays ??
      widget.company?.workingDays;

  _workingDayInts = workingDays
          ?.map((day) => _dayStringToInt[day] ?? -1)
          .where((dayInt) => dayInt != -1)
          .toSet() ??
      {};

  _focusedDay = _findNextWorkingDay(DateTime.now());
  _selectedDay = _focusedDay;
}
DateTime _findNextWorkingDay(DateTime start) {
  DateTime candidate = start;
  while (!_isWorkingDay(candidate)) {
    candidate = candidate.add(const Duration(days: 1));
  }
  return candidate;
}


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
   
  }

  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }

  @override
  Widget build(BuildContext context) {
    final isFreelancer = widget.freelancer != null;

    final serviceId = isFreelancer
        ? widget.freelancer?.freelancerServices?.firstOrNull?.serviceId
        : widget.company?.companyServices?.firstOrNull?.serviceId;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Kalendar ${isFreelancer ? 'radnika' : 'kompanije'}',style: TextStyle(color: Color.fromRGBO(27, 76, 125, 1),fontFamily: GoogleFonts.lobster().fontFamily),),
        
       
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Builder(
                  builder: (context) {
                    final imageString = isFreelancer
                        ? widget.freelancer?.freelancerNavigation?.image
                        : widget.company?.image;

                    if (imageString != null) {
                      return imageFromString(imageString, height: 100, width: 100);
                    }
                     else if(isFreelancer) {
                      return SvgPicture.asset("assets/images/undraw_construction-workers_z99i.svg",
                      width: 100, height: 100);
                    }
                    else if(isFreelancer==false){
                      return SvgPicture.asset("assets/images/undraw_under-construction_c2y1.svg",width: 100, height: 100);
                    }

                    return const SizedBox();
                  },

                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isFreelancer
                      ? 'Ime: ${widget.freelancer?.freelancerNavigation?.firstName ?? ''} ${widget.freelancer?.freelancerNavigation?.lastName ?? ''}'
                      : widget.company?.companyName ?? 'Nepoznata kompanija'),
                  if (isFreelancer)
                    Text('Iskustsvo: ${widget.freelancer?.experianceYears} godine'),
                  Text('Ocjena: ${(isFreelancer ? widget.freelancer?.rating : widget.company?.rating) != 0 ? (isFreelancer ? widget.freelancer?.rating : widget.company?.rating).toString() : 'Neocijenjen'}'),
                  Text('Lokacija: ${isFreelancer ? widget.freelancer?.freelancerNavigation?.location?.locationName : widget.company?.location?.locationName ?? 'Nepoznato'}'),
                  Text('Radno vrijeme: ${isFreelancer ? widget.freelancer?.startTime.substring(0,5) : widget.company?.startTime.substring(0,5)} - ${isFreelancer ? widget.freelancer?.endTime.substring(0,5) : widget.company?.endTime.substring(0,5)}'),
                 
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Kalendar dostupnosti'),
          Expanded(
            child: TableCalendar(
              key: const PageStorageKey('calendar'), 

              shouldFillViewport: true,
              firstDay: DateTime.now(),
              lastDay: DateTime(2035),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              availableGestures: AvailableGestures.all,
              enabledDayPredicate: _isWorkingDay,
             onDaySelected: (selectedDay, focusedDay) async {
  setState(() {

    _focusedDay = selectedDay;
  });

  if (isFreelancer) {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FreelancerDaySchedule(selectedDay, widget.freelancer!),
    ));
  } else {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BookCompanyJob(widget.company!, selectedDay),
    ));
  }

  if (mounted) {
    setState(() {
      _focusedDay = _selectedDay!;
    });
  }
},
              calendarStyle: CalendarStyle(
              
                isTodayHighlighted: true,
                selectedDecoration: const BoxDecoration(
                  color: Color.fromRGBO(27, 76, 125, 1),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromRGBO(27, 76, 125, 1), width: 2),
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
    );
  }
}
