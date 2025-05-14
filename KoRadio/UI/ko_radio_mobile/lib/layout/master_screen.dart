import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/screens/freelancer_confirmed_requests.dart';
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
     
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           
            
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
       
          ],
        ),
      ),

      body: widget.child,
      bottomNavigationBar:
      AuthProvider.userRoles?.role.roleName == "User" ?
      
       BottomNavigationBar(
    
        
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
      ):
       BottomNavigationBar(
    
        
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
          BottomNavigationBarItem(icon: InkWell(child: Icon(Icons.shop),onTap:()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ConfirmedRequests())),), label: 'Pregled poslova'),
        ],
      )

    );
  }
}
