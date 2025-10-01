import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/models/messages.dart';
import 'package:ko_radio_mobile/providers/messages_provider.dart';
import 'package:provider/provider.dart';

class MessageDetails extends StatefulWidget {
  const MessageDetails({ super.key, required this.messages});
  final Messages messages;

  @override
  State<MessageDetails> createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<MessageDetails> {
  late MessagesProvider messagesProvider;
  @override
  void initState() {
    super.initState();
    messagesProvider = context.read<MessagesProvider>();
    _updateIsOpened();
    
  }
  Future<void> _updateIsOpened() async {
    var request = {
      'messageId': widget.messages.messageId,
      'message1': widget.messages.message1,
      'userId': widget.messages.userId,
      'isOpened': true,
    };
    
    try {
      await messagesProvider.update(widget.messages.messageId!, request);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Dialog(
      
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
     
            width: 500,
            height: 200,
            child: Center(
            child:Column(
          children: [
              Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifikacija',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(onPressed: () async {
               
                Navigator.of(context).pop();
              },icon: const Icon(Icons.close,color: Colors.white,),),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.messages.message1!,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        ),
            
          ],
        ),
              ),
      ) 
    );
  }
}