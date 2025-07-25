import 'dart:async';
import 'messages_provider.dart';
import 'package:ko_radio_mobile/main.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';
import 'package:flutter/material.dart'; 


class SignalRProvider with ChangeNotifier {
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
  final url = '$_baseUrl$_endpoint?userId=${AuthProvider.user?.userId}';


    _hubConnection = HubConnectionBuilder().withUrl(url).build();

     _hubConnection.on('ReceiveNotification', (arguments) {
  if (arguments != null && arguments.isNotEmpty) {
    final message = arguments[0]?.toString() ?? '';
    if (message.isNotEmpty) {
      onNotificationReceived?.call(message);
    }
  }
});

    try {
      await _hubConnection.start();
      _startConnectionIdTimeout();
    } catch (e) {
      _scheduleReconnect();
    }

    _hubConnection.on('ReceiveConnectionId', (arguments) async {
      _connectionIdTimeoutTimer?.cancel();
      AuthProvider.connectionId = arguments?[0];
      onNotificationReceived?.call('Dobrodošli u KoTiJeOvoRadio!');
        await messagesProvider.get(filter: {
        'UserId': AuthProvider.user?.userId,
        'IsOpened': false,
      });


      notifyListeners();
    });


   


   
  }

void Function(String message)? onNotificationReceived = (message) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );
};


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
