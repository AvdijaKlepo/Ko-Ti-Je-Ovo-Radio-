import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/tender_bids.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/tender_bid_provider.dart';
import 'package:ko_radio_mobile/providers/tender_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/book_tender.dart';
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
  late FreelancerProvider freelancerProvider;
  late PaginatedFetcher<TenderBid> tenderBidFetcher;
  late final ScrollController _scrollController;
  late Set<int> _workingDayInts;
  SearchResult<Freelancer>? freelancerResult;
  SearchResult<Job>? tenderResult;


  bool _isInitialized = false;
  final Map<String, int> _dayStringToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };
  
  @override
  void initState() {
    super.initState();
    jobProvider = context.read<JobProvider>();
    freelancerProvider = context.read<FreelancerProvider>();
       tenderBidProvider = context.read<TenderBidProvider>();
 
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
      await _getTender();
      await _getFreelancer();
      if(freelancerResult?.result.isNotEmpty==true) {
        _workingDayInts = freelancerResult?.result.first.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};
      }

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
      if(mounted) {
        await tenderBidFetcher.refresh(newFilter: {
        'tenderId': widget.tender?.jobId,
      });
      }
      if(!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    });
  }
  bool _isWorkingDay(DateTime day) {
    return _workingDayInts.contains(day.weekday);
  }
  Future<void> _getTender() async{
    var filter = {'JobId': widget.tender?.jobId};
    try{
      var fetchedTender = await jobProvider.get(filter: filter);
      if(!mounted) return;
      setState(() {
        tenderResult = fetchedTender;
      });
    } on Exception catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška tokom dohvaćanja tendera.")),
      );
    }
  }
  
  Future<void> _getFreelancer() async {
    try {
      var fetchedFreelancer = await freelancerProvider.get(filter: {'FreelancerId': AuthProvider.user?.userId});
      if(mounted)
      {
      setState(() {
        freelancerResult = fetchedFreelancer;
      });
      }
    } on Exception catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  String formatPhoneNumber(String phone) {

  String normalized = phone.replaceFirst(RegExp(r'^\+387'), '0');


  normalized = normalized.replaceAll(RegExp(r'\D'), '');


  if (normalized.length < 9) return normalized;


  String part1 = normalized.substring(0, 3);
  String part2 = normalized.substring(3, 6);
  String part3 = normalized.substring(6, 9);

  return "$part1-$part2-$part3";
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
      child: Container(
          width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                 colors: 
                                        [Color.fromRGBO(27, 76, 125, 1),Color(0xFF4A90E2)] ,
                                       
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
               borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
        child: Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Specifikacije tendera'),
            
            _buildDetailRow('Posao', tenderResult?.result.first.jobTitle ?? 'Nije dostupan'), 
             _buildDetailRow('Potreban', tenderResult?.result.first.jobsServices?.map((e) => e.service?.serviceName ?? '').join(' i ') ?? 'Nije dostupan'), 
                _buildDetailRow('Početak radova', formatDateTime(tenderResult?.result.first.jobDate)), 
                _buildDetailRow('Opis', tenderResult?.result.first.jobDescription ?? 'Nije dostupan'),
                tenderResult?.result.first.image!=null ?
                _buildImageRow(
                                    'Slika',
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(context: context, builder: (context) => _openImageDialog(tender));
                                      
                                      
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      child:  const Text(
                                        'Otvori sliku',
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(27, 76, 125, 25)),
                                      ),
                                    ))
                                : _buildDetailRow('Slika','Nije unesena'),
                const SizedBox(height: 10),
                   _sectionTitle('Korisnički podaci'),
                    _buildDetailRow('Korisnik', tenderResult?.result.first.user?.firstName ?? 'Nije dostupan'), 
                    _buildDetailRow('Lokacija', tenderResult?.result.first.user?.location?.locationName ?? 'Nije dostupan'), 
                    _buildDetailRow('Adresa', tenderResult?.result.first.user?.address ?? 'Nije dostupan'), 
                    _buildDetailRow('Telefonski broj',  formatPhoneNumber(tenderResult?.result.first.user?.phoneNumber ?? 'Nije dostupan')),
                    _buildDetailRow('Email adresa',  tenderResult?.result.first.user?.email ?? 'Nije dostupan'),
        
              
                   
                  
          
             if(AuthProvider.selectedRole=="User" && tenderBidFetcher.items.isEmpty)
                const SizedBox(height: 30,),
                    if(AuthProvider.selectedRole=="User" && tenderBidFetcher.items.isEmpty)
        Align(alignment: Alignment.bottomRight,child: ElevatedButton(onPressed: () async{
          await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookTender(tender: tender),
                  ),
                  
                ); 
                await tenderBidFetcher.refresh(newFilter: {
                'tenderId': widget.tender?.jobId,
              });
              await _getTender();
              if(!mounted) return;
              setState(() {
                
              });
        },style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12)),
              ),
              child: const Text(
                'Uredi tender',
                style: TextStyle(color: Colors.black),
              ),
            ),
        ),
        const SizedBox(height: 30,),
        if(AuthProvider.selectedRole=="User")
        Align(alignment: Alignment.bottomRight,child: ElevatedButton(onPressed: () => _deleteTender(),style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12)),
              ),
              child: const Text(
                'Izbriši tender',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ),
                  ],
                ),
              ),
        
          ),
      ),
    );
  }
  void _deleteTender() async {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Izbriši tender?'),
      content: const Text('Jeste li sigurni da želite izbrisati ovaj tender?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
         
          },
          child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),)),
            TextButton(onPressed: () async {
              try{
               await jobProvider.delete(widget.tender!.jobId);
              
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tender je izbrisan')));
             
               Navigator.of(context).pop();
              } on Exception catch (e) {
                if(!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Greška tokom brisanja')));
              }
            Navigator.of(context).pop();
          

            },
            child: const Text("Da",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),)),
      ],
    ));
  }
      
  Widget _buildImageRow(String label, Widget value) {
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
            child: value,
          ),
        ],
      ),
    );
  }
 _openImageDialog(Job? tender) {
    return AlertDialog(
      backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
      title: const Text('Proslijeđena slika',style: TextStyle(color: Colors.white),),
      content: imageFromString(tenderResult?.result.first.image??''),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),))
      ],
    );
  }

Widget _buildBidCard(TenderBid tenderBid) {
  final theme = Theme.of(context);
  final isFreelancerBid = tenderBid.freelancer != null;

  return LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth > 500; 
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isFreelancerBid
                  ? [Colors.indigo.shade700, Colors.indigoAccent.shade200]
                  : [Colors.teal.shade700, Colors.tealAccent.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBidCardContent(tenderBid, theme)),
                    const SizedBox(width: 20),
                    _buildAcceptButton(tenderBid),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBidCardContent(tenderBid, theme),
                    const SizedBox(height: 12),
                    _buildAcceptButton(tenderBid),
                  ],
                ),
        ),
      );
    },
  );
}

Widget _buildBidCardContent(TenderBid tenderBid, ThemeData theme) {
  final isFreelancerBid = tenderBid.freelancer != null;
  final bidderName = isFreelancerBid
      ? '${tenderBid.freelancer?.freelancerNavigation?.firstName} '
        '${tenderBid.freelancer?.freelancerNavigation?.lastName}'
      : tenderBid.company?.companyName;

  final durationText = isFreelancerBid
      ? 'Trajanje: ${tenderBid.startEstimate?.substring(0, 5)} – ${tenderBid.endEstimate?.substring(0, 5)}'
      : 'Trajanje: ${DateFormat('dd.MM.yyyy').format(widget.tender!.jobDate)} '
        'do ${DateFormat('dd.MM.yyyy').format(tenderBid.dateFinished ?? DateTime.now())}';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "${tenderBid.bidAmount} KM",
        style: theme.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Icon(
            isFreelancerBid ? Icons.person : Icons.business,
            color: Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isFreelancerBid ? "Radnik: $bidderName" : "Firma: $bidderName",
              style: const TextStyle(color: Colors.white, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        "Opis: ${tenderBid.bidDescription}",
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      const SizedBox(height: 6),
      if(tenderBid.dateFinished!=null)
       Text(
        "Datum završetka: ${DateFormat.yMMMMd('bs').format(tenderBid.dateFinished!)}",
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      const SizedBox(height: 6),

      Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(durationText,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
      const SizedBox(height: 6),
      if(tenderBid.freelancerId==AuthProvider.user?.userId)
      ElevatedButton(onPressed: () async{
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TenderBidScreen(tenderBid: tenderBid,freelancer: freelancerResult?.result.first,tender: widget.tender,)));
        await tenderBidFetcher.refresh(newFilter: {'TenderId': widget.tender?.jobId});
      },style: ElevatedButton.styleFrom(backgroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
       child: const Text('Uredi ponudu',style: TextStyle(color: Colors.black),),),
        if(tenderBid.freelancerId==AuthProvider.user?.userId)
      const SizedBox(height: 6),
        if(tenderBid.freelancerId==AuthProvider.user?.userId)

      ElevatedButton(onPressed: () async{
        await showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text('Izbriši ponudu?'),
          content: const Text('Jeste li sigurni da želite izbrisati ovu ponudu?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),)),
            TextButton(onPressed: () async {
              Navigator.of(context).pop();
              await tenderBidProvider.delete(tenderBid.tenderBidId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ponuda je izbrisana")),
              );
              tenderBidFetcher.refresh(newFilter: {'TenderId': widget.tender?.jobId});
             
            },
            child: const Text("Da",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),)),
          ],
        ));
      },style: ElevatedButton.styleFrom(backgroundColor: Colors.red,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
       child: const Text('Izbriši ponudu',style: TextStyle(color: Colors.black),),),
     

    ],
  );
}


Widget _buildAcceptButton(TenderBid tenderBid) {
  final canAccept = AuthProvider.selectedRole == "User" &&
      AuthProvider.user?.userId != tenderBid.job?.user?.userId;

  if (!canAccept) {
    return const SizedBox.shrink();
  }


  return Center(
    child: ElevatedButton(
      onPressed: () => _showAcceptDialog(tenderBid),
      child: const Text(
        "Prihvati ponudu",
        style: TextStyle(color: Color.fromRGBO(27, 76, 125, 1)),
      ),
    ),
  );
}

// Unified function to show the accept dialog and handle the logic
Future<void> _showAcceptDialog(TenderBid tenderBid) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Prihvati ponudu?'),
      content: const Text('Jeste li sigurni da želite da prihvatite ovu ponudu?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Nazad", style: TextStyle(color: Color.fromRGBO(27, 76, 125, 1))),
        ),
        TextButton(
          onPressed: () async {
            try {
              final isFreelancerBid = tenderBid.freelancer != null;
              final requestData = isFreelancerBid
                  ? _buildFreelancerRequest(tenderBid)
                  : _buildCompanyRequest(tenderBid);

              await jobProvider.update(tenderBid.jobId!, requestData);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Posao potvrđen!")),
              );
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Greška: ${e.toString()}")),
              );
              Navigator.of(context).pop(false);
              Navigator.of(context).pop(false);
            }
          },
          child: const Text("Potvrdi", style: TextStyle(color: Color.fromRGBO(27, 76, 125, 1))),
        ),
      ],
    ),
  );
}
Map<String, dynamic> _buildFreelancerRequest(TenderBid tenderBid) {
  return {
    'jobStatus': JobStatus.approved.name,
    'endEstimate': tenderBid.endEstimate,
    'payEstimate': tenderBid.bidAmount,
    'dateFinished': tenderBid.dateFinished?.toIso8601String(),
    'freelancerId': tenderBid.freelancer?.freelancerId,
    'startEstimate': tenderBid.startEstimate,
    'userId': tenderBid.job?.user?.userId,
    'serviceId': tenderBid.job?.jobsServices?.map((e) => e.service?.serviceId).toList(),
    'jobDescription': tenderBid.bidDescription,
    'image': tenderBid.job?.image,
    'jobDate': tenderBid.job?.jobDate.toIso8601String(),
    'isTenderFinalized': false,
    'isInvoiced': false,
    'isRated': false,
    'jobTitle': tenderBid.job?.jobTitle,
  };
}


Map<String, dynamic> _buildCompanyRequest(TenderBid tenderBid) {
  return {
    'jobStatus': JobStatus.approved.name,
    'endEstimate': tenderBid.endEstimate,
    
    'payEstimate': tenderBid.bidAmount,
    'freelancerId': null,
    'companyId': tenderBid.company?.companyId,
       'startEstimate': tenderBid.startEstimate,
    'userId': tenderBid.job?.user?.userId,
    'serviceId': tenderBid.job?.jobsServices?.map((e) => e.service?.serviceId).toList(),
    'jobDescription': tenderBid.bidDescription,
    'image': tenderBid.job?.image,
    'jobDate': tenderBid.job?.jobDate.toIso8601String(),
    'dateFinished': tenderBid.dateFinished?.toIso8601String(),
    'isTenderFinalized': false,
    'isInvoiced': false,
    'isRated': false,
    'jobTitle': tenderBid.job?.jobTitle,
  };
}

  void _navigateToBidScreen()  async{
    if(!_isWorkingDay(widget.tender!.jobDate))
    {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Radni dani',),
          content: const Text('Ovaj tender je obajavljen na dan koji ste proglasisi neradnim. Da li ste sigurni da želite nastaviti?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),)),
              TextButton(onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TenderBidScreen(tender: widget.tender,freelancer: freelancerResult?.result.first,),
                  ),
                  
                ); 
                Navigator.of(context).pop();
                  await tenderBidFetcher.refresh(newFilter: {
                    'TenderId': widget.tender?.jobId,
                  });
               
              }, child: const Text("Da"),),
          ],
        ),
      );
    }
    else
    {
      await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TenderBidScreen(tender: widget.tender,freelancer: freelancerResult?.result.first,),
                  ),
                  
                );
                  await tenderBidFetcher.refresh(newFilter: {
                    'tenderId': widget.tender?.jobId,
                  });
    }


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
      appBar: AppBar(title:  Text('Detalji tendera',style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: const Color.fromRGBO(27, 76, 125, 25)),),centerTitle: true,scrolledUnderElevation: 0,),
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
                              backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                    ),
                    onPressed: _navigateToBidScreen,
                    child: const Text("Napravi ponudu", style: TextStyle(color: Colors.white)),
                  ),
                ),
            ] else ...[
               Center(child: Text('Lista ponuda',style:  TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: GoogleFonts.roboto().fontFamily,color: Colors.indigo),)),
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
                              backgroundColor:  Colors.indigoAccent,
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
