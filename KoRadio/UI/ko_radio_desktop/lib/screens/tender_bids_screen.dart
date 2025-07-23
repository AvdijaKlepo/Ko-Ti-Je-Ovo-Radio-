import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/tender_bids.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/tender_bid_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/tender_bid_screen.dart';
import 'package:provider/provider.dart';

class TenderBidsScreen extends StatefulWidget {
  const TenderBidsScreen({required this.tender,super.key});
  final Job tender;

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
        'tenderId': widget.tender.jobId,
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
             _buildDetailRow('Opis', tender?.jobDescription ?? 'Nije dostupan'), 
              _buildDetailRow('Početak radova', DateFormat('dd‑MM‑yyyy').format(tender.jobDate )),
              const SizedBox(height: 10),
                 _sectionTitle('Korisnički podaci'),
                  _buildDetailRow('Korisnik', tender?.user?.firstName ?? 'Nije dostupan'), 
                  _buildDetailRow('Lokacija', tender?.user?.location?.locationName ?? 'Nije dostupan'), 
                  _buildDetailRow('Adresa', tender?.user?.address ?? 'Nije dostupan'), 
            
                 
                
            
           

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
            Text('Firma: ${tenderBid.company?.companyName}' ,  
                style: const TextStyle(fontSize: 15, color: Colors.white)),
                Text('Potrebno: ${tenderBid.bidDescription}' ,  
                style: const TextStyle(fontSize: 15, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Trajanje: ${DateFormat('dd‑MM‑yyyy').format(widget.tender.jobDate)} do ${DateFormat('dd‑MM‑yyyy').format(tenderBid.dateFinished ?? DateTime.now())}',
                style: const TextStyle(fontSize: 13, color: Colors.white70),

               
           
            ),
          ],
        ),
      ),
      
    );
  }

  void _navigateToBidScreen()  async{
    await showDialog(context: context, builder: (_) => TenderBidScreen(tender: widget.tender));

   
      
    
      await tenderBidFetcher.refresh(newFilter: {
        'tenderId': widget.tender.jobId,
      });

  }
  @override
  Widget build(BuildContext context) {
     if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasBids = tenderBidFetcher.items.isNotEmpty;
    final hasCompanyAlreadyBid = tenderBidFetcher.items.any(
  (bid) => bid.company?.companyId == AuthProvider.selectedCompanyId,
);
    return
    Padding(padding: const EdgeInsets.only(left: 1800),
    child:
     Scaffold(
      
      
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Text('Detalji tendera'),
        centerTitle: true,
      ),
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
            
              if (!hasCompanyAlreadyBid)
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
              Center(child: Text('Lista ponuda',style:  TextStyle(fontSize: 20, fontFamily: GoogleFonts.roboto().fontFamily,color: Color.fromRGBO(27, 76, 125, 25)),)),
              ...tenderBidFetcher.items.map(_buildBidCard),
              if (tenderBidFetcher.hasNextPage)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 10),
               
              if (!hasCompanyAlreadyBid)
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
    ));
  }
}