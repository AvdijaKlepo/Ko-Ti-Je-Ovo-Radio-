import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: 
          ElevatedButton(child: Text('Odjava'),onPressed: () => Navigator.pop(context),),
        )
      ],
    );
  }
}