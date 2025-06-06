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
      await _loadData();
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

  final result = await serviceProvider.get(filter: filter);

  setState(() {
    // Show filtered or full list depending on search query
    filteredServices = result.result;
    serviceSearch = query;
  });
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
      await _searchServices(serviceSearch); // refresh with current filter
    }
  }

  Future<void> _openLocationDialog({Location? location}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => LocationFormDialog(location: location),
    );
    if (result == true) {
      await _searchLocations(locationSearch); // refresh with current filter
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
  return Padding(
    padding: const EdgeInsets.all(12),
    child: SizedBox(
       // fixed height or flexible as needed
      child: Row(
        children: [
          // SERVICES COLUMN
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
                  child: filteredServices.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("No services found."),
                        )
                      : ListView.separated(
                          itemCount: filteredServices.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
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
