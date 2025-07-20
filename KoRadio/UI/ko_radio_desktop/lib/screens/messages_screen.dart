import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/messages.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/messages_provider.dart';
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
  SearchResult<Messages>? result;
  @override
  void initState() {
    super.initState();
    messagesProvider = context.read<MessagesProvider>();
    _fetchData();

  }
   Future<void> _fetchData() async {
    Map<String, dynamic> filter = {};
    if(widget.companyId!=null)
    {
      filter = {'CompanyId' : widget.companyId};
    }
    if(widget.storeId!=null)
    {
      filter = {'StoreId' : widget.storeId};
    }
  try {
  final messages = await messagesProvider.get(filter: filter);
  if(!mounted) return;
  setState(() {
    result = messages;
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
      appBar: AppBar(title: const Text("Poruke")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: result?.result.length ?? 0,
                  itemBuilder: (context, index) {
                    var e = result!.result[index];
                    return Card(
                      color: e.isOpened == true ? const Color.fromRGBO(27, 76, 125, 25) : Colors.grey.shade100,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        onTap: () async { 
                        //  await Navigator.of(context).push(MaterialPageRoute(builder: (_) =>  MessageDetails(messages: e,)));
                          setState(() {
                            _fetchData();
                          });
                         },

                        leading: Text(e.message1.toString().split('.')[0],style: TextStyle(color: e.isOpened == true ? Colors.white : Colors.black),), 
                      ),
                    );
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