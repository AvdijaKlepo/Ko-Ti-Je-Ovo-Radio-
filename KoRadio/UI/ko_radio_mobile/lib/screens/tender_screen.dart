import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/models/tender_bids.dart';

import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/tender_bid_provider.dart';

import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/book_tender.dart';
import 'package:ko_radio_mobile/screens/tender_bid.dart';
import 'package:ko_radio_mobile/screens/tender_bids_screen.dart';
import 'package:provider/provider.dart';

class TenderScreen extends StatefulWidget {
  const TenderScreen({super.key});

  @override
  State<TenderScreen> createState() => _TenderScreenState();
}

class _TenderScreenState extends State<TenderScreen> {
  late JobProvider tenderProvider;
  late TenderBidProvider tenderBidProvider;
  late PaginatedFetcher<Job> tenderFetcher;
  late ServiceProvider serviceProvider;
  SearchResult<Service>? serviceResult;
  SearchResult<TenderBid>? tenderBidResult;
  var tenderBids;

  List<DropdownMenuItem<int?>> serviceDropdownItems = [];
  int? _selectedServiceId;

  late final ScrollController _scrollController;
  bool _isInitialized = false;
  bool _isFreelancer = true;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 100 &&
            tenderFetcher.hasNextPage &&
            !tenderFetcher.isLoading) {
          tenderFetcher.loadMore();
        }
      });

    tenderProvider = context.read<JobProvider>();
    serviceProvider = context.read<ServiceProvider>();
    tenderBidProvider = context.read<TenderBidProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(!mounted) return;
      await _getServices();
      await _getTenderBids();
   

      tenderFetcher = PaginatedFetcher<Job>(
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
        }) async {
          final result = await tenderProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult<Job>(
            result: result.result,
            count: result.count,
          );
        },
        pageSize: 6,
      );

      tenderFetcher.addListener(() {
        if (mounted) setState(() {});
      });
      final filter = <String, dynamic>{
      'IsTenderFinalized': true,
      if (AuthProvider.selectedRole != "Freelancer")
        'UserId': AuthProvider.user?.userId
      else
        'IsFreelancer': true,
    };

      await tenderFetcher.refresh(newFilter: filter);
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    });
  }

  Future<void> _getServices() async {
  
    try {
      var fetchedServices = await serviceProvider.get();
      if(!mounted) return;
      setState(() {
        serviceResult = fetchedServices;
        serviceDropdownItems = [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text("Svi tipovi"),
          ),
          ...fetchedServices.result
              .map((s) => DropdownMenuItem<int?>(
                  value: s.serviceId, child: Text(s.serviceName)))
        ];
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  Future<void> _getTenderBids() async {
    try {
    
      final result = await tenderBidProvider.get();
      if (!mounted) return;
      setState(() {
        tenderBidResult = result;

  
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }

    
    

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _refreshWithFilter);
  }

  Future<void> _refreshWithFilter() async {
    if(!mounted) return;
    setState(() => _isLoading = true);


    final filter = <String, dynamic>{
      'IsTenderFinalized': true,
      if (AuthProvider.selectedRole != "Freelancer")
        'UserId': AuthProvider.user?.userId
      else
        'IsFreelancer': true,
    };

    if (_selectedServiceId != null) {
      filter['JobService'] = _selectedServiceId;
    }
    
    await tenderFetcher.refresh(newFilter: filter);
    if(!mounted) return;
    setState(() => _isLoading = false);
  }

  Widget _buildServiceDropdown() {
    if (AuthProvider.selectedRole!="Freelancer") return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: DropdownButtonFormField<int?>(
        iconDisabledColor: Colors.grey,
        iconEnabledColor: const Color.fromRGBO(27, 76, 125, 25),
        value: _selectedServiceId,
        decoration: InputDecoration(
          labelText: "Tip servisa",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: serviceDropdownItems,
        onChanged: (value) {
          setState(() => _selectedServiceId = value);
          _refreshWithFilter();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if(_isLoading) return const Center(child: CircularProgressIndicator());
   var filterOutLoggedInFreelancer = AuthProvider.selectedRole == "Freelancer"
    ? tenderFetcher.items.where((e) => e.user?.userId != AuthProvider.user?.userId).toList()
    : tenderFetcher.items; 


    

    final selectedRole = AuthProvider.selectedRole;

    return RefreshIndicator(
      onRefresh: tenderFetcher.refresh,
      child: filterOutLoggedInFreelancer.isEmpty
          ? Column(
           mainAxisAlignment: tenderFetcher.items.isEmpty && AuthProvider.selectedRole=="User" ? MainAxisAlignment.center
           : MainAxisAlignment.start,
              
              children: [
                  _buildServiceDropdown(),
           
                
                const SizedBox(height: 10),
                selectedRole == "User"
                    ? const Center(
                        child: Text("Nemate aktivan tender",
                            style: TextStyle(fontSize: 18)))
                    : const Center(
                        child: Text("Nema aktivnih tendera",
                            style: TextStyle(fontSize: 18))),
                const SizedBox(height: 10),
                if (selectedRole == "User")
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(27, 76, 125, 25),
                        ),
                        onPressed: () {
                          final alert = AlertDialog(
                            title: const Text("Kreiraj tender"),
                            content: const Text("Stranka?",
                                style: TextStyle(fontSize: 16)),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  _isFreelancer = true;
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookTender(isFreelancer: _isFreelancer),
                                    ),
                                  );
                                  await _refreshWithFilter();
                                },
                                child: const Text("Radnik"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  _isFreelancer = false;
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookTender(isFreelancer: _isFreelancer),
                                    ),
                                  );
                                  await _refreshWithFilter();
                                },
                                child: const Text("Firma"),
                              ),
                            ],
                          );

                          showDialog(
                            context: context,
                            builder: (context) => alert,
                          );
                        },
                        child: const Text(
                          "Kreiraj tender",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
              ],
            )
          : Column(
       
              children: [
                if(AuthProvider.selectedRole=="User")
                const Text('Vaši trenutno aktivni tenderi',style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),),
              _buildServiceDropdown(),
               Expanded(
  child: ListView.builder(
    controller: _scrollController,
    itemCount: tenderFetcher.items.length +
        (tenderFetcher.hasNextPage ? 1 : 0) +
        (AuthProvider.selectedRole == "User" ? 1 : 0),
    padding: const EdgeInsets.all(16),
    itemBuilder: (context, index) {
      if (index < tenderFetcher.items.length) {
        final tender = filterOutLoggedInFreelancer[index];

        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (context)=> TenderBidsScreen(tender: tender)));
            tenderFetcher.refresh(newFilter: {
      'IsTenderFinalized': true,
      if (AuthProvider.selectedRole != "Freelancer")
        'UserId': AuthProvider.user?.userId
      else
        'IsFreelancer': true,
    });
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.transparent,
            shadowColor: Colors.black45,
            elevation: 3,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(27, 76, 125, 1), Color(0xFF4A90E2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: tender.user?.image!=null ? imageFromString(
                        tender.user!.image!,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ) : Image.asset('assets/images/user.png',height: 40,width: 40,fit: BoxFit.cover,),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Naslov: ${tender.jobTitle}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'Korisnik: ${tender.user?.firstName} ${tender.user?.lastName}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Potreban servis: ${tender.jobsServices?.map((e) => e.service?.serviceName ?? '').join(' i ')}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Početak radova: ${formatDateTime(tender.jobDate)}",
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amberAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tender',
                            style: TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }


      if (index == tenderFetcher.items.length && tenderFetcher.hasNextPage) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (AuthProvider.selectedRole == "User" &&
          index == tenderFetcher.items.length +
              (tenderFetcher.hasNextPage ? 1 : 0)) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final alert = AlertDialog(
                title: const Text("Kreiraj tender"),
                content: const Text("Stranka?",
                    style: TextStyle(fontSize: 16)),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      _isFreelancer = true;
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              BookTender(isFreelancer: _isFreelancer),
                        ),
                      );
                      await _refreshWithFilter();
                    },
                    child: const Text("Radnik"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      _isFreelancer = false;
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              BookTender(isFreelancer: _isFreelancer),
                        ),
                      );
                      await _refreshWithFilter();
                    },
                    child: const Text("Firma"),
                  ),
                ],
              );

              showDialog(
                context: context,
                builder: (context) => alert,
              );
            },
            child: const Text(
              "Objavi novi tender",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    },
  ),
),

              ],
            ),
    );
  }
}
