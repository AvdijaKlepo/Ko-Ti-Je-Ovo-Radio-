





import 'package:ko_radio_desktop/models/messages.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class MessagesProvider extends BaseProvider<Messages>{
  MessagesProvider(): super("Message");

  @override
  Messages fromJson(data) {
    return Messages.fromJson(data);
  
  }
}
