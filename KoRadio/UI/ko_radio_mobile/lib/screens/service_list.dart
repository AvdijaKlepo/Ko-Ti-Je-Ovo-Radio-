import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';

import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/freelancer_list.dart';
import 'package:provider/provider.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  late ServiceProvider serviceProvider;
  late PaginatedFetcher<Service> servicePagination;
  late final ScrollController _scrollController;

  bool _isInitialized = false;
  String _searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();


    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          servicePagination.hasNextPage &&
          !servicePagination.isLoading) {
        servicePagination.loadMore();
      }
    });

 
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      serviceProvider = context.read<ServiceProvider>();

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
        pageSize: 6, 
      );


      servicePagination.addListener(() {
        if (mounted) setState(() {});
      });


      await servicePagination.refresh();
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
      _searchQuery = query.trim();
      _refreshWithFilter();
    });
  }

  Future<void> _refreshWithFilter() async {
    final filter = <String, dynamic>{};
    if (_searchQuery.isNotEmpty) {
      filter['ServiceName'] = _searchQuery;
    }
    await servicePagination.refresh(newFilter: filter);
  }

  Future<void> _openService(Service service) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FreelancerList(service.serviceId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
     
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Pretražite servise...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshWithFilter,
            child: servicePagination.items.isEmpty
                ? ListView(
      
                    children: const [
                      SizedBox(height: 50),
                      Center(child: Text("No services found.")),
                    ],
                  )
                :  Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: servicePagination.items.length + 1,
        itemBuilder: (context, index) {
          if (index < servicePagination.items.length) {
            final service = servicePagination.items[index];
            return service.serviceName != null
                ? InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final height = width * 0.5;
                              return SizedBox(
                                width: width,
                                height: height,
                                child: imageFromString(
                                  service.image!,
                                  width: width,
                                  height: height,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            service.serviceName!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            FreelancerList(service.serviceId),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }

          if (servicePagination.hasNextPage) {
            return const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return const SizedBox.shrink();
        },
      )),
          ),
        ),
      ],
    );
  }
}


