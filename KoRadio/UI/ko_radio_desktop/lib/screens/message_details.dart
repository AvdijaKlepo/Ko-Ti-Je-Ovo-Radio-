import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/messages.dart';
import 'package:ko_radio_desktop/providers/messages_provider.dart';
import 'package:provider/provider.dart';

class MessageDetails extends StatefulWidget {
  const MessageDetails({required this.messages, super.key});
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
      'companyId': widget.messages.companyId,
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
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 500,
        height: 200,
        child: Center(
        child: Text(widget.messages.message1??"Poruka nije dostupna"),
      ),
      ) 
    );
  }
}