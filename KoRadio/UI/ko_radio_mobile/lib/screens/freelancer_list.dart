import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/freelancer_details.dart';
import 'package:provider/provider.dart';

enum Options { radnici, firme }

class FreelancerList extends StatefulWidget {
  final int serviceId;

  const FreelancerList(this.serviceId, {super.key});

  @override
  State<FreelancerList> createState() => _FreelancerListState();
}

class _FreelancerListState extends State<FreelancerList> {
  late FreelancerProvider freelancerProvider;
  late LocationProvider locationProvider;
  late CompanyProvider companyProvider;
  final ScrollController _scrollController = ScrollController();

  PaginatedFetcher<Freelancer>? freelancerPagination;
  PaginatedFetcher<Company>? companyPagination;

  SearchResult<Location>? locationResult;
  List<DropdownMenuItem<int>> locationDropdownItems = [];

  Options view = Options.radnici;
  bool _isInitialized = false;
  String _searchQuery = "";
  int? _selectedLocationId;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      freelancerProvider = context.read<FreelancerProvider>();
      locationProvider = context.read<LocationProvider>();
      companyProvider = context.read<CompanyProvider>();

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
          if (view == Options.radnici &&
              freelancerPagination != null &&
              freelancerPagination!.hasNextPage &&
              !freelancerPagination!.isLoading) {
            freelancerPagination!.loadMore();
          } else if (view == Options.firme &&
              companyPagination != null &&
              companyPagination!.hasNextPage &&
              !companyPagination!.isLoading) {
            companyPagination!.loadMore();
          }
        }
      });

      freelancerPagination = PaginatedFetcher<Freelancer>(
        pageSize: 5,
        initialFilter: {
          'ServiceId': widget.serviceId,
          'IsDeleted': false,
          'IsApplicant': false,
        },
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
        }) async {
          final result = await freelancerProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));

      companyPagination = PaginatedFetcher<Company>(
        pageSize: 10,
        initialFilter: {
          'ServiceId': widget.serviceId,
          'isDeleted': false,
          'isApplicant': false,
        },
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
        }) async {
          final result = await companyProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));

      await freelancerPagination!.refresh();
      await companyPagination!.refresh();
      await _loadLocations();

      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.trim();
      });
      _refreshWithFilter();
    });
  }

  Future<void> _refreshWithFilter() async {
    final filter = <String, dynamic>{
      'ServiceId': widget.serviceId,
      'IsDeleted': false,
      'IsApplicant': false,
    };

    if (_searchQuery.isNotEmpty && view == Options.radnici) {
      filter['FirstNameGTE'] = _searchQuery;
    }
    if (_searchQuery.isNotEmpty && view == Options.firme) {
      filter['CompanyName'] = _searchQuery;
    }

    if (_selectedLocationId != null) {
      filter['LocationId'] = _selectedLocationId;
    }

    if (view == Options.radnici) {
      await freelancerPagination?.refresh(newFilter: filter);
    } else {
      await companyPagination?.refresh(newFilter: filter);
    }
  }

  Future<void> _loadLocations() async {
    try {
      final fetched = await locationProvider.get();
      locationResult = fetched;
      locationDropdownItems = [
        const DropdownMenuItem(value: null, child: Text("Sve lokacije")),
        ...fetched.result
            .map((l) => DropdownMenuItem(value: l.locationId, child: Text(l.locationName)))
      ];
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Greška: $message')));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Lista servisera',
          style: TextStyle(
            color: const Color.fromRGBO(27, 76, 125, 1),
            fontFamily: GoogleFonts.lobster().fontFamily,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SegmentedButton<Options>(
              showSelectedIcon: false,
              emptySelectionAllowed: false,
              style: ButtonStyle(
                backgroundColor:MaterialStateProperty.resolveWith<Color>(
   (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)){
        return const Color.fromRGBO(27, 76, 125, 25);
      }
      return Colors.white;
    },
 ),
                
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
   (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)){
        return Colors.white;
      }
      return Colors.black;
    },
 ),
              ),
              segments: const [
                ButtonSegment(

                    value: Options.radnici,
                    label: Text('Radnici'),
                    icon: Icon(Icons.construction)),
                ButtonSegment(
                    value: Options.firme,
                    label: Text('Firme'),
                    icon: Icon(Icons.business)),
              ],

              selected: {view},
              onSelectionChanged: (Set<Options> newSelection) {

                setState(() => view = newSelection.first);
                _refreshWithFilter();
              },
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText:
                    view == Options.radnici ? 'Pretraži radnike...' : 'Pretraži firme...',
                prefixIcon:  const Icon(Icons.search,color: Color.fromRGBO(27, 76, 125, 25)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            _buildFilterCard(),
           Expanded(
  child: RefreshIndicator(
    onRefresh: _refreshWithFilter,
    child: Builder(
      builder: (context) {
        if ((freelancerPagination?.items.isEmpty ?? true) &&
            (view == Options.radnici)) {
          return ListView(
            children: const [
              SizedBox(height: 50),
              Center(child: Text("Nema rezultata za tu lokaciju.")),
            ],
          );
        } else if ((companyPagination?.items.isEmpty ?? true) &&
            (view == Options.firme)) {
          return ListView(
            children: const [
              SizedBox(height: 50),
              Center(child: Text("Nema rezultata za tu lokaciju.")),
            ],
          );
        } else {
          return view == Options.radnici
              ? _buildFreelancerList()
              : _buildCompanyList();
        }
      },
    ),
  ),
),

          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return DropdownButtonFormField<int>(
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
        _refreshWithFilter();
      },
    );
  }

  Widget _buildFreelancerList() {
    final items = freelancerPagination?.items ?? [];
    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length +
          (freelancerPagination?.hasNextPage ?? false ? 1 : 0),
      itemBuilder: (context, index) {
         if(freelancerPagination?.items.isEmpty ?? true) return const Text('Nema prijavljenih radnika u ovom zanatu');
        if (index < items.length) {
          final f = items[index];
          final freelancer = f.freelancerNavigation;
         
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              tileColor: const Color.fromRGBO(27, 76, 125, 25),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Container(
    width: 80,
    height: 80,
    color: Colors.white, 
    child: freelancer?.image != null
      ? imageFromString(freelancer!.image!, height: 80, width: 80, fit: BoxFit.cover)
      : SvgPicture.asset(
          "assets/images/undraw_construction-workers_z99i.svg",
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
  ),
),
               
              title: Text('${freelancer?.firstName} ${freelancer?.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Iskustvo: ${f.experianceYears} godina',style: TextStyle(color: Colors.white),),
                  Text('Ocjena: ${f.rating != 0 ? f.rating : 'Neocijenjen'}',style: TextStyle(color: Colors.white),),
                  Text('Lokacija: ${freelancer?.location?.locationName ?? '-'}',style: TextStyle(color: Colors.white),),
                 
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FreelancerDetails(freelancer: f)),
              ),
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildCompanyList() {
    final items = companyPagination?.items ?? [];
    return ListView.builder(
      controller: _scrollController,
      itemCount:
          items.length + (companyPagination?.hasNextPage ?? false ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          final c = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              tileColor: Color.fromRGBO(27, 76, 125, 25),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Container(
    width: 80,
    height: 80,
    color: Colors.white, // Optional: ensures good contrast regardless of image transparency
    child: c.image != null
      ? imageFromString(c!.image!, height: 80, width: 80, fit: BoxFit.cover)
      : SvgPicture.asset(
          "assets/images/undraw_under-construction_c2y1.svg",
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
  ),
),
              title: Text(c.companyName ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Iskustvo: ${c.experianceYears} godina',style: TextStyle(color: Colors.white),),
                  Text('Ocjena: ${c.rating != 0 ? c.rating : 'Neocijenjen'}',style: TextStyle(color: Colors.white),),
                  Text('Lokacija: ${c.location?.locationName ?? '-'}',style: TextStyle(color: Colors.white),),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FreelancerDetails(company: c)),
              ),
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
