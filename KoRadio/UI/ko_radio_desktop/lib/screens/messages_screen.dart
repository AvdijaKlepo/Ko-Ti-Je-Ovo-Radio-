import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/messages.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/messages_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/message_details.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({this.companyId, this.storeId, super.key});
  final int? companyId;
  final int? storeId;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late MessagesProvider messagesProvider;
  late PaginatedFetcher<Messages> messagesPagination;
  late SearchResult<Messages>? messagesResult;
  bool _isInitialized = false;
  bool isChecked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      messagesProvider = context.read<MessagesProvider>();

      messagesPagination = PaginatedFetcher<Messages>(
        pageSize: 30,
        initialFilter: widget.companyId != null
            ? {'CompanyId': widget.companyId, 'OrderBy': 'desc'}
            : widget.storeId != null
                ? {'StoreId': widget.storeId, 'OrderBy': 'desc'}
                : {'UserId': AuthProvider.user?.userId, 'OrderBy': 'desc'},
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
       var filter;
      if(AuthProvider.selectedCompanyId!=null)
      {
        filter = {'CompanyId': AuthProvider.selectedCompanyId, 'OrderBy': 'desc'};
      }
      else if(AuthProvider.selectedStoreId!=null)
      {
        filter = {'StoreId': AuthProvider.selectedStoreId, 'OrderBy': 'desc'};
      }
      else{
        filter = {'UserId': AuthProvider.user?.userId, 'OrderBy': 'desc'};
      }
      await messagesPagination.refresh(newFilter: filter);
      await _getNotifications();
    

     
      setState(() => _isInitialized = true);
    });
  }
  Future<void> _getNotifications() async {
    Map<String, dynamic>? filter;
    if(AuthProvider.selectedCompanyId!=null)
    {
      filter = {'CompanyId': AuthProvider.selectedCompanyId, 'OrderBy': 'desc'};
    }
    else if(AuthProvider.selectedStoreId!=null)
    {
      filter = {'StoreId': AuthProvider.selectedStoreId, 'OrderBy': 'desc'};
    }
    else{
      filter = {'UserId': AuthProvider.user?.userId, 'OrderBy': 'desc'};
    }
    try {
      var fetched = await messagesProvider.get(filter: filter);
      if(!mounted) return;
      setState(() => messagesResult = fetched);
    } catch (e) {
      if(!mounted) return;
     
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Center(child: CircularProgressIndicator());


    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [

            if (messagesPagination.items.isNotEmpty &&
                messagesPagination.items.any((e) => e.isOpened == false))
              Row(
                children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    value: isChecked,
                    onChanged: (bool? value) async {
                      final message = ScaffoldMessenger.of(context);
                      setState(() => isChecked = true);
        
                      for (var message in messagesResult!.result
                          .where((e) => e.isOpened == false)
                          .toList()) {
                        var request = {
                        
                          'isOpened': true,
                        };
                        await messagesProvider.update(
                            message.messageId!, request);
                      }
        
                      setState(() => isLoading = true);
                      await messagesPagination.refresh(
                        newFilter: widget.companyId != null
                            ? {'CompanyId': widget.companyId, 'OrderBy': 'desc'}
                            : widget.storeId != null
                                ? {'StoreId': widget.storeId, 'OrderBy': 'desc'}
                                : {'UserId': AuthProvider.user?.userId, 'OrderBy': 'desc'},
                      );
                      await _getNotifications();
                      setState(() {
                        isChecked = false;
                        isLoading = false;
                      });
                      message.showSnackBar(const SnackBar(content: Text('Notifikacije su označene kao pročitane.')));
                    },
                  ),
                  const Text(
                    'Označi sve notifikacije kao pročitane',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
        
   
            if (messagesPagination.items.isNotEmpty &&
                messagesPagination.items
                    .where((e) => e.isOpened == false)
                    .isEmpty)
              Row(
                children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    value: isChecked,
                    onChanged: (bool? value) async {
                      final message = ScaffoldMessenger.of(context);
                      setState(() => isChecked = true);
        
                      for (var message in messagesResult!.result
                          .where((e) => e.isOpened == true)) {
                        await messagesProvider.delete(message.messageId!);
                      }
        
                      setState(() => isLoading = true);
                      await messagesPagination.refresh(
                        newFilter: widget.companyId != null
                            ? {'CompanyId': widget.companyId, 'OrderBy': 'desc'}
                            : widget.storeId != null
                                ? {'StoreId': widget.storeId, 'OrderBy': 'desc'}
                                : {'UserId': AuthProvider.user?.userId, 'OrderBy': 'desc'},
                      );
                      setState(() {
                        isChecked = false;
                        isLoading = false;
                      });
                      message.showSnackBar(const SnackBar(content: Text('Notifikacije su izbrisane.')));
                    },
                  ),
                  const Text(
                    'Izbriši sve pročitane notifikacije',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
        
  
            ...messagesPagination.items.map((e) {
              return Card(
                color: e.isOpened! ? const Color(0xFF2E2E2E) : const Color(0xFFFFF3CD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => MessageDetails(messages: e),
                    );
                    await messagesPagination.refresh(newFilter: widget.companyId != null
            ? {'CompanyId': widget.companyId, 'OrderBy': 'desc'}
            : widget.storeId != null
                ? {'StoreId': widget.storeId, 'OrderBy': 'desc'}
                : {'UserId': AuthProvider.user?.userId, 'OrderBy': 'desc'} );
                await _getNotifications();
                  },

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          e.isOpened!
                              ? Icons.mark_email_read_outlined
                              : Icons.mark_email_unread_outlined,
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
                                DateFormat('dd-MM-yyyy')
                                    .format(e.createdAt ?? DateTime.now()),
                                style: TextStyle(
                                  color: e.isOpened! ? Colors.white54 : Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (e.isOpened!)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.white54,
                            onPressed: () async {
                              final message = ScaffoldMessenger.of(context);
                              await messagesProvider.delete(e.messageId!);
                              await messagesPagination.refresh(
                                newFilter: widget.companyId != null
                                    ? {'CompanyId': widget.companyId, 'OrderBy': 'desc'}
                                    : widget.storeId != null
                                        ? {'StoreId': widget.storeId, 'OrderBy': 'desc'}
                                        : {'UserId': AuthProvider.user?.userId, 'OrderBy': 'desc'},
                              );
                              await _getNotifications();
                              message.showSnackBar(const SnackBar(content: Text('Notifikacija je obrisana.')));
                            },
                            tooltip: 'Obriši notifikaciju.',
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        
  
            if (messagesPagination.items.isEmpty)
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Center(
                      child: Text(
                        'Nemate notifikacija',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
