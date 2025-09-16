import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/main.dart';
import 'package:ko_radio_mobile/models/messages.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/messages_provider.dart';
import 'package:ko_radio_mobile/providers/signalr_provider.dart';
import 'package:ko_radio_mobile/screens/cart.dart';
import 'package:ko_radio_mobile/screens/freelancer_job_screen.dart';
import 'package:ko_radio_mobile/screens/job_list.dart';
import 'package:ko_radio_mobile/screens/messages.dart';
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
  late MessagesProvider messagesProvider;
  SearchResult<Messages>? result;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      messagesProvider = context.read<MessagesProvider>();
      await _getNotifications();
      
    });
      final signalR = context.read<SignalRProvider>();
signalR.onNotificationReceived = (message) async {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );
  await _getNotifications();
};
   
  }
  Future<void> _getNotifications() async {
    var filter = {'UserId' : AuthProvider.user?.userId,
    'IsOpened': false};
    try {
      var fetched = await messagesProvider.get(filter: filter);
      setState(() => result = fetched);
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }
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
          StoreList(),
          Settings()
        ];
      case "CompanyEmployee":
        return const [
           FreelancerJobsScreen(),
          JobList(),
          Settings(),
        ];
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
           BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Trgovine'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Račun'),
        ];
      case "CompanyEmployee":
        return const [
           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
          BottomNavigationBarItem(icon: Icon(Icons.paste), label: 'Poslovi'),
           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Račun'),

        ];
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
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        
    
        title: Card(
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
        
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            
              
          
            children: [
                Stack(
                
              alignment: Alignment.topLeft,
              children: [
                IconButton(
                
                  icon: const Icon(Icons.notifications),
                  style: IconButton.styleFrom(
              
                   
                  ),
                  color: const Color.fromRGBO(27, 76, 125, 1),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const MessagesScreen()),
                    );
                    setState(() {
                      _getNotifications();
                    });
                  },
                ),
                if (result?.result.isNotEmpty ?? false)
                  Positioned(
          
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${result?.count ?? 0}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ) ,
              Padding(
                padding: 
              EdgeInsets.zero,
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
            ) ,
            ],
          ),
        ),
      ),
  body: pages[selectedIndex.clamp(0, pages.length - 1)],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex.clamp(0, bottomNavItems.length - 1),
        onTap: (index) => setState(() => selectedIndex = index),
        items: bottomNavItems,
      ),
    );
  }
}
