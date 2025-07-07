import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/tender_bids.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/tender_bid_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/tender_bid.dart';
import 'package:provider/provider.dart';

class TenderBidsScreen extends StatefulWidget {
  const TenderBidsScreen({this.tender, super.key});
  final Job? tender;
  

  @override
  State<TenderBidsScreen> createState() => _TenderBidsScreenState();
}

class _TenderBidsScreenState extends State<TenderBidsScreen> {
  late TenderBidProvider tenderBidProvider;
  late JobProvider jobProvider;
  late PaginatedFetcher<TenderBid> tenderBidFetcher;
  late final ScrollController _scrollController;

  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      jobProvider = context.read<JobProvider>();
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          tenderBidFetcher.hasNextPage &&
          !tenderBidFetcher.isLoading) {
        tenderBidFetcher.loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      tenderBidProvider = context.read<TenderBidProvider>();

      tenderBidFetcher = PaginatedFetcher<TenderBid>(
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
        }) async {
          final result = await tenderBidProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult<TenderBid>(
            result: result.result,
            count: result.count,
          );
        },
        pageSize: 6,
      );

      tenderBidFetcher.addListener(() {
        if (mounted) setState(() {});
      });

      await tenderBidFetcher.refresh(newFilter: {
        'tenderId': widget.tender?.jobId,
      });

      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
   Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white), 
      ),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors. white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenderHeader() {
    final tender = widget.tender;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
            color: Color.fromRGBO(27, 76, 125, 25),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Detalji tendera'),
          
          _buildDetailRow('Posao', tender?.jobTitle ?? 'Nije dostupan'), 
           _buildDetailRow('Potreban', tender?.jobsServices?.map((e) => e.service?.serviceName ?? '').join(' i ') ?? 'Nije dostupan'), 
              _buildDetailRow('Početak radova', formatDateTime(tender?.jobDate)), 
              SizedBox(height: 10),
                 _sectionTitle('Korisnički podaci'),
                  _buildDetailRow('Korisnik', tender?.user?.firstName ?? 'Nije dostupan'), 
                  _buildDetailRow('Lokacija', tender?.user?.location?.locationName ?? 'Nije dostupan'), 
            
                 
                
            
           

                ],
              ),
            ),
        ),
    );
  }
      
  

  Widget _buildBidCard(TenderBid tenderBid) {
    return Card(
      
      surfaceTintColor: const Color.fromRGBO(27, 76, 125, 25),
      color: const Color.fromRGBO(27, 76, 125, 25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${tenderBid.bidAmount} KM',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Radnik: ${tenderBid.freelancer?.freelancerNavigation?.firstName} ${tenderBid.freelancer?.freelancerNavigation?.lastName}' ,  
                style: const TextStyle(fontSize: 15, color: Colors.white)),
                Text('Potrebno: ${tenderBid.bidDescription}' ,  
                style: const TextStyle(fontSize: 15, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Trajanje: ${tenderBid.startEstimate?.substring(0, 5)} - ${tenderBid.endEstimate?.substring(0, 5)}',
                style: const TextStyle(fontSize: 13, color: Colors.white70)),
                if(AuthProvider.user?.userId==tenderBid.job?.user?.userId)
                Center(child:  IconButton(alignment: Alignment.bottomRight, onPressed: (){
                  try{
                    var request ={
                     
                       'jobStatus': JobStatus.approved.name,
                       
                    'endEstimate': tenderBid.endEstimate,
                    'payEstimate': tenderBid.bidAmount,
                    'freelancerId': tenderBid.freelancer?.freelancerId,
                    'startEstimate': tenderBid.startEstimate,
                    'userId':tenderBid.job?.user?.userId,
                    
                    'serviceId': tenderBid.job?.jobsServices
                        ?.map((e) => e.service?.serviceId)
                        .toList(),
                    'jobDescription': tenderBid.bidDescription,
                    'image': tenderBid.job?.image,
                    'jobDate': tenderBid.job?.jobDate.toIso8601String(),
                    
                    'isTenderFinalized': false,
                    'isInvoiced': false,
                    'isRated': false,
                    'jobTitle': tenderBid.job?.jobTitle,
                    };
                  jobProvider.update(tenderBid.jobId!,
                  request);
                  } catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Greška: ${e.toString()}")),
                    );
                  }
             
            }, icon: const Icon(Icons.check),color: Colors.white,),)
           ,
          
          ],
        ),
      ),
      
    );
  }

  void _navigateToBidScreen()  async{
   await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TenderBidScreen(tender: widget.tender),
      ),
      
    );
      await tenderBidFetcher.refresh(newFilter: {
        'tenderId': widget.tender?.jobId,
      });

  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasBids = tenderBidFetcher.items.isNotEmpty;
    final hasUserAlreadyBid = tenderBidFetcher.items.any(
  (bid) => bid.freelancer?.freelancerId == AuthProvider.user?.userId,
);


    return Scaffold(
      appBar: AppBar(title: const Text('Lista ponuda')),
      body: RefreshIndicator(
        onRefresh: tenderBidFetcher.refresh,
        child:
            ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: [
                _buildTenderHeader(),
                if (!hasBids) ...[
              const Center(child: Text("Tender trenutno nema ponuda.", style: TextStyle(fontSize: 16))),
              const SizedBox(height: 12),
              if(AuthProvider.selectedRole == "Freelancer")
              if (!hasUserAlreadyBid)
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(27, 76, 125, 25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                    ),
                    onPressed: _navigateToBidScreen,
                    child: const Text("Napravi ponudu", style: TextStyle(color: Colors.white)),
                  ),
                ),
            ] else ...[
              ...tenderBidFetcher.items.map(_buildBidCard),
              if (tenderBidFetcher.hasNextPage)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 10),
                if(AuthProvider.selectedRole == "Freelancer")
              if (!hasUserAlreadyBid)
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(27, 76, 125, 25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                    ),
                    onPressed: _navigateToBidScreen,
                    child: const Text("Dodaj novu ponudu", style: TextStyle(color: Colors.white)),
                  ),
                ),
            
            
                ]
              ],
            ),
       

      ),
    );
  }
}
