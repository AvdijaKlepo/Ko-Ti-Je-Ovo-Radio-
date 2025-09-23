import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/location_dialog.dart';
import 'package:ko_radio_desktop/screens/service_form_dialog.dart';
import 'package:provider/provider.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  late ServiceProvider serviceProvider;
  late LocationProvider locationProvider;

  late PaginatedFetcher<Service> servicePagination;
  late PaginatedFetcher<Location> locationPagination;

  late ScrollController _serviceScrollController;
  late ScrollController _locationScrollController;

  bool _isInitialized = false;

  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();

  Timer? _serviceDebounce;
  Timer? _locationDebounce;

  @override
  void initState() {
    super.initState();

    _serviceScrollController = ScrollController();
    _locationScrollController = ScrollController();

    _serviceScrollController.addListener(() {
      if (_serviceScrollController.position.pixels >=
              _serviceScrollController.position.maxScrollExtent - 100 &&
          servicePagination.hasNextPage &&
          !servicePagination.isLoading) {
        servicePagination.loadMore();
      }
    });

    _locationScrollController.addListener(() {
      if (_locationScrollController.position.pixels >=
              _locationScrollController.position.maxScrollExtent - 100 &&
          locationPagination.hasNextPage &&
          !locationPagination.isLoading) {
        locationPagination.loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      serviceProvider = context.read<ServiceProvider>();
      locationProvider = context.read<LocationProvider>();

      servicePagination = PaginatedFetcher<Service>(
        pageSize: 20,
        fetcher: ({required page, required pageSize, filter}) async {
          final result = await serviceProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));

      locationPagination = PaginatedFetcher<Location>(
        pageSize: 20,
        fetcher: ({required page, required pageSize, filter}) async {
          final result = await locationProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));
      if(mounted) {
      await Future.wait([
        servicePagination.refresh(),
        locationPagination.refresh(),
      ]);
      }

      setState(() => _isInitialized = true);
    });
  }

  void _onServiceSearchChanged(String query) {
    if (_serviceDebounce?.isActive ?? false) _serviceDebounce!.cancel();
    _serviceDebounce = Timer(const Duration(milliseconds: 300), () async {
      final filter = <String, dynamic>{};
      if (_serviceNameController.text.trim().isNotEmpty) {
        filter['ServiceName'] = _serviceNameController.text.trim();
      }
      await servicePagination.refresh(newFilter: filter);
    });
  }

  void _onLocationSearchChanged(String query) {
    if (_locationDebounce?.isActive ?? false) _locationDebounce!.cancel();
    _locationDebounce = Timer(const Duration(milliseconds: 300), () async {
      final filter = <String, dynamic>{};
      if (_locationNameController.text.trim().isNotEmpty) {
        filter['LocationName'] = _locationNameController.text.trim();
      }
      await locationPagination.refresh(newFilter: filter);
    });
  }

  Future<void> _openServiceDialog({Service? service}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ServiceFormDialog(service: service),
    );
    if (result == true) {
      _onServiceSearchChanged(_serviceNameController.text);
    }
  }

  Future<void> _openLocationDialog({Location? location}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => LocationFormDialog(location: location),
    );
    if (result == true) {
      _onLocationSearchChanged(_locationNameController.text);
    }
  }

  @override
  void dispose() {
    _serviceDebounce?.cancel();
    _locationDebounce?.cancel();
    _serviceNameController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
      
          Expanded(
            child: Column(
              
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _serviceNameController,
                        decoration: const InputDecoration(
                          labelText: "Pretraži usluge",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onServiceSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4C7D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Dodaj uslugu", style: TextStyle(color: Colors.white)),
                      onPressed: () => _openServiceDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: servicePagination.isLoading && servicePagination.items.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : servicePagination.items.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text("Usluga nije pronađena."),
                            )
                          : ListView.separated(
                              controller: _serviceScrollController,
                              itemCount: servicePagination.items.length +
                                  (servicePagination.hasNextPage ? 1 : 0),
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                if (index < servicePagination.items.length) {
                                  final service = servicePagination.items[index];
                                  return ListTile(
  title: Text(service.serviceName ?? ""),
  leading: service.image != null
      ? SizedBox(
          width: 50,
          height: 50,
          child: imageFromString(service.image!),
        )
      : const Icon(Icons.miscellaneous_services, size: 30),
  trailing: Row(

    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.edit, size: 24),
        tooltip: 'Uredi',
        onPressed: () => _openServiceDialog(service: service),
      ),
      // Use SizedBox for consistent spacing between icons.
      const SizedBox(width: 8), 
      IconButton(
        icon: const Icon(Icons.delete, size: 24),
        tooltip: 'Obriši',
        onPressed: () async {
          showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Obriši?'),
            content: const Text('Jeste li sigurni da želite obrisati ovu uslugu?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Ne'),
              ),
              TextButton(
                onPressed: () async {
                  final message = ScaffoldMessenger.of(context);
                  final back = Navigator.of(context);
                  try {
                    await serviceProvider.delete(service.serviceId);
                    await servicePagination.refresh(newFilter: {
                  
                    });
                   message.showSnackBar(
                      const SnackBar(content: Text("Usluga je uspješno obrisana.")),
                    );
                  } on UserException catch (e) {
                    message.showSnackBar(
                       SnackBar(content: Text(e.exMessage)),
                    );
                  }
                  
                   on Exception catch (e) {
                    message.showSnackBar(
                      const SnackBar(content: Text("Greška tokom brisanja podataka. Pokušajte ponovo.")),
                    );
                  }
                  back.pop();
                },
                child: const Text('Da'),
              ),
            ],
          ));
          
        },
      ),
    ],
  ),
  onTap: () => _openServiceDialog(service: service),
);
                                } else {
                                  // loader for pagination
                                  servicePagination.loadMore();
                                  return const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                              },
                            ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

      
          Expanded(
            child: Column(
          
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _locationNameController,
                        decoration: const InputDecoration(
                          labelText: "Pretraži lokacije",
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onLocationSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4C7D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Dodaj lokaciju", style: TextStyle(color: Colors.white)),
                      onPressed: () => _openLocationDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: locationPagination.isLoading && locationPagination.items.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : locationPagination.items.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text("Lokacija nije pronađena."),
                            )
                          : ListView.separated(
                              controller: _locationScrollController,
                              itemCount: locationPagination.items.length +
                                  (locationPagination.hasNextPage ? 1 : 0),
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                if (index < locationPagination.items.length) {
                                  final location = locationPagination.items[index];
                                  return ListTile(
  title: Text(location.locationName ?? ""),
  
  trailing: Row(

    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.edit, size: 24),
        tooltip: 'Uredi',
        onPressed: () => _openLocationDialog(location: location),
      ),
      // Use SizedBox for consistent spacing between icons.
      const SizedBox(width: 8), 
      IconButton(
        icon: const Icon(Icons.delete, size: 24),
        tooltip: 'Obriši',
        onPressed: () async {
          showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Obriši?'),
            content: const Text('Jeste li sigurni da želite obrisati ovu lokaciju?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Ne'),
              ),
              TextButton(
                onPressed: () async {
                  final message = ScaffoldMessenger.of(context);
                  final back = Navigator.of(context);
                  try {
                    await locationProvider.delete(location.locationId!);
                    await locationPagination.refresh(newFilter: {
                  
                    });
                   message.showSnackBar(
                      const SnackBar(content: Text("Lokacija je uspješno obrisana.")),
                    );
                  } on UserException catch (e) {
                    message.showSnackBar(
                       SnackBar(content: Text(e.exMessage)),
                    );
                  }
                  
                   on Exception catch (e) {
                    message.showSnackBar(
                      const SnackBar(content: Text("Greška tokom brisanja podataka. Pokušajte ponovo.")),
                    );
                  }
                  back.pop();
                },
                child: const Text('Da'),
              ),
            ],
          ));
          
        },
      ),
    ],
  ),
  onTap: () => _openLocationDialog(location: location),
);
                                } else {
                                  locationPagination.loadMore();
                                  return const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
