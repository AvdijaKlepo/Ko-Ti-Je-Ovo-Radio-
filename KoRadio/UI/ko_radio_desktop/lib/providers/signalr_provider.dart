import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/main.dart';
import 'package:ko_radio_desktop/models/messages.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/messages_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
class SignalRProvider with ChangeNotifier {
  SearchResult<Messages>? result;
  
  late HubConnection _hubConnection;
  Timer? _reconnectTimer;
  Timer? _connectionIdTimeoutTimer;
  bool _isReconnecting = false;

  MessagesProvider messagesProvider = MessagesProvider();


  int _messageCount = 0;

  late String _baseUrl;
  late String _endpoint;

  SignalRProvider._privateConstructor(String endpoint) {
    
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "http://localhost:5053/");
  }

  static final SignalRProvider _instance =
      SignalRProvider._privateConstructor("");

  factory SignalRProvider(String endpoint) {
    _instance._endpoint = endpoint;
    return _instance;
  }

 /*Future<void> initializeMessageCount() async {
    final messages = await getMessages();
    _messageCount = messages.length;
    notifyListeners();
  }*/

  Future<void> startConnection() async {
    var url;
    if(AuthProvider.selectedCompanyId!=null)
    {
     url = '$_baseUrl$_endpoint?userId=${AuthProvider.selectedCompanyId}';
    }
     if(AuthProvider.selectedStoreId!=null)
    {
     url = '$_baseUrl$_endpoint?userId=${AuthProvider.selectedCompanyId}';
    }
 debugPrint('Connecting to SignalR at $url');


    _hubConnection = HubConnectionBuilder().withUrl(url).build();

     _hubConnection.on('ReceiveNotification', (arguments) async {
  if (arguments != null && arguments.isNotEmpty) {
    final message = arguments[0]?.toString() ?? '';
    if (message.isNotEmpty) {
      onNotificationReceived?.call(message);
       if(AuthProvider.selectedCompanyId!=null)
       {
      await messagesProvider.get(filter: {
        'CompanyId': AuthProvider.selectedCompanyId,
        'IsOpened': false,
      });
       }
       if(AuthProvider.selectedStoreId!=null)
       {
      await messagesProvider.get(filter: {
        'StoreId': AuthProvider.selectedStoreId,
        'IsOpened': false,
      });
       }


      notifyListeners();
      
    
      
      
    }
  }

});

    try {
      await _hubConnection.start();
      _startConnectionIdTimeout();
    } catch (e) {
      _scheduleReconnect();
    }

    _hubConnection.on('ReceiveConnectionId', (arguments) {
      _connectionIdTimeoutTimer?.cancel();
      AuthProvider.connectionId = arguments?[0];
      onNotificationReceived?.call('Dobrodošli u KoTiJeOvoRadio!');
    });

   


   
  }

void Function(String message)? onNotificationReceived = (message) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );



};

  Future<void> _getNotifications() async {
    Map<String, dynamic> filter = {};
    if(AuthProvider.selectedCompanyId!=null)
    {
       filter = {'CompanyId' : AuthProvider.selectedCompanyId,
    'IsOpened': false};
    }
    
    try {
      var fetched = await messagesProvider.get(filter: filter);
      result = fetched;
    } catch (e) {
     print(e);
    }
  }


  void _startConnectionIdTimeout() {
    _connectionIdTimeoutTimer = Timer(Duration(seconds: 3), () {
      _restartConnection();
    });
  }

  void _scheduleReconnect() {
    if (_isReconnecting) return;

    _isReconnecting = true;
    _reconnectTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      try {
        await startConnection();
        if (_hubConnection.state == HubConnectionState.Connected) {
          timer.cancel();
          _isReconnecting = false;
        }
      } catch (e) {}
    });
  }

  Future<void> _restartConnection() async {
    if (_hubConnection.state == HubConnectionState.Connected) {
      await _hubConnection.stop();
    }
    await startConnection();
  }

  bool isConnected() {
    return _hubConnection.state == HubConnectionState.Connected;
  }

  Future<void> stopConnection() async {
    if (_hubConnection.state == HubConnectionState.Connected) {
      await _hubConnection.stop();
      print(_hubConnection.state);
    }
    
  }

  Future<void> _saveMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthProvider.username;

    if (username != null) {
      final key = 'messages_$username';
      final messages = prefs.getStringList(key) ?? [];
      messages.add(message);
      await prefs.setStringList(key, messages);
    } else {}
  }

  Future<List<String>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthProvider.username;

    if (username != null) {
      return prefs.getStringList('messages_$username') ?? [];
    } else {
      return [];
    }
  }

  Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthProvider.username;

    if (username != null) {
      await prefs.remove('messages_$username');
      notifyListeners();
      _messageCount = 0;
    } else {}
  }

  int get messageCount => _messageCount;
 // void Function(String message)? onNotificationReceived;
}
