import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/main.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/signalr_provider.dart';
import 'package:ko_radio_mobile/screens/messages.dart';
import 'package:ko_radio_mobile/screens/user_company_apply.dart';
import 'package:ko_radio_mobile/screens/user_freelancer_apply.dart';
import 'package:signalr_netcore/hub_connection.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});


  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {  late HubConnection _hubConnection;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: 
          GestureDetector(
            child: ElevatedButton(child: Text('Odjava'),onPressed: () async =>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>  LoginPage())),) ,
            onTap: () async => {
              _hubConnection.stop(),
              AuthProvider.connectionId = null,
              AuthProvider.isSignedIn = false
  

            } 
          )
         ,
        ),
        Center(
          child: 
          ElevatedButton(child: Text('Radnik prijava'),onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>  UserFreelancerApply(user: AuthProvider.user,))),),
        ),
         Center(
          child: 
          ElevatedButton(child: Text('Prijava Firme'),onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>  UserCompanyApply(user: AuthProvider.user,))),),
        ),
          Center(
          child: 
          ElevatedButton(child: Text('Poruke'),onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>  MessagesScreen())),),
        ),
      ],
    );
  }
}