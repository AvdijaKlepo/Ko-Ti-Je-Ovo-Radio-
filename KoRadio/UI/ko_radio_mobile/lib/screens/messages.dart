import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/messages.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/messages_provider.dart';
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
  SearchResult<Messages>? result;
  bool isChecked = false;
  @override
  void initState() {
    super.initState();
    messagesProvider = context.read<MessagesProvider>();
    _fetchData();

  }
   Future<void> _fetchData() async {
    var filter = {'UserId': AuthProvider.user?.userId ?? 0};
    try {
  final messages = await messagesProvider.get(filter: filter,orderBy: 'desc');
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
      
      appBar: AppBar(title: const Text("Notifikacije"),centerTitle: true,),
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
                 Row(
                 children: [
                   Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    value: isChecked, 
                    onChanged: (bool? value)async {
                   setState(() {
                     isChecked = true;
                     _fetchData();
                   
                     
                   });
                   if (isChecked) {
                    for (var message in result!.result.where((element) => element.isOpened == false)) {
                      var request = {
                        'messageId': message.messageId, 
              'message1': message.message1,
              'userId': AuthProvider.user?.userId,
              'isOpened': true,
            };
                      await messagesProvider.update(message.messageId!,request);
                    }
                     
                   }
                      await _fetchData();
                    },
                                 ),
                                 Container(margin:EdgeInsets.only(),
                   child:  Text('Označi sve kao pročitano',style: TextStyle(color: Colors.black),)
                    ,
                               ),
                 ],
               ),
              Expanded(
                child: ListView.builder(
                  itemCount: result?.result.length ?? 0,
                  itemBuilder: (context, index) {
                    var e = result!.result[index];
                    return Card(
                     color: e.isOpened == true ?Color.fromRGBO(27, 76, 125, 25) : Colors.amberAccent,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        onTap: () async { 
                         showDialog(context: context, builder: (_)=> MessageDetails(messages: e));
                         setState(() {
                           _fetchData();
                         });
                         await _fetchData();
                         },

                        leading: Text("${e.message1.toString().split('.')[0]}" ?? "Poruka nije dostupna",style: TextStyle(color: e.isOpened == true ? Colors.white : Colors.black),), 
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