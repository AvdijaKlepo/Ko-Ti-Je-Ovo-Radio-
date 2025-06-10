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
  bool _isInitialized = false;

  List<Service> filteredServices = [];
  List<Location> filteredLocations = [];

  String serviceSearch = "";
  String locationSearch = "";

  Timer? _serviceDebounce;
  Timer? _locationDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      serviceProvider = context.read<ServiceProvider>();
      locationProvider = context.read<LocationProvider>();
      servicePagination = PaginatedFetcher<Service>(
    fetcher: ({
      required int page,
      required int pageSize,
      Map<String, dynamic>? filter,
    }) async {
      final result = await serviceProvider.get(
        page: page,
        pageSize: pageSize,
        filter: filter,
      );
      return PaginatedResult<Service>(
        result: result.result,
        count: result.count,
      );
    },
    pageSize: 10,
  );

  servicePagination.refresh(); 
    await _loadData();

    setState(() {
      _isInitialized = true;
    });
    });
  
  }

  Future<void> _loadData() async {
    final servicesResult = await serviceProvider.get();
    final locationsResult = await locationProvider.get();

    setState(() {
      filteredServices = servicesResult.result;
      filteredLocations = locationsResult.result;
    });
  }

  void _onServiceSearchChanged(String query) {
    if (_serviceDebounce?.isActive ?? false) _serviceDebounce!.cancel();
    _serviceDebounce = Timer(const Duration(milliseconds: 300), () async {
      await _searchServices(query);
    });
  }

  Future<void> _searchServices(String query) async {
  final filter = <String, dynamic>{};
  if (query.trim().isNotEmpty) {
    filter['ServiceName'] = query.trim();
  }
  await servicePagination.refresh(newFilter: filter);
}

  void _onLocationSearchChanged(String query) {
    if (_locationDebounce?.isActive ?? false) _locationDebounce!.cancel();
    _locationDebounce = Timer(const Duration(milliseconds: 300), () async {
      await _searchLocations(query);
    });
  }

 Future<void> _searchLocations(String query) async {
  final filter = <String, dynamic>{};

  if (query.trim().isNotEmpty) {
    filter['LocationName'] = query.trim();
  }

  final result = await locationProvider.get(filter: filter);

  setState(() {
    filteredLocations = result.result;
    locationSearch = query;
  });
}

  Future<void> _openServiceDialog({Service? service}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ServiceFormDialog(service: service),

    );
    if (result == true) {
      await _searchServices(serviceSearch); 
    }
  }

  Future<void> _openLocationDialog({Location? location}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => LocationFormDialog(location: location),
    );
    if (result == true) {
      await _searchLocations(locationSearch); 
    }
  }

  @override
  void dispose() {
    _serviceDebounce?.cancel();
    _locationDebounce?.cancel();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  if (!_isInitialized) {
    return const Center(child: CircularProgressIndicator());
  }
  return Padding(
    padding: const EdgeInsets.all(12),
    child: SizedBox(

      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
  
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Search Services",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onServiceSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Service"),
                      onPressed: () => _openServiceDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: servicePagination.items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("No services found."),
                        )
                      : ListView.separated(
                          itemCount: servicePagination.items.length +1,
                          controller: ScrollController(),
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            if(index<servicePagination.items.length){
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
                            }
                           else if (servicePagination.hasNextPage) {
              // Load more trigger
              servicePagination.loadMore();
              return const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const SizedBox.shrink();
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
                // Search + Add
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Search Locations",
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onLocationSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Location"),
                      onPressed: () => _openLocationDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredLocations.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("No locations found."),
                        )
                      : ListView.separated(
                          itemCount: filteredLocations.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final location = filteredLocations[index];
                            return ListTile(
                              title: Text(location.locationName ?? ""),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openLocationDialog(location: location),
                              ),
                              onTap: () => _openLocationDialog(location: location),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}
