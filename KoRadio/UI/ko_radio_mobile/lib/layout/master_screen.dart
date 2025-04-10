import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/screens/freelancer_list.dart';
import 'package:ko_radio_mobile/screens/service_list.dart';

class MasterScreen extends StatefulWidget {
  MasterScreen({super.key, required this.child});
  Widget child;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
   int _selectedIndex = 0;
  final List<Widget> _pages = [
        const ServiceListScreen(),
      

  ];
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _navigateTo(Widget page) {
    _navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('Ko Ti Je Ovo Radio?', style: GoogleFonts.lobster())),
      ),
      body: Expanded(
        child: widget.child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: InkWell(
              child: Icon(Icons.home),
              onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ServiceListScreen())),
            ),
            label: 'Servisi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Trgovine')
        ],
      ),
    );
  }
}