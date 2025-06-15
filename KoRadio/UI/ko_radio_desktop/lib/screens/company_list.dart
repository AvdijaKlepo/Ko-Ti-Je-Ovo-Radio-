import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_services.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/screens/company_update_dialog.dart';
import 'package:provider/provider.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({super.key});

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  late CompanyProvider companyProvider;
  SearchResult<Company>? companyResult;

  final TextEditingController _companyNameController = TextEditingController();
  bool showApplicants = false;
  bool showDeleted = false;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      companyProvider = context.read<CompanyProvider>();
      _getCompanies();
    });

  }
  @override
  void dispose() {
    _debounce?.cancel();
    _companyNameController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _getCompanies);
  }

  Future<void> _getCompanies() async {
    final filter = {
 
      'IsApplicant': showApplicants,
      'isDeleted': showDeleted,
    };

    final fetchedCompanies = await companyProvider.get(filter: filter);
    setState(() {
      companyResult = fetchedCompanies;
    });
  }
  final shortDayNamesMap = {
    0: 'Ned',
    1: 'Pon',
    2: 'Uto',
    3: 'Sri',
    4: 'Čet',
    5: 'Pet',
    6: 'Sub',
  };

  List<String> getWorkingDaysShort(List<dynamic>? workingDays) {
    if (workingDays == null) return [];
    return workingDays.map((day) {
      if (day is int) {
        return shortDayNamesMap[day] ?? '';
      } else if (day is String) {
        return day.length > 3 ? day.substring(0, 3) : day;
      }
      return '';
    }).where((e) => e.isNotEmpty).toList();
  }

  void _openUserDeleteDialog({required Company company}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izbriši?'),
        content: Text('Jeste li sigurni da želite izbrisati ovog korisnika?'),
        actions: [
          TextButton(
            onPressed: () async {
              await companyProvider.delete(company.companyId);
              _getCompanies();
              Navigator.of(context).pop(true);
            },
            child: const Text('Da'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
        ],
      ),
    );
  }

  void _openUserRestoreDialog({required Company company}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vrati?'),
        content: Text('Jeste li sigurni da želite vratiti ovog korisnika?'),
        actions: [
          TextButton(
            onPressed: () async {
              await companyProvider.delete(company.companyId);
              _getCompanies();
              Navigator.of(context).pop(true);
            },
            child: const Text('Da'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ime Firme',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Text("Prikaži aplikante"),
                  Switch(
                    value: showApplicants,
                    onChanged: (val) {
                      setState(() => showApplicants = val);
                      _getCompanies();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("Prikaži izbrisane"),
                  Switch(
                    value: showDeleted,
                    onChanged: (val) {
                      setState(() => showDeleted = val);
                      _getCompanies();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(flex: 2, child: Text("Ime", style: TextStyle(fontWeight: FontWeight.bold))),
           
              const Expanded(flex: 3, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 3, child: Text("Lokacija", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 3, child: Text("Radni Dani", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 2, child: Text("Iskustvo", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 2, child: Text("Rating", style: TextStyle(fontWeight: FontWeight.bold))),
              const Expanded(flex: 6, child: Text("Usluge", style: TextStyle(fontWeight: FontWeight.bold))),
              if (!showApplicants && !showDeleted)
                const Expanded(flex: 2, child: Icon(Icons.edit, size: 18)),
              if (!showApplicants && !showDeleted)
                const Expanded(flex: 2, child: Icon(Icons.delete, size: 18)),
              if (showDeleted)
                const Expanded(flex: 2, child: Icon(Icons.restore, size: 18)),
              if (showApplicants)
                const Expanded(flex: 2, child: Text("Akcije", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          Expanded(
            child: companyResult == null
                ? const Center(child: CircularProgressIndicator())
                : companyResult!.result.isEmpty
                    ? const Center(child: Text('No companies found.'))
                    : ListView.separated(
                        itemCount: companyResult!.result.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = companyResult!.result[index];
                          final days = getWorkingDaysShort(c.workingDays);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(c.companyName ?? '')),
                                Expanded(flex: 2, child: Text(c.email ?? '')),
                                Expanded(flex: 3, child: Text(c.phoneNumber ?? '')),
                                Expanded(flex: 3, child: Text(c.location?.locationName ?? '')),
                                Expanded(flex: 3, child: Text(days.join(', '))),
                                Expanded(flex: 2, child: Text(c.experianceYears.toString())),
                                Expanded(flex: 2, child: Text(c.rating?.toStringAsFixed(1) ?? '')),
                                Expanded(
                                  flex: 6,
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: c.companyServices?.map((CompanyServices s) {
                                      return Text(s.service?.serviceName ?? '', style: const TextStyle(fontSize: 12));
                                    }).toList() ?? [],
                                  ),
                                ),
                                if (!showApplicants && !showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Uredi',
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (_) => CompanyUpdateDialog(company: c),
                                        );
                                        _getCompanies();
                                      },
                                    ),
                                  ),
                                if (!showApplicants && !showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Izbriši',
                                      onPressed: () => _openUserDeleteDialog(company: c),
                                    ),
                                  ),
                                if (showDeleted)
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: const Icon(Icons.restore),
                                      tooltip: 'Vrati',
                                      onPressed: () => _openUserRestoreDialog(company: c),
                                    ),
                                  ),
                                if (showApplicants)
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          tooltip: 'Odobri',
                                          onPressed: () async {
                                            final dayMap = {
                                              'Nedjelja': 0, 'Ponedjeljak': 1, 'Utorak': 2, 'Srijeda': 3,
                                              'Četvrtak': 4, 'Petak': 5, 'Subota': 6
                                            };

                                            var workingDaysStringList = c.workingDays as List<String>? ?? [];

                                            final workingDaysIntList = workingDaysStringList
                                                .map((day) => dayMap[day])
                                                .whereType<int>()
                                                .toList();

                                            await companyProvider.update(
                                              c.companyId,
                                              {
                                                "companyName": c.companyName,
                                                "bio": c.bio,
                                                "rating": c.rating,
                                                "phoneNumber": c.phoneNumber,
                                                "experianceYears": c.experianceYears,
                                                "image": c.image,
                                                "startTime": c.startTime,
                                                "endTime": c.endTime,
                                                "workingDays": workingDaysIntList,
                                                "serviceId": c.companyServices?.map((e) => e.serviceId).toList(),
                                                "locationId": c.location?.locationId,
                                                
                                                "isApplicant": false,
                                                "isDeleted": false,
                                                "employee": c.companyEmployees?.map((e) => e.userId).toList(),
                                              },
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Firma odobrena!")),
                                            );
                                            _getCompanies();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          tooltip: 'Odbaci',
                                          onPressed: () async {
                                            // Add rejection logic here
                                          },
                                        ),
                                      ],
                                    ),
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