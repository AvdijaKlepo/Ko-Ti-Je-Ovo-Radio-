import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/service.dart';
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
          // SERVICES COLUMN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
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
                                        : const Icon(Icons.miscellaneous_services),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _openServiceDialog(service: service),
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

          // LOCATIONS COLUMN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
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
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _openLocationDialog(location: location),
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
