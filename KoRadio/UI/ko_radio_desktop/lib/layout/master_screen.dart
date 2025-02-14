import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/screens/worker_list_screen.dart';

class MasterScreen extends StatefulWidget {
  MasterScreen(this.title, this.child, {super.key});
  String title;
  Widget child;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
                title: Text("Back"),
                onTap: () {
                  Navigator.pop(context);
                }),
            ListTile(
              title: Text("Workers"),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WorkerListScreen())),
            ),
            ListTile(
              title: Text("Products"),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WorkerListScreen())),
            )
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
