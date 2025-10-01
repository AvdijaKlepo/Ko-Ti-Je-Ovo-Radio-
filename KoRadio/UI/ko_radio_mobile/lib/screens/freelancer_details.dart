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
    scrolledUnderElevation: 0.0,
    title: Text(
      'Kalendar ${isFreelancer ? 'radnika' : 'kompanije'}',
      style: GoogleFonts.lobster(
        textStyle: const TextStyle(
          color: Color.fromRGBO(27, 76, 125, 1),
          fontSize: 22,
          
          letterSpacing: 1.2
        ),
        
      ),
    ),
  ),
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) {
                    final imageString = isFreelancer
                        ? freelancer?.freelancerNavigation?.image
                        : company?.image;
            
                    final avatarSize = MediaQuery.of(context).size.width * 0.22;
            
                    if (imageString != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageFromString(imageString,
                            height: avatarSize, width: avatarSize),
                      );
                    } else if (isFreelancer) {
                      return SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: SvgPicture.asset(
                          "assets/images/undraw_construction-workers_z99i.svg",
                          fit: BoxFit.cover,
                        ),
                      );
                    } else {
                      return SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: SvgPicture.asset(
                          "assets/images/undraw_under-construction_c2y1.svg",
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isFreelancer
                                      ? 'Ime: ${freelancer?.freelancerNavigation?.firstName ?? ''} ${freelancer?.freelancerNavigation?.lastName ?? ''}'
                                      : company?.companyName ??
                                          'Nepoznata kompanija',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (isFreelancer) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.construction,
                                    size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Iskustvo: ${freelancer?.experianceYears} godine',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_outline,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ocjena: ${(isFreelancer ? freelancer?.rating : company?.rating) != 0 ? (isFreelancer ? freelancer?.rating.toStringAsFixed(1) : company?.rating.toStringAsFixed(1)).toString() : 'Neocijenjen'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lokacija: ${isFreelancer ? freelancer?.freelancerNavigation?.location?.locationName : company?.location?.locationName ?? 'Nepoznato'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Radni dani: ${(widget.freelancerId != null ? localizeWorkingDays(freelancer?.workingDays) : localizeWorkingDays(company?.workingDays)).join(', ')}',
            style: const TextStyle(
              color: Color.fromRGBO(27, 76, 125, 1),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Radno vrijeme: ${isFreelancer ? freelancer?.startTime.substring(0, 5) : company?.startTime.substring(0, 5)} - ${isFreelancer ? freelancer?.endTime.substring(0, 5) : company?.endTime.substring(0, 5)}',
            style: const TextStyle(
              color: Color.fromRGBO(27, 76, 125, 1),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
   


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
                   defaultTextStyle: const TextStyle(color: Color.fromRGBO(27, 76, 125, 1),fontWeight: FontWeight.bold),
                  

                  
            
           
                 
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
