import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_desktop/main.dart';
import 'package:ko_radio_desktop/screens/freelancer_list_screen.dart';
import 'package:ko_radio_desktop/screens/service_list_screen.dart';
import 'package:ko_radio_desktop/screens/user_list_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const UserListScreen(),
    const FreelancerListScreen(),
    const UserListScreen(),
    const ServicesListScreen(),
    LoginPage(),
    LoginPage(),
    LoginPage(),
  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: const Color(0xFF1B4C7D),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Ko Ti Je Ovo Radio?",
                style: GoogleFonts.lobster(
                  textStyle: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            unselectedIconTheme: const IconThemeData(color: Colors.white),
            selectedIconTheme: const IconThemeData(color: Colors.amberAccent),
            selectedLabelTextStyle: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Korisnici'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work_outline),
                selectedIcon: Icon(Icons.work),
                label: Text('Samozaposleni'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: Text('Firme'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.electrical_services_outlined),
                selectedIcon: Icon(Icons.electrical_services),
                label: Text('Servisi'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings),
                label: Text('Administracija'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.manage_accounts_outlined),
                selectedIcon: Icon(Icons.manage_accounts),
                label: Text('Uredi Profil'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.logout_outlined),
                selectedIcon: Icon(Icons.logout),
                label: Text('Odjava'),

              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
