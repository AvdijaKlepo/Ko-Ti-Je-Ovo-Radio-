import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/layout/master_Screen.dart';

class WorkerListScreen extends StatelessWidget {
  const WorkerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
        "Workers",
        Column(
          children: [
            Text("Worker list placeholder!"),
            SizedBox(
              height: 8,
            ),
            ElevatedButton(
                onPressed: () => Navigator.pop(context), child: Text("Back"))
          ],
        ));
  }
}
