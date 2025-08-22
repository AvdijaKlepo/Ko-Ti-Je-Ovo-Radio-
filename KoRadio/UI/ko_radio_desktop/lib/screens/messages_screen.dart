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
  late SearchResult<Messages> result = SearchResult();
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
      setState(() => isLoading = true);
      messagesProvider = context.read<MessagesProvider>();

      messagesPagination = PaginatedFetcher<Messages>(
        pageSize: 30,
        initialFilter:  {
          'CompanyId': AuthProvider.selectedCompanyId,
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
     if(AuthProvider.selectedCompanyId!=null)
      {
        await messagesPagination.refresh(newFilter: {
          'CompanyId': AuthProvider.selectedCompanyId,
          'OrderBy': 'desc',
        });
      }
      else if(AuthProvider.selectedStoreId!=null)
      {
        await messagesPagination.refresh(newFilter: {
          'StoreId': AuthProvider.selectedStoreId,
          'OrderBy': 'desc',
        });
      }
      else{
        await messagesPagination.refresh(newFilter: {
          'UserId': AuthProvider.user?.userId,
          'OrderBy': 'desc',
        });
      }

    

      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mark all unread as read
            if (messagesPagination.items.isNotEmpty &&
                messagesPagination.items.any((e) => e.isOpened == false))
              Row(
                children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    value: isChecked,
                    onChanged: (bool? value) async {
                      setState(() => isChecked = true);

                      for (var message in messagesPagination.items
                          .where((e) => e.isOpened == false)
                          .toList()) {
                        var request = {
                          'messageId': message.messageId,
                          'message1': message.message1,
                          'userId': AuthProvider.user?.userId,
                          'isOpened': true,
                        };
                        await messagesProvider.update(
                            message.messageId!, request);
                      }

                      setState(() {
                        isChecked = false;
                        isLoading = true;
                      });

                      await messagesPagination.refresh();
                      setState(() => isLoading = false);
                    },
                  ),
                  const Text(
                    'Označi sve vidljive kao pročitano',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),

            // Delete all read messages
            if (messagesPagination.items.isNotEmpty &&
                messagesPagination.items
                    .where((e) => e.isOpened == false)
                    .isEmpty)
              Row(
                children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    value: isChecked,
                    onChanged: (bool? value) async {
                      setState(() => isChecked = true);

                      for (var message in messagesPagination.items
                          .where((e) => e.isOpened == true)) {
                        await messagesProvider.delete(message.messageId!);
                      }

                      setState(() {
                        isChecked = false;
                        isLoading = true;
                      });

                      await messagesPagination.refresh();
                      setState(() => isLoading = false);
                    },
                  ),
                  const Text(
                    'Izbriši sve pročitane notifikacije',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),

            // Message list
            if (messagesPagination.items.isNotEmpty)
              ListView.separated(
                shrinkWrap: true, // important to prevent overflow
                physics:
                    const NeverScrollableScrollPhysics(), // drawer handles scrolling
                separatorBuilder: (context, index) => const Divider(height: 35),
                controller: _scrollController,
                itemCount: messagesPagination.items.length + 
                (messagesPagination.hasNextPage ? 1 : 0),
                itemBuilder: (context, index) {
           
                  final e = messagesPagination.items[index];

                  return Card(
                    color: e.isOpened == true
                        ? const Color(0xFF2E2E2E)
                        : const Color(0xFFFFF3CD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => MessageDetails(messages: e),
                        );
                        await messagesPagination.refresh();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              e.isOpened!
                                  ? Icons.mark_email_read_outlined
                                  : Icons.mark_email_unread_outlined,
                              color: e.isOpened!
                                  ? Colors.white70
                                  : Colors.amber.shade800,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.message1?.split('.').first ?? '',
                                    style: TextStyle(
                                      color: e.isOpened!
                                          ? Colors.white70
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(e.createdAt ?? DateTime.now()),
                                    style: TextStyle(
                                      color: e.isOpened!
                                          ? Colors.white54
                                          : Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            e.isOpened!
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.white54,
                                    onPressed: () async {
                                      await messagesProvider.delete(e.messageId!);
                                      await messagesPagination.refresh();
                                    },
                                    tooltip: 'Obriši poruku',
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Show loading or empty state if no messages
            if (messagesPagination.items.isEmpty)
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[  Center(
                        child: Text(
                          'Nemate notifikacija',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ]
                  ),
          ],
        ),
      ),
    );
  }
}
