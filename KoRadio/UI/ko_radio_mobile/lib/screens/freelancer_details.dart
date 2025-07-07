import 'package:flutter/material.dart';
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
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;

    List<String>? workingDays = widget.freelancer?.workingDays ??
        widget.company?.workingDays;

    _workingDayInts = workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedDay != null) {
      _selectedDay = _focusedDay;
    }
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
        title: Text('Kalendar ${isFreelancer ? 'radnika' : 'kompanije'}'),
        
       
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

                    if (imageString != null && imageString.startsWith("data:image")) {
                      return imageFromString(imageString, height: 100, width: 100);
                    } else {
                      return Image.network(
                        imageString ??
                            "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png",
                        height: 100,
                        width: 100,
                      );
                    }
                  },
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isFreelancer
                      ? '${widget.freelancer?.freelancerNavigation?.firstName ?? ''} ${widget.freelancer?.freelancerNavigation?.lastName ?? ''}'
                      : widget.company?.companyName ?? 'Nepoznata kompanija'),
                  if (isFreelancer)
                    Text('Iskustvo: ${widget.freelancer?.experianceYears} godina'),
                  Text('Ocjena: ${(isFreelancer ? widget.freelancer?.rating : widget.company?.rating) != 0 ? (isFreelancer ? widget.freelancer?.rating : widget.company?.rating).toString() : 'Neocijenjen'}'),
                  Text('Lokacija: ${isFreelancer ? widget.freelancer?.freelancerNavigation?.location?.locationName : widget.company?.location?.locationName ?? 'Nepoznato'}'),
                  Text('Radno vrijeme: ${isFreelancer ? widget.freelancer?.startTime : widget.company?.startTime} - ${isFreelancer ? widget.freelancer?.endTime : widget.company?.endTime}'),
                ],
              ),
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
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                if (isFreelancer) {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        FreelancerDaySchedule(selectedDay, widget.freelancer!),
                  ));
                } else {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        BookCompanyJob(widget.company!, selectedDay),
                  ));
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
