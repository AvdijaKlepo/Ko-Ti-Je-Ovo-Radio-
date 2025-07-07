import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/freelancer_details.dart';
import 'package:ko_radio_mobile/screens/service_list.dart';
import 'package:provider/provider.dart';

enum options { Radnici, Firme }

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

  SearchResult<Freelancer>? freelancerResult;
  SearchResult<Location>? locationResult;
  SearchResult<Company>? companyResult;

  List<DropdownMenuItem<int>> locationDropdownItems = [];
  options view = options.Radnici;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      freelancerProvider = context.read<FreelancerProvider>();
      locationProvider = context.read<LocationProvider>();
      companyProvider = context.read<CompanyProvider>();

      await _loadLocations();
      await _loadFreelancers();
      await _loadCompanies();
    });
  }

  Future<void> _loadFreelancers({int? locationId}) async {
    var filter = {
      'ServiceId': widget.serviceId,
      'IsServiceIncluded': true,
      'IsDeleted': false,
      'IsApplicant': false,
    };

    if (locationId != null) {
      filter['LocationId'] = locationId;
    }

    try {
      var fetched = await freelancerProvider.get(filter: filter);
      setState(() => freelancerResult = fetched);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _loadCompanies({int? locationId}) async {
    var filter = {
      'ServiceId': widget.serviceId,
      'isApplicant': false,
      'isDeleted': false,
    };

    if (locationId != null) {
      filter['LocationId'] = locationId;
    }

    try {
      var fetched = await companyProvider.get(filter: filter);
      setState(() => companyResult = fetched);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _loadLocations() async {
    try {
      var fetched = await locationProvider.get();
      setState(() {
        locationResult = fetched;
        locationDropdownItems = fetched.result
                ?.map((l) => DropdownMenuItem(
                      value: l.locationId,
                      child: Text(l.locationName ?? '', style: const TextStyle(color: Colors.white)),
                    ))
                .toList() ??
            [];
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Greška: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        
        title: const Text('Lista servisera'),
    
       
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildFilterCard(),
              const SizedBox(height: 16),
              Expanded(
                child: view == options.Radnici
                    ? _buildFreelancerList()
                    : _buildCompanyList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      color: const Color.fromRGBO(27, 76, 125, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filteri', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<options>(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(20, 60, 100, 1)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      
                    ),
                    segments: const [
                      ButtonSegment(
                        value: options.Radnici,
                        label: Text('Radnici'),
                        icon: Icon(Icons.construction, color: Colors.white),

                      ),
                      ButtonSegment(
                        value: options.Firme,
                        label: Text('Firme'),
                        icon: Icon(Icons.business, color: Colors.white),
                      ),
                    ],
                    selected: {view},
                    onSelectionChanged: (Set<options> newSelection) {
                      setState(() {
                        view = newSelection.first;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    
                    
                    dropdownColor: const Color.fromRGBO(20, 60, 100, 1),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                   
                    ),
                    iconEnabledColor: Colors.white,
                    hint: const Text('Odaberi lokaciju', style: TextStyle(color: Colors.white70)),
                    items: locationDropdownItems,
                    onChanged: (value) {
                      if (value != null) {
                        _loadFreelancers(locationId: value);
                        _loadCompanies(locationId: value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreelancerList() {
    if (freelancerResult == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (freelancerResult!.result.isEmpty) {
      return const Center(child: Text('Nema dostupnih radnika.'));
    }

    return ListView.builder(
      itemCount: freelancerResult!.result.length,
      itemBuilder: (context, index) {
        final f = freelancerResult!.result[index];
        final freelancer = f.freelancerNavigation;
        return Card(
          color: const Color.fromRGBO(240, 245, 255, 1),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: InkWell(
              child: freelancer?.image != null
                  ? imageFromString(freelancer!.image!)
                  : Image.network(
                      "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png",
                      width: 80,
                      height: 80,
                    ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FreelancerDetails(freelancer: f)),
              ),
            ),
            title: Text('${freelancer?.firstName} ${freelancer?.lastName}',
                style: const TextStyle(color: Color.fromRGBO(27, 76, 125, 1), fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Iskustvo: ${f.experianceYears} godina'),
                Text('Ocjena: ${f.rating != 0 ? f.rating : 'Neocijenjen'}'),
                Text('Lokacija: ${freelancer?.location?.locationName ?? '-'}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompanyList() {
    if (companyResult == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (companyResult!.result.isEmpty) {
      return const Center(child: Text('Nema dostupnih firmi.'));
    }

    return ListView.builder(
      itemCount: companyResult!.result.length,
      itemBuilder: (context, index) {
        final c = companyResult!.result[index];
        return Card(
          color: const Color.fromRGBO(240, 245, 255, 1),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FreelancerDetails(company: c)),
              ),
              child: c.image != null
                  ? imageFromString(c.image!)
                  : Image.network(
                      "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png",
                      width: 80,
                      height: 80,
                    ),
            ),
            title: Text(c.companyName ?? '',
                style: const TextStyle(color: Color.fromRGBO(27, 76, 125, 1), fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Iskustvo: ${c.experianceYears} godina'),
                Text('Ocjena: ${c.rating != 0 ? c.rating : 'Neocijenjen'}'),
                Text('Lokacija: ${c.location?.locationName ?? "-"}'),
              ],
            ),
          ),
        );
      },
    );
  }
}