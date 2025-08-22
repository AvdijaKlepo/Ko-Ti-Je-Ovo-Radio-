import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/tender_bids_screen.dart';
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
  final bool _isFreelancer = true;

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




    Map<String, dynamic>? filter;
    
      filter = {'isFreelancer':false,'IsTenderFinalized':true};
    
 

    await tenderFetcher.refresh(newFilter: filter);
    if(!mounted) return;
    setState(() {
      _isInitialized = true;
    });
  });
}
  @override
  Widget build(BuildContext context) {

     if (!_isInitialized) {
    return const Center(child: CircularProgressIndicator());
  }
    return  RefreshIndicator(
  
      onRefresh: tenderFetcher.refresh,
      child: Center(
        child:  ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: tenderFetcher.items.isEmpty
            ?  Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              
                children:   [
                
                 
                  Image.asset('assets/images/tenderNotFound.webp'),
                  const Text("Nema aktivnih tendera. Provjerite kasnije.", style: TextStyle(fontSize: 18)) ,
                  const SizedBox(height: 10,),
                ]
            ):
        
               
            
          
            
            ListView.builder(
            
                controller: _scrollController,
                itemCount: tenderFetcher.items.length + (tenderFetcher.hasNextPage ? 1 : 0),
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  if (index < tenderFetcher.items.length) {
                    final tender = tenderFetcher.items[index];
        
                   return _tenderCard(context, tender);
                  }
        
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
      ),
    ));
  
}

Widget _tenderCard(BuildContext context, Job tender) {
  Map<String, dynamic>? filter;
  return Card(
    color: const Color.fromRGBO(27, 76, 125, 1),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
      //  final updated = showDialog(context: context, builder: (_) => TenderBidsScreen(tender: tender));
      final updated = await Navigator.of(context).push(
    PageRouteBuilder(
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 200),
      opaque: false,
      barrierColor: Colors.black54,
      pageBuilder: (context, _, __) => TenderBidsScreen(tender: tender),
    ),
  );

  filter = {'IsTenderFinalized': true, 'isFreelancer': false};
  if (updated == true) {
    await tenderFetcher.refresh(newFilter: filter);
  } else if (updated == false) {
    setState(() {});
  }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Datum: ${DateFormat('dd‑MM‑yyyy').format(tender.jobDate)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Korisnik: ${tender.user?.firstName} ${tender.user?.lastName}",
                    style: const TextStyle(color: Colors.white),
                  ),
                 Text(
                    "Lokacija: ${tender.user?.location?.locationName}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Adresa: ${tender.user?.address}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Tender: ${tender.jobTitle}",
                    style: const TextStyle(color: Colors.white),
                  ),
                    Text(
                    "Opis: ${tender.jobDescription}",
                    style: const TextStyle(color: Colors.white),
                  ),
                   Text(
                    "Potreban: ${tender.jobsServices?.map((e) => e.service?.serviceName ?? '').join('i ')}",
                    style: const TextStyle(color: Colors.white),
                  ),
                 
                  
                  
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.work_outline, color: Colors.white),
          ],
        ),
      ),
    ),
  );


}
}