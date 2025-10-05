import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/messages.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/messages_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/message_details.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, this.user});
  final User? user;


  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late MessagesProvider messagesProvider;
  late PaginatedFetcher<Messages> messagesPagination;
  late SearchResult<Messages> result =SearchResult();
  late final ScrollController _scrollController;

  bool _isInitialized = false;
  bool isChecked = false;
  bool isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          messagesPagination.hasNextPage &&
          !messagesPagination.isLoading) {
        messagesPagination.loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading=true;
      });
    messagesProvider = context.read<MessagesProvider>();
     messagesPagination = PaginatedFetcher<Messages>(
        pageSize: 6,
        initialFilter: {
         'UserId': AuthProvider.user?.userId ?? 0,
         'OrderBy': 'desc',
        },
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
        }) async {
          final result = await messagesProvider.get(
            page: page,
            pageSize: pageSize,
            filter: filter,
          );
          return PaginatedResult(result: result.result, count: result.count);
        },
      )..addListener(() => setState(() {}));
  

     _fetchData();
      await messagesPagination.refresh(
        newFilter: {
          'UserId': AuthProvider.user?.userId ?? 0,
         'OrderBy': 'desc',
        }
      );
      setState(() {
        _isInitialized = true;
        isLoading=false;
      });

   
    });
   

  }
    Future<void> _refreshWithFilter() async {
    setState(() {
      isLoading=true;
    });
    final filter = <String, dynamic>{};

    filter['OrderBy'] = 'desc';
    
    

  
    await messagesPagination.refresh(newFilter: filter);
    setState(() {
      isLoading=false;
    });
  }
   Future<void> _fetchData() async {
    setState(() {
      isLoading=true;
    });
    var filter = {'UserId': AuthProvider.user?.userId ?? 0,'OrderBy':'desc'};
    try {
  final messages = await messagesProvider.get(filter: filter,orderBy: 'desc');
  if(!mounted) return;
  setState(() {
    result = messages;
    isLoading=false;
  });
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Greška: $e')),
  );
}
  }
 

  @override
  Widget build(BuildContext context) {
    

   
    return  Scaffold(

      
      appBar: AppBar(scrolledUnderElevation: 0,title:  Text("Notifikacije",style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: const Color.fromRGBO(27, 76, 125, 25),letterSpacing: 1.2),),
      centerTitle: true,
      ),
      
      body: !_isInitialized ? const Center(child: CircularProgressIndicator()) :
      isLoading ? const Center(child: CircularProgressIndicator()) 
      
       : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [ 
           if (messagesPagination.items.isNotEmpty &&
    messagesPagination.items.any((element) => element.isOpened == false))

  SizedBox(
    width: double.maxFinite,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
     
     crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Checkbox(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          value: isChecked,
          onChanged: (bool? value) async {
            final message = ScaffoldMessenger.of(context);
            setState(() {
              isChecked = true;
            });
    
            for (var message
                in result.result.where((e) => e.isOpened == false).toList()) {
    
                
              var request = {
             
                
                'isOpened': true,
              };
              await messagesProvider.update(message.messageId!, request);
            }
              setState(() {
                        isChecked = false;
                        isLoading=true;
                      });
            await messagesPagination.refresh(newFilter: {
              'UserId': AuthProvider.user?.userId ?? 0,
         'OrderBy': 'desc',
            });
            await _fetchData();
    
            setState(() {
              isLoading=false;  
            });
            message.showSnackBar(
              const SnackBar(content: Text("Notifikacije označene kao pročitane.")),
            );
         
          },
        ),
        const Text(
          'Označi sve notifikacije kao pročitane',
          style: TextStyle(color: Colors.black),
        ),
      ],
    ),
  ),
  messagesPagination.items.where((e) => e.isOpened == false).isEmpty
  && messagesPagination.items.isNotEmpty
   ?
   SizedBox(
    width: double.maxFinite,
     child: Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Checkbox(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          value: isChecked,
          onChanged: (bool? value) async {
            final message = ScaffoldMessenger.of(context);
            setState(() {
              isChecked = true;
            });
     
            for (var message
                in result.result.where((e) => e.isOpened == true)) {
              
              await messagesProvider.delete(message.messageId!);
            }
            
            setState(() {
              isChecked = false;
              isLoading=true;
            });
     
           
            await messagesPagination.refresh(
              newFilter: {
                'UserId': AuthProvider.user?.userId ?? 0,
         'OrderBy': 'desc',
              }
            );
     
     
            setState(() {
              isLoading=false;
            });
            message.showSnackBar(
              const SnackBar(content: Text("Notifikacije izbrisane.")),
            );
            
          },
        ),
        const Text(
          'Izbriši sve pročitane notifikacije',
          style: TextStyle(color: Colors.black),
        ),
      ],
       ),
   ) : const SizedBox.shrink(),

              Expanded(
                child:
              (messagesPagination.items.isEmpty)
              ? isLoading ? const Center(child: CircularProgressIndicator()) : const Center(
                child: 
         
                
                    Text('Nemate notifikacija',style: TextStyle(color: Colors.black,fontSize: 20),),
            
              ) : 
                
                
                 ListView.separated(
                  separatorBuilder: (context, index) => const Divider(height: 35),
                  controller: _scrollController,
                  itemCount: messagesPagination.items.length
                  + (messagesPagination.hasNextPage ? 1 : 0),
                  itemBuilder: (context, index) {

                

                    if(index < messagesPagination.items.length){
                
                   


                    final e = messagesPagination.items[index];

                    
                   
                    return Card(
  color: e.isOpened == true ? const Color(0xFF2E2E2E) : const Color(0xFFFFF3CD), 
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 3,
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () async {
      await showDialog(context: context, builder: (_) => MessageDetails(messages: e));
      await messagesPagination.refresh();
      await _fetchData();
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
   
          Icon(
            e.isOpened! ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
            color: e.isOpened! ? Colors.white70 : Colors.amber.shade800,
          ),
          const SizedBox(width: 12),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.message1!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: e.isOpened! ? Colors.white70 : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd-MM-yyyy').format(e.createdAt ?? DateTime.now()),
                  style: TextStyle(
                    color: e.isOpened! ? Colors.white54 : Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          e.isOpened! ?  
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: e.isOpened! ? Colors.white54 : Colors.redAccent,
            onPressed: () async {
              final message = ScaffoldMessenger.of(context);
              try {
  await messagesProvider.delete(e.messageId!);
  await messagesPagination.refresh();
  await _fetchData();
  message.showSnackBar(
    const SnackBar(content: Text("Notifikacija obrisana.")),
  );
} on Exception catch (e) {
  message.showSnackBar(
    const SnackBar(content: Text('Greška tokom brisanja notifikacije. Pokušajte ponovo.')),
  );
}
            },
            tooltip: 'Obriši poruku',
          ):const SizedBox.shrink(),
        ],
      ),
    ),
  ),
);

                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}