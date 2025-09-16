import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Builder(
                    builder: (context) {
                      final imageString = isFreelancer
                          ? freelancer?.freelancerNavigation?.image
                          : company?.image;
        
                      if (imageString != null) {
                        return imageFromString(imageString, height: 100, width: 100);
                      } else if (isFreelancer) {
                        return SizedBox(
                          width: 100,
                          height: 100,
                          child: SvgPicture.asset(
                            "assets/images/undraw_construction-workers_z99i.svg",
                           
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: 100,
                          height: 100,
                          child: SvgPicture.asset(
                            "assets/images/undraw_under-construction_c2y1.svg",
                          
                          ),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        
                        
                        children: [
                         
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.person, size: 18, color: Colors.grey),
                                const SizedBox(width: 4,),
                                Flexible(
                                  child: Text(isFreelancer
                                      ? 'Ime: ${freelancer?.freelancerNavigation?.firstName ?? ''} ${freelancer?.freelancerNavigation?.lastName ?? ''}'
                                      : company?.companyName ?? 'Nepoznata kompanija',style: const TextStyle(fontWeight: FontWeight.bold,),
                                      overflow: TextOverflow.ellipsis,maxLines: 1,
                                  ),
                                )
                              ],
                            ),
                          ),
                          if (isFreelancer)
                            Row(
                              children: [
                                const Icon(Icons.construction, size: 18, color: Colors.grey),
                              const SizedBox(width: 4,),
                              
                                Flexible(child: Text('Iskustvo: ${freelancer?.experianceYears} godine', style: const TextStyle(fontWeight: FontWeight.bold),)),
                              ],
                            ),
                          Row(
                            children: [
                              const Icon(Icons.star_outline, size: 18, color: Colors.grey),
                              const SizedBox(width: 4,),
                              
                              Flexible(child: Text('Ocjena: ${(isFreelancer ? freelancer?.rating : company?.rating) != 0 ? (isFreelancer ? freelancer?.rating.toStringAsFixed(1) : company?.rating.toStringAsFixed(1)).toString() : 'Neocijenjen'}',style: const TextStyle(fontWeight: FontWeight.bold),)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                              const SizedBox(width: 4,),
                              
                              Flexible(child: Text('Lokacija: ${isFreelancer ? freelancer?.freelancerNavigation?.location?.locationName : company?.location?.locationName ?? 'Nepoznato'}',style: const TextStyle(fontWeight: FontWeight.bold),)),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            widget.freelancerId!=null ?
             Text(
              'Radni dani: ${localizeWorkingDays(freelancer?.workingDays).join(', ')}',
              style: const TextStyle(
                color: Color.fromRGBO(27, 76, 125, 25),
                fontWeight: FontWeight.bold,
              ),
            ):
             Text(
              'Radni dani: ${localizeWorkingDays(company?.workingDays).join(', ')}',
              style: const TextStyle(
                color: Color.fromRGBO(27, 76, 125, 25),
                fontWeight: FontWeight.bold,
              ),
            )
            ,
            Text('Radno vrijeme: ${isFreelancer ? freelancer?.startTime.substring(0,5) : company?.startTime.substring(0,5)} - ${isFreelancer ? freelancer?.endTime.substring(0,5) : company?.endTime.substring(0,5)}',
            style: const TextStyle(
                color: Color.fromRGBO(27, 76, 125, 25),
                fontWeight: FontWeight.bold,
              ),),
            Expanded(
              child: TableCalendar(
                locale: 'bs',
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
                   defaultTextStyle: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
            
           
                 
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
  Widget _buildDetailRow(Icon icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$icon:',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors. white),
            ),
          ),
        ],
      ),
    );
  }
}
