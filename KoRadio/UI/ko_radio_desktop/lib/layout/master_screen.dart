import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/screens/freelancer_list_screen.dart';
import 'package:ko_radio_desktop/screens/service_list_screen.dart';
import 'package:ko_radio_desktop/screens/user_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MasterScreen extends StatefulWidget {
  MasterScreen({super.key});



  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
    int _selectedIndex = 0;

    final List<Widget> _pages = [
    const UserListScreen(),       
    const FreelancerListScreen(), 
    const UserListScreen(),
    const ServicesListScreen()

  ];

   final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _navigateTo(Widget page) {
    _navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => page));
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Row(
     
        children: [
          
          NavigationRail(
          
            extended: true,
            
            backgroundColor:const Color.fromRGBO(27, 76, 125, 25),

            selectedIndex: _selectedIndex,
            onDestinationSelected:
            
             (int index) {
              setState(() {
                _selectedIndex = index; 
              });

            
            },
            labelType: NavigationRailLabelType.none,
            leading: Text( "Ko Ti Je Ovo Radio?",style:GoogleFonts.lobster(textStyle: const TextStyle(color: Colors.white,fontSize: 25))),
            unselectedIconTheme: const  IconThemeData(color: Colors.white),
         
            selectedLabelTextStyle: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white),

            
            
            destinations: const [

              

         
              NavigationRailDestination(
                
                
                icon: Icon(Icons.person),
                selectedIcon: Icon(Icons.person_outline),
                label: Text('Korisnici',),  
                padding: EdgeInsets.only(top: 50),


              ),
              NavigationRailDestination(
                icon: Icon(Icons.work),
                selectedIcon: Icon(Icons.work_outline),
                label: Text('Samozaposleni'),
              ),
               NavigationRailDestination(
                icon: Icon(Icons.business),
                selectedIcon: Icon(Icons.business_outlined),
                  label: Text('Firme'),
              ),
               NavigationRailDestination(
                icon: Icon(Icons.electrical_services),
                selectedIcon: Icon(Icons.electrical_services_outlined),
                 label: Text('Servisi'),
              ),
               NavigationRailDestination(
                icon: Icon(Icons.admin_panel_settings),
                selectedIcon: Icon(Icons.admin_panel_settings_outlined),
                 label: Text('Administracija'),
              ),
                             NavigationRailDestination(
                icon: Icon(Icons.manage_accounts),
                selectedIcon: Icon(Icons.manage_accounts_outlined),
                 label: Text('Uredi Profil'),
                 padding: EdgeInsets.only(top: 650)
              ),
               NavigationRailDestination(

                icon: Icon(Icons.logout),
                selectedIcon: Icon(Icons.logout_outlined),
                 label: Text('Odjava'),
                 
              ),
            ],

          ),


          const VerticalDivider(thickness: 1, width: 1),

         
          
           Expanded(
            child: _pages[_selectedIndex], // Switches the main content
          ),
          
        ],
      ),
    );
  }
}
