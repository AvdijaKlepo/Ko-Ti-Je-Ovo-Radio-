
import 'package:flutter/material.dart';

import 'package:ko_radio_mobile/models/job.dart';

import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';

import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/book_tender.dart';

import 'package:ko_radio_mobile/screens/tender_bids_screen.dart';
import 'package:provider/provider.dart';

class TenderScreen extends StatefulWidget {
  const TenderScreen({super.key});

  @override
  State<TenderScreen> createState() => _TenderScreenState();
}

class _TenderScreenState extends State<TenderScreen> {
  late JobProvider tenderProvider;
  late PaginatedFetcher<Job> tenderFetcher;
  late final ScrollController _scrollController;

  bool _isInitialized = false;
  bool _isFreelancer = true;

 @override
void initState() {
  super.initState();
  _scrollController = ScrollController();
  _scrollController.addListener(() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        tenderFetcher.hasNextPage &&
        !tenderFetcher.isLoading) {
      tenderFetcher.loadMore();
    }
  });

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    tenderProvider = context.read<JobProvider>();

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

    final selectedRole = AuthProvider.selectedRole;


    Map<String, dynamic>? filter;
    if (selectedRole != "Freelancer") {
      filter = {'userId': AuthProvider.user?.userId,'IsTenderFinalized':true};
    }
    else{
      filter = {'IsTenderFinalized':true,'isFreelancer':true};
    }

    await tenderFetcher.refresh(newFilter: filter);

    setState(() {
      _isInitialized = true;
    });
  });
}



 @override
Widget build(BuildContext context) {
  final selectedRole = AuthProvider.selectedRole;
  Map<String, dynamic>? filter;
    if (selectedRole != "Freelancer") {
      filter = {'userId': AuthProvider.user?.userId,'IsTenderFinalized':true};
    }
    else{
      filter = {'IsTenderFinalized':true,'isFreelancer':true};
    }
  if (!_isInitialized) {
    return const Center(child: CircularProgressIndicator());
  }

  return  RefreshIndicator(
  
      onRefresh: tenderFetcher.refresh,
      child: tenderFetcher.items.isEmpty
          ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
         
            


            
              children:  [

              
                const SizedBox(height: 10),
                AuthProvider.selectedRole== "User" ? 
                const Center(child: Text("Nemate aktivan tender", style: TextStyle(fontSize: 18))):
               const Center(child: Text("Trenutno nema aktivnih tendera", style: TextStyle(fontSize: 18))) ,
                const SizedBox(height: 10,),

                AuthProvider.selectedRole == "User" ?
                Column(
                
                  children: [
                    const SizedBox(height: 15,),
                    ElevatedButton(
                    
                      style: ElevatedButton.styleFrom(backgroundColor:const Color.fromRGBO(27, 76, 125, 25)),
                      onPressed: () {
                       AlertDialog alert = AlertDialog(
                       
                      title: const Text("Kreiraj tender"),
                      content: const Text("Stranka?",style: TextStyle(fontSize: 16),),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); 
                            _isFreelancer = true;
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BookTender(isFreelancer: _isFreelancer),
                              ),
                            );
                            await tenderFetcher.refresh(newFilter: filter); 
                          },
                          child: const Text("Radnik"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); 
                            _isFreelancer = false;
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BookTender(isFreelancer: _isFreelancer),
                              ),
                            );
                            await tenderFetcher.refresh(newFilter: filter);
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
                      child: const Text("Kreiraj tender",style: TextStyle(color: Colors.white),),
                    
                    ),
                  ],
                ): const SizedBox.shrink(),

              ],
            )
          : 
        
          
          ListView.builder(
          
              controller: _scrollController,
              itemCount: tenderFetcher.items.length + (tenderFetcher.hasNextPage ? 1 : 0),
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                if (index < tenderFetcher.items.length) {
                  final tender = tenderFetcher.items[index];

                  return Card(

                    color: const Color.fromRGBO(27, 76, 125, 25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                    final updated = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TenderBidsScreen(tender: tender)));
                     
                      if (selectedRole != "Freelancer") {
      filter = {'userId': AuthProvider.user?.userId,'IsTenderFinalized':true};
    }
    else{
      filter = {'IsTenderFinalized':true,'isFreelancer':true};
    }
    if(updated==true){
      await tenderFetcher.refresh(newFilter: filter);
    }
    else if(updated==false){
      setState(() {
        
      });
    }
                      

  
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Naslov:  ${tender.jobTitle}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
                            Text(
                              'Korisnik:  ${tender.user?.firstName} ${tender.user?.lastName}' ?? "",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text('Potreban:  ${tender.jobsServices?.map((e) => e.service?.serviceName ?? '').join('i ')}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(
                              "Početak radova:  ${formatDateTime(tender.jobDate)}",
                              style: const TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
    );
  
}

  }
