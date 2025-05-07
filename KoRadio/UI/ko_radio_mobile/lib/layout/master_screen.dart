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

      


  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _navigateTo(Widget page) {
    _navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  drawer: Drawer(
    child: ListView(
      children: [
        DrawerHeader(child: Text('Ko Ti Je Ovo Radio?')),
        ListTile(
          title: Text('Tile 1'),
        )
      ],
    ),
  ),
  appBar: AppBar(
    automaticallyImplyLeading: false, 
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
    
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),


        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Ko Ti Je Ovo Radio?',
                style: GoogleFonts.lobster(
                  textStyle: TextStyle(
                    color: Color.fromRGBO(27, 76, 125, 1),
                  ),
                ),
              ),
            ),
          ),
        ),

   
        Icon(Icons.person),
      ],
    ),
  ),
  body: widget.child, 
  bottomNavigationBar: BottomNavigationBar(
    items: [
      BottomNavigationBarItem(
        icon: InkWell(
          child: Icon(Icons.home),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ServiceListScreen()),
          ),
        ),
        label: 'Početna',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Trgovine'),
    ],
  ),
);

  }
}