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
  final TextEditingController _searchController = TextEditingController();


  bool _isInitialized = false;
  String _searchQuery = "";
  Timer? _debounce;
  Map<String, dynamic> filter = {};
  bool _isLoading = false;

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
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() {
        _isLoading=true;
      });
      _searchQuery = query.trim();
      await _refreshWithFilter();

      setState(() {
        _isLoading=false;
      });
   
    });
  }

  Future<void> _refreshWithFilter() async {
    final filter = <String, dynamic>{};
    if (_searchQuery.isNotEmpty) {
      filter['ServiceName'] = _searchQuery;
    }
    await servicePagination.refresh(newFilter: filter);
  }

  

  @override
  Widget build(BuildContext context) {

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }



    return Column(
      children: [
     


      
        SearchBar(controller: _searchController, onChanged: _onSearchChanged),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshWithFilter,
            child: _isLoading
            
              ? const Center(child: CircularProgressIndicator())
              : servicePagination.items.isEmpty
              
                  ? ListView(
                      children: const [
                        SizedBox(height: 50),
                        Center(child: Text("Servis nije pronađen")),
                      ],
                    )
             
                  :
      ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: servicePagination.items.length + 1,
        itemBuilder: (context, index)  {
          if (index < servicePagination.items.length) {
            final service = servicePagination.items[index];
        
            return 
                 InkWell(
                 hoverColor: Colors.transparent,
                    child: Card(
                     color: Colors.white,
                     surfaceTintColor: Colors.transparent,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
 aspectRatio: 16 / 9,
                                      child: service.image != null
                                          ? imageFromString(
                                              service.image,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/images/intro-1660762097.jpg',
                                              fit: BoxFit.cover,
                                              
                                            ),
                        
                          ),
                          Padding(padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text(
                                service.serviceName,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Row(
                                children: [
                                  
                                  Text(
                                    'Radnika : ${service.freelancerCount}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Firma : ${service.companyCount}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                    await  Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            FreelancerList(service.serviceId),
                      ),
                    );
                    }
          
                  );
         
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
        
      ],
    );
  }
}


class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Pretražite servise...",
          prefixIcon: const Icon(Icons.search, color: Color.fromRGBO(27, 76, 125, 1)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}


