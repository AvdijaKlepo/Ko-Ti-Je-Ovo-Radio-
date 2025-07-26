import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late SearchResult<Messages> result =SearchResult();
  bool isChecked = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading=true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    messagesProvider = context.read<MessagesProvider>();
    

    await _fetchData();
    });
    setState(() {
      isLoading=false;
    });
   

  }
   Future<void> _fetchData() async {
    setState(() {
      isLoading=true;
    });
    var filter = {'UserId': AuthProvider.user?.userId ?? 0};
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
      
      appBar: AppBar(title:  Text("Notifikacije",style: TextStyle(fontFamily: GoogleFonts.lobster().fontFamily,color: Color.fromRGBO(27, 76, 125, 25),letterSpacing: 1.2),),
      centerTitle: true,
      ),
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [ 
           if (result.result.isNotEmpty &&
    result.result.any((element) => element.isOpened == false))
  Row(
    children: [
      Checkbox(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        value: isChecked,
        onChanged: (bool? value) async {
          setState(() {
            isChecked = true;
          });

          for (var message
              in result.result.where((e) => e.isOpened == false)) {
            var request = {
              'messageId': message.messageId,
              'message1': message.message1,
              'userId': AuthProvider.user?.userId,
              'isOpened': true,
            };
            await messagesProvider.update(message.messageId!, request);
          }

          await _fetchData();
        },
      ),
      const Text(
        'Označi sve kao pročitano',
        style: TextStyle(color: Colors.black),
      ),
    ],
  ),

              Expanded(
                child:
              (result.result.isEmpty)
              ? isLoading ? const Center(child: CircularProgressIndicator()) : const Center(
                child: 
         
                
                    Text('Nemate notifikacija',style: TextStyle(color: Colors.black,fontSize: 20),),
            
              ) : 
                
                
                 ListView.builder(
                  itemCount: result.result.length,
                  itemBuilder: (context, index) {
                   


                    var e = result.result[index];
                   
                    return Card(
                     color: e.isOpened == true ? Colors.grey : Colors.amberAccent,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        onTap: () async { 
                      
                      await  showDialog(context: context, builder: (_)=> MessageDetails(messages: e));

                       
                         await _fetchData();
                        
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