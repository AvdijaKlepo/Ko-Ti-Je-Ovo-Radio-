import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/messages.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/messages_provider.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, this.user});
  final User? user;

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
    final messages = await messagesProvider.get();

    setState(() {
      result = messages;
    });
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
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(

                        leading: Text(e.message1??"Poruka nije dostupna"),
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