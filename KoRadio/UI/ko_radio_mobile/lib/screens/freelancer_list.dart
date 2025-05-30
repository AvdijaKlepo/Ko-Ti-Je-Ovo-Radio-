import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/location.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/freelancer_details.dart';
import 'package:provider/provider.dart';

enum options { Radnici, Firme }

class FreelancerList extends StatefulWidget {
  FreelancerList(this.serviceId, {super.key});
  int serviceId;

  @override
  State<FreelancerList> createState() => _FreelancerListState();
}

options view = options.Radnici;

class _FreelancerListState extends State<FreelancerList> {
  late FreelancerProvider freelancerProvider;
  late LocationProvider locationProvider;
  SearchResult<Freelancer>? result;
  SearchResult<Location>? locationResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      freelancerProvider = context.read<FreelancerProvider>();
     
    });
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      locationProvider = context.read<LocationProvider>();
     
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    freelancerProvider = context.read<FreelancerProvider>(); 
    _getServices();

    locationProvider = context.read<LocationProvider>();

    _loadLocations();
  }

  List<DropdownMenuItem<int>> items = [];

  void _loadLocations() async {
    try {
      var fetchedLocations = await locationProvider.get();
      setState(() {
        locationResult = fetchedLocations;
      });

      print("Fetched locations: ${locationResult?.result.map((l) => l.locationName)}");
      items = locationResult?.result
          .map((loc) => DropdownMenuItem(
                value: loc.locationId,
                child: Text(loc.locationName ?? ''),
              ))
          .toList() ??
          [];
    } catch (e) {
      print("Error fetching locations: $e");
      setState(() {});
    }
  }

   Future<void> onChanged(int? value) async {
    if (value != null) {
      var filter = {'LocationId': value};
      var freelancer = await freelancerProvider.get(filter: filter);
      setState(() {
        result = freelancer;
      });
    }
  }

  _getServices() async {
    var filter = {'ServiceId': widget.serviceId,'IsServiceIncluded':true};
    var freelancer = await freelancerProvider.get(filter: filter);
    setState(() {
      result = freelancer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(title: 'Lista radnika', automaticallyImplyLeading: true),body:  SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filteri', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<options>(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 8)),
                        textStyle:
                            MaterialStateProperty.all(TextStyle(fontSize: 14)),
                      ),
                      segments: const <ButtonSegment<options>>[
                        ButtonSegment(
                          value: options.Radnici,
                          label: Text('Radnici'),
                          icon: Icon(Icons.construction),
                        ),
                        ButtonSegment(
                          value: options.Firme,
                          label: Text('Firme'),
                          icon: Icon(Icons.business),
                        ),
                      ],
                      selected: <options>{view},
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
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      hint: Text('Odaberi lokaciju'),
                      items: items,
                      onChanged: onChanged,
                      
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: result?.result.length ?? 0,
            itemBuilder: (context, index) {
              var e = result!.result[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: InkWell(
                    child: e.user.image != null
                        ? SizedBox(
                            width: 80,
                            height: 80,
                            child: imageFromString(e.user.image!),
                          )
                        : Image.network(
                            "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png",
                            width: 80,
                            height: 80,
                          ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FreelancerDetails(e))),
                  ),
                  title: Text('${e.user.firstName} ${e.user.lastName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Iskustvo: ${e.experianceYears} godina'),
                      Text(
                          'Ocjena: ${e.rating != 0 ? e.rating : 'Neocijenjen'}'),
                      Text('Lokacija: ${e.user.location?.locationName}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
));


             

    
  }
}
