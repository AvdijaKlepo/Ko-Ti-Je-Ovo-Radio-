import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/freelancer.dart';
import 'package:ko_radio_desktop/models/freelancer_service.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class FreelancerListScreen extends StatefulWidget {
  const FreelancerListScreen({super.key});

  @override
  State<FreelancerListScreen> createState() => _FreelancerListScreenState();
}

class _FreelancerListScreenState extends State<FreelancerListScreen> {
  late FreelancerProvider provider;
  SearchResult<Freelancer>? result;



  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool showApplicants = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = context.read<FreelancerProvider>();
      _getFreelancers();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _getFreelancers();
    });
  }

  Future<void> _getFreelancers() async {
    final filter = {
      'IsServiceIncluded': true,
      'IsApplicant': showApplicants,
    };


    final fetchedUsers = await provider.get(filter: filter);
    setState(() {
      result = fetchedUsers;
    });
  }


final dayNamesMap = {
  0: 'Nedjelja',
  1: 'Ponedjeljak',
  2: 'Utorak',
  3: 'Srijeda',
  4: 'Četvrtak',
  5: 'Petak',
  6: 'Subota',

};

List<String> getWorkingDaysStrings(List<dynamic>? workingDays) {
  if (workingDays == null) return [];
  return workingDays.map((day) {
    if (day is int) {
      return dayNamesMap[day] ?? '';
    } else if (day is String) {
      return day;
    }
    return '';
  }).where((e) => e.isNotEmpty).toList();
}



@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        // Search fields + toggle (unchanged)
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _onSearchChanged(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _onSearchChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                const Text("Show Applicants"),
                Switch(
                  value: showApplicants,
                  onChanged: (val) {
                    setState(() => showApplicants = val);
                    _getFreelancers();
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Headers, all flex values match below
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: const Row(
            children: [
              Expanded(flex: 2, child: Text("Ime",        style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Prezime",    style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Email",      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Lokacija",   style: TextStyle(fontWeight: FontWeight.bold))),

              Expanded(flex: 3, child: Text("Radni Dani", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Iskustvo",   style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Rating",     style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 6, child: Text("Usluge",     style: TextStyle(fontWeight: FontWeight.bold))),
           
              Expanded(flex: 2, child: Text("Akcije",     style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // List
        Expanded(
          child: result == null
              ? const Center(child: CircularProgressIndicator())
              : result!.result.isEmpty
                  ? const Center(child: Text('No freelancers found.'))
                  : ListView.separated(
                      itemCount: result!.result.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final f = result!.result[index];
                        final days = getWorkingDaysStrings(f.workingDays);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(f.freelancerNavigation?.firstName ?? '')),
                              Expanded(flex: 2, child: Text(f.freelancerNavigation?.lastName  ?? '')),
                              Expanded(flex: 3, child: Text(f.freelancerNavigation?.email     ?? '')),
                              Expanded(flex: 3, child: Text(f.freelancerNavigation?.location?.locationName ?? '')),
                           
                          
                              Expanded(flex: 3, child: Text(days.join(', '))),
                              Expanded(flex: 2, child: Text(f.experianceYears.toString())),
                              Expanded(flex: 2, child: Text(f.rating.toStringAsFixed(1))),
                              Expanded(
                                flex: 6,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: f.freelancerServices
                                          ?.map((fs) => Chip(label: Text(fs.service?.serviceName ?? '')))
                                          .toList() ??
                                      [],
                                ),
                              ),

              
                              Expanded(
                                flex: 2,
                                child: showApplicants
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check, color: Colors.green),
                                            onPressed: () async {
                                             final dayMap = {
  'Nedjelja': 0, 'Ponedjeljak': 1, 'Utorak': 2, 'Srijeda': 3,
  'Četvrtak': 4, 'Petak': 5, 'Subota': 6
};

var workingDaysStringList = f.workingDays as List<String>? ?? [];

final workingDaysIntList = workingDaysStringList
    .map((day) => dayMap[day])
    .whereType<int>()
    .toList();
     await provider.update(
  f.freelancerId,
  {
    


    "freelancerId": f.freelancerId,
    "bio": f.bio,
    "rating": f.rating,
    "experianceYears": f.experianceYears,
    "startTime": f.startTime,
    "endTime": f.endTime,
"workingDays": workingDaysIntList,

    "serviceId": f.freelancerServices.map((e) => e.serviceId).toList(), 
    "roles": [10,11],
    "isApplicant": false,
    "isDeleted": false,
    'freelancerNavigation': f.freelancerNavigation,
  });
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Radnik odobren.!")),
    
  );
  _getFreelancers();
                                            },
                                            tooltip: 'Odobri',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () async {
                                              // your existing reject logic here
                                            },
                                            tooltip: 'Odbaci',
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    ),
  );
}

}
