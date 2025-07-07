import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/bottom_nav_provider.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/screens/cart.dart';
import 'package:ko_radio_mobile/screens/freelancer_job_screen.dart';
import 'package:ko_radio_mobile/screens/job_list.dart';
import 'package:ko_radio_mobile/screens/service_list.dart';
import 'package:ko_radio_mobile/screens/settings.dart';
import 'package:ko_radio_mobile/screens/store_list.dart';
import 'package:ko_radio_mobile/screens/tender_screen.dart';
import 'package:provider/provider.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int selectedIndex = 0;
  String get selectedRole =>
      AuthProvider.selectedRole;

  List<Widget> get pages {
    switch (selectedRole) {
      case "Freelancer":
        return const [
          FreelancerJobsScreen(),
          JobList(),
          TenderScreen(),
          Settings()
        ];
      case "User":
      default:
        return const [
          ServiceListScreen(),
          JobList(),
          TenderScreen(),
          StoreList(),
          Settings()
        ];
    }
  }

  List<BottomNavigationBarItem> get bottomNavItems {
    switch (selectedRole) {
      case "Freelancer":
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
          BottomNavigationBarItem(icon: Icon(Icons.paste), label: 'Poslovi'),
          BottomNavigationBarItem(icon: Icon(Icons.content_paste_go), label: 'Tenderi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Račun'),
        ];
      case "User":
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
          BottomNavigationBarItem(icon: Icon(Icons.paste), label: 'Poslovi'),
          BottomNavigationBarItem(icon: Icon(Icons.content_paste_go), label: 'Tenderi'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Trgovine'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Račun'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<BottomNavProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
            Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                style: IconButton.styleFrom(
            
                 
                ),
                color: const Color.fromRGBO(27, 76, 125, 1),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Cart()),
                  );
                },
              ),
              if (cart.count > 0)
                Positioned(

                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.count}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: 
                FittedBox(
                 
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Ko Ti Je Ovo Radio?',
                    style: GoogleFonts.lobster(
                      textStyle: const TextStyle(
                        color: Color.fromRGBO(27, 76, 125, 1),
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              
              
            ),
          ],
        ),
      ),
  body: pages[navProvider.selectedIndex.clamp(0, pages.length - 1)],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
     currentIndex: navProvider.selectedIndex.clamp(0, bottomNavItems.length - 1),

        onTap: navProvider.setIndex,
        items: bottomNavItems,
      ),
    );
  }
}
