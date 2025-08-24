import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/book_company_job.dart';
import 'package:ko_radio_mobile/screens/freelancer_day_schedule.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class FreelancerDetails extends StatefulWidget {
  final int? freelancerId;
  final int? companyId;

  const FreelancerDetails({super.key, this.freelancerId, this.companyId});

  @override
  State<FreelancerDetails> createState() => _FreelancerDetailsState();
}

class _FreelancerDetailsState extends State<FreelancerDetails> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late Set<int> _workingDayInts;
  late FreelancerProvider freelancerProvider;
  late CompanyProvider companyProvider;

  SearchResult<Freelancer>? _freelancerResult;
  SearchResult<Company>? _companyResult;
  bool _loading = true;

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
    freelancerProvider = context.read<FreelancerProvider>();
    companyProvider = context.read<CompanyProvider>();

    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      if (widget.freelancerId != null) {
        _freelancerResult = await freelancerProvider.get(
          filter: {'FreelancerId': widget.freelancerId},
        );
        if (_freelancerResult!.result.isNotEmpty) {
          _workingDayInts = _freelancerResult!.result.first.workingDays
                  ?.map((day) => _dayStringToInt[day] ?? -1)
                  .where((dayInt) => dayInt != -1)
                  .toSet() ??
              {};
        }
      } else if (widget.companyId != null) {
        _companyResult = await companyProvider.get(
          filter: {'CompanyId': widget.companyId},
        );
        if (_companyResult!.result.isNotEmpty) {
          _workingDayInts = _companyResult!.result.first.workingDays
                  ?.map((day) => _dayStringToInt[day] ?? -1)
                  .where((dayInt) => dayInt != -1)
                  .toSet() ??
              {};
        }
      }

      _focusedDay = _findNextWorkingDay(DateTime.now());
      _selectedDay = _focusedDay;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška tokom dohvaćanja podataka.')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  DateTime _findNextWorkingDay(DateTime start) {
    DateTime candidate = start;
    while (!_isWorkingDay(candidate)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isFreelancer = _freelancerResult != null && _freelancerResult!.result.isNotEmpty;
    final freelancer = isFreelancer ? _freelancerResult!.result.first : null;
    final company = !isFreelancer && _companyResult != null && _companyResult!.result.isNotEmpty
        ? _companyResult!.result.first
        : null;

    if (freelancer == null && company == null) {
      return const Scaffold(
        body: Center(child: Text("Nema rezultata")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Kalendar ${isFreelancer ? 'radnika' : 'kompanije'}',
          style: TextStyle(
            color: const Color.fromRGBO(27, 76, 125, 1),
            fontFamily: GoogleFonts.lobster().fontFamily,
          ),
        ),
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
                        ? freelancer?.freelancerNavigation?.image
                        : company?.image;

                    if (imageString != null) {
                      return imageFromString(imageString, height: 100, width: 100);
                    } else if (isFreelancer) {
                      return SvgPicture.asset(
                        "assets/images/undraw_construction-workers_z99i.svg",
                        width: 100,
                        height: 100,
                      );
                    } else {
                      return SvgPicture.asset(
                        "assets/images/undraw_under-construction_c2y1.svg",
                        width: 100,
                        height: 100,
                      );
                    }
                  },
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isFreelancer
                      ? 'Ime: ${freelancer?.freelancerNavigation?.firstName ?? ''} ${freelancer?.freelancerNavigation?.lastName ?? ''}'
                      : company?.companyName ?? 'Nepoznata kompanija'),
                  if (isFreelancer)
                    Text('Iskustvo: ${freelancer?.experianceYears} godine'),
                  Text('Ocjena: ${(isFreelancer ? freelancer?.rating : company?.rating) != 0 ? (isFreelancer ? freelancer?.rating.toStringAsFixed(1) : company?.rating.toStringAsFixed(1)).toString() : 'Neocijenjen'}'),
                  Text('Lokacija: ${isFreelancer ? freelancer?.freelancerNavigation?.location?.locationName : company?.location?.locationName ?? 'Nepoznato'}'),
                  Text('Radno vrijeme: ${isFreelancer ? freelancer?.startTime.substring(0,5) : company?.startTime.substring(0,5)} - ${isFreelancer ? freelancer?.endTime.substring(0,5) : company?.endTime.substring(0,5)}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Neradni dani radnika su onemogućeni',
            style: TextStyle(
              color: Color.fromRGBO(27, 76, 125, 25),
              fontWeight: FontWeight.bold,
            ),
          ),
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

                if (isFreelancer && freelancer != null) {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FreelancerDaySchedule(selectedDay, freelancer),
                  ));
                } else if (company != null) {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BookCompanyJob(company, selectedDay),
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
                    color: const Color.fromRGBO(27, 76, 125, 1),
                    width: 2,
                  ),
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
