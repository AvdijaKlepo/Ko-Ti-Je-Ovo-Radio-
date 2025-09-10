import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/book_company_job.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CompanyJob extends StatefulWidget {
  const CompanyJob({super.key});

  @override
  State<CompanyJob> createState() => _CompanyJobState();
}

class _CompanyJobState extends State<CompanyJob> {
  late JobProvider jobProvider;
  late PaginatedFetcher<Job> jobsPagination;
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  
  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Job>> jobsByDate = {};
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final List<JobStatus> _jobStatuses = [
    JobStatus.finished,
    JobStatus.approved,
    JobStatus.unapproved,
    JobStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    jobProvider = context.read<JobProvider>();
    jobsPagination = PaginatedFetcher<Job>(
      pageSize: 10,
      initialFilter: _createFilterMap(_jobStatuses[_selectedIndex]),
      fetcher: ({
        required int page,
        required int pageSize,
        Map<String, dynamic>? filter,
      }) async {
        final result = await jobProvider.get(
          page: page,
          pageSize: pageSize,
          filter: filter,
        );
        return PaginatedResult(result: result.result, count: result.count);
      },
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
          jobsPagination.hasNextPage && !jobsPagination.isLoading) {
        jobsPagination.loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await jobsPagination.refresh();
      await _loadAllJobsForCalendar();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  Future<void> _loadAllJobsForCalendar() async {
    final allJobs = await jobProvider.get(filter: {
      'CompanyId': AuthProvider.selectedCompanyId,
      'isTenderFinalized': false,
      'isDeleted': false,
    });
    if (!mounted) return;
    setState(() {
      jobsByDate.clear();
      for (var job in allJobs.result) {
        final day = DateTime(job.jobDate.year, job.jobDate.month, job.jobDate.day);
        jobsByDate.putIfAbsent(day, () => []).add(job);
      }
    });
  }

Map<String, dynamic> _createFilterMap(JobStatus status, {DateTime? date}) {
  final Map<String, dynamic> filter = {
    'CompanyId': AuthProvider.selectedCompanyId,
    'isTenderFinalized': false,
    'OrderBy': 'desc',
    'isDeleted': false,
  };

  if (date != null) {
    filter['DateRange'] = date.toIso8601String().split('T')[0];
  } else {
    filter['JobStatus'] = status.name;
  }

  return filter;
}

  @override
  void dispose() {
    _scrollController.dispose();
    jobsPagination.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    String normalized = phone.replaceFirst(RegExp(r'^\+387'), '0').replaceAll(RegExp(r'\D'), '');
    if (normalized.length < 9) return normalized;
    return "${normalized.substring(0, 3)}-${normalized.substring(3, 6)}-${normalized.substring(6, 9)}";
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {
      setState(() {
        _selectedDay = normalizedSelectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        _isLoading = true;
      });
     await jobsPagination.refresh(newFilter: _createFilterMap(
  _jobStatuses[_selectedIndex],
  date: normalizedSelectedDay,


      ));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) async {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _isLoading = true;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      // The backend doesn't support a date range, so we'll treat the selection
      // as the last day of the range.
      await jobsPagination.refresh(newFilter: _createFilterMap(
        _jobStatuses[_selectedIndex],
        date: end,
      ));
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearDateFilter() async {
    setState(() {
      _selectedDay = null;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
      _isLoading = true;
    });
    await jobsPagination.refresh(newFilter: _createFilterMap(_jobStatuses[_selectedIndex]));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _jobStatuses.length,
      initialIndex: _selectedIndex,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    TabBar(
                      onTap: (index) async {
                        setState(() {
                          _selectedIndex = index;
                          _isLoading = true;
                          _selectedDay = null;
                          _rangeStart = null;
                          _rangeEnd = null;
                          _rangeSelectionMode = RangeSelectionMode.toggledOff;
                        });
                        await jobsPagination.refresh(newFilter: _createFilterMap(_jobStatuses[_selectedIndex]));
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      indicatorColor: const Color.fromRGBO(27, 76, 125, 1),
                      labelColor: const Color.fromRGBO(27, 76, 125, 1),
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(icon: Icon(Icons.check_circle), text: 'Završeni'),
                        Tab(icon: Icon(Icons.hourglass_top), text: 'Odobreni'),
                        Tab(icon: Icon(Icons.free_cancellation), text: 'Zahtjevi'),
                        Tab(icon: Icon(Icons.cancel), text: 'Otkazani'),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TableCalendar(
                      shouldFillViewport: false,
                      locale: 'bs',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: _onDaySelected,
                      onRangeSelected: _onRangeSelected,
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      rangeSelectionMode: _rangeSelectionMode,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mjesec',
                        CalendarFormat.week: 'Sedmica',
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                      ),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Color.fromRGBO(27, 76, 125, 0.2),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color.fromRGBO(27, 76, 125, 1),
                          shape: BoxShape.circle,
                        ),
                        rangeStartDecoration: BoxDecoration(
                          color: Color.fromRGBO(27, 76, 125, 1),
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: BoxDecoration(
                          color: Color.fromRGBO(27, 76, 125, 1),
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: TextStyle(color: Colors.white),
                      ),
                      eventLoader: (day) {
                        final normalized = DateTime(day.year, day.month, day.day);
                        return jobsByDate[normalized] ?? [];
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              bottom: 1,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${events.length}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ukupan broj poslova: ${jobsPagination.count}', style: Theme.of(context).textTheme.titleMedium),
                        if (_selectedDay != null || _rangeStart != null)
                          TextButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text('Poništi filter datuma'),
                            onPressed: _clearDateFilter,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : jobsPagination.items.isEmpty
                              ? const Center(child: Text('Nema poslova za prikaz.'))
                              : ListView.builder(
                                  controller: _scrollController,
                                  itemCount: jobsPagination.items.length + (jobsPagination.hasNextPage ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index < jobsPagination.items.length) {
                                      final job = jobsPagination.items[index];
                                      return _jobCard(context, job);
                                    }
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jobCard(BuildContext context, Job job) {
    return Card(
      color: job.isEdited == false || job.isWorkerEdited == false ? const Color.fromRGBO(27, 76, 125, 1) : Colors.amber,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await showDialog(context: context, builder: (_) => BookCompanyJobPage(job: job));
          await jobsPagination.refresh(newFilter: _createFilterMap(_jobStatuses[_selectedIndex]));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.work_outline, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Datum: ',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        children: [
                          TextSpan(
                            text: DateFormat('dd.MM.yyyy.').format(job.jobDate),
                            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Korisnik: ${job.user?.firstName} ${job.user?.lastName}', style: const TextStyle(color: Colors.white)),
                    Text('Telefon: ${_formatPhoneNumber(job.user!.phoneNumber!)}', style: const TextStyle(color: Colors.white)),
                    Text('Adresa: ${job.user?.address}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Posao: ',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        children: [
                          TextSpan(
                            text: job.jobTitle,
                            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Text('Opis: ${job.jobDescription}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: job.isInvoiced == true ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        job.isInvoiced == true ? 'Plaćen' : 'Nije plaćen',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}