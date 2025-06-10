

import 'package:ko_radio_mobile/models/messages.dart';

import 'package:ko_radio_mobile/providers/base_provider.dart';



class MessagesProvider extends BaseProvider<Messages>{
  MessagesProvider(): super("Message");

  @override
  Messages fromJson(data) {
    return Messages.fromJson(data);
  
  }
}
