import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/tender_bids_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class TenderScreen extends StatefulWidget {
  const TenderScreen({super.key});

  @override
  State<TenderScreen> createState() => _TenderScreenState();
}

class _TenderScreenState extends State<TenderScreen> {
  late JobProvider tenderProvider;
  late LocationProvider   locationProvider;
  late PaginatedFetcher<Job> tenderFetcher;
  SearchResult<Location>? locationResult;
  late final ScrollController _scrollController;
  late final TextEditingController _clientController = TextEditingController();
  List<DropdownMenuItem<int>> locationDropdownItems = [];
  int? _selectedLocationId;

  bool _isInitialized = false;
  bool _isLoading = false;
  Timer? _debounce;
  final bool _isFreelancer = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic> _createFilterMap({DateTime? date}) {

  final Map<String, dynamic> filter = {
    'isFreelancer': false,
    'IsTenderFinalized': true

  };
  

  if (date != null) {
    filter['DateRange'] = date.toIso8601String().split('T')[0];
  } 
  if(_clientController.text.isNotEmpty)
  {
    filter['ClientName'] = _clientController.text;
  }
  if (_selectedLocationId != null) {
      filter['Location'] = _selectedLocationId;
    }
  
 


  return filter;
}
void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isLoading = true;
      });
      
      await tenderFetcher.refresh(newFilter: _createFilterMap());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    });
  }


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          tenderFetcher.hasNextPage &&
          !tenderFetcher.isLoading) {
        tenderFetcher.loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      tenderProvider = context.read<JobProvider>();
      locationProvider = context.read<LocationProvider>();

      tenderFetcher = PaginatedFetcher<Job>(
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
        }) async {
          final result = await tenderProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult<Job>(
            result: result.result,
            count: result.count,
          );
        },
        pageSize: 6,
      );

      tenderFetcher.addListener(() {
        if (mounted) setState(() {});
      });

  
      await tenderFetcher.refresh(newFilter: _createFilterMap());
      await _getLocations();

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    });
  }
  Future<void> _getLocations() async {
    try {
      final fetched = await locationProvider.get();
      if(!mounted) return;
      setState(() {
        locationResult = fetched;
      locationDropdownItems = [
        const DropdownMenuItem(value: null, child: Text("Sve lokacije")),
        ...fetched.result
            .map((l) => DropdownMenuItem(value: l.locationId, child: Text(l.locationName!)))
      ];
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška tokom dohvaćanja lokacija")),
      );
    }
  }
   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (!isSameDay(_selectedDay, normalizedSelectedDay) && mounted) {
      setState(() {
        _selectedDay = normalizedSelectedDay;
        _focusedDay = focusedDay;

        _isLoading = true;
      });
     await tenderFetcher.refresh(newFilter: _createFilterMap(
  date: normalizedSelectedDay,


      ));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
    @override
  void dispose() {
    _scrollController.dispose();
    tenderFetcher.dispose();
    _clientController.dispose();
    _clientController.removeListener(() {_clientController.dispose();});


    super.dispose();
  }
  
  void _clearDateFilter() async {
    setState(() {
      _selectedDay = null;

      _isLoading = true;
    });
    await tenderFetcher.refresh(newFilter:_createFilterMap());
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
   

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 900, minHeight: 600),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Sidebar
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_selectedDay != null )
                            TextButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text('Poništi aktivni filter datuma'),
                            onPressed: (){
                              _clearDateFilter();
                            },
                            ),
                    TableCalendar(
                      shouldFillViewport: false,
                      locale: 'bs',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                           onDaySelected: _onDaySelected,
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
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
                        selectedTextStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Pretraži klijente',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _clientController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        prefixIcon: Icon(Icons.search_outlined),
                        labelText: 'Ime i prezime klijenta',
                      ),
                      onChanged: (value) async {
                        _onSearchChanged();
                      },
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Pretraži po lokaciji',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      hint: const Text(
        'Odaberi lokaciju',
        style: TextStyle(color: Colors.black),
      ),
      
      icon: const Icon(Icons.location_on,color: Color.fromRGBO(27, 76, 125, 25),),
      
      dropdownColor: Colors.white,
      items: locationDropdownItems,
      onChanged: (value) {
        setState(() {
          _selectedLocationId = value;
        });
        _onSearchChanged();
      },
    ),
                  
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 24),
            
 
            // Tenders Grid
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator()) :
              tenderFetcher.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/usersNotFound.webp',
                            width: 250,
                            height: 250,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Nema tendera",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  : 
                   ListView.builder(
                                    controller: _scrollController,
                              
                                    itemCount: tenderFetcher.items.length + (tenderFetcher.hasNextPage ? 1 : 0),
                                    itemBuilder: (context, index) {
                        if (index < tenderFetcher.items.length) {
                          final tender = tenderFetcher.items[index];
                          return _tenderCard(context, tender);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tenderCard(BuildContext context, Job tender) {
    Map<String, dynamic>? filter;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        onTap: () async {
          final updated = await Navigator.of(context).push(
            PageRouteBuilder(
              barrierDismissible: true,
              transitionDuration: const Duration(milliseconds: 200),
              opaque: false,
              barrierColor: Colors.black54,
              pageBuilder: (context, _, __) => TenderBidsScreen(tender: tender),
            ),
          );

          filter = {'IsTenderFinalized': true, 'isFreelancer': false};
          if (updated == true) {
            await tenderFetcher.refresh(newFilter: filter);
          } else if (updated == false) {
            setState(() {});
          }
        },
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B4C7D), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min, // <- add this too for safety
    children: [
      Text(
        tender.jobTitle!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        "Datum: ${DateFormat('dd-MM-yyyy').format(tender.jobDate)}",
        style: const TextStyle(color: Colors.white70),
      ),
      const SizedBox(height: 6),
      Text(
        "Korisnik: ${tender.user?.firstName} ${tender.user?.lastName}",
        style: const TextStyle(color: Colors.white70),
      ),
      const SizedBox(height: 6),
      Text(
        "Lokacija: ${tender.user?.location?.locationName ?? '-'}",
        style: const TextStyle(color: Colors.white70),
      ),
        const SizedBox(height: 12),       Text(
                                        'Potreban servis:  ${tender.jobsServices?.map((e) => e.service?.serviceName ?? '').join(' i ')}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amberAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Tender",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    ],
  ),
),

        ),
      ),
    );
  }
}
