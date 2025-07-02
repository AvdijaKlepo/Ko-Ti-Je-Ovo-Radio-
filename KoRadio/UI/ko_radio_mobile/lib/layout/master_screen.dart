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

import 'package:provider/provider.dart';



class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  



  
  @override
  State<MasterScreen> createState() => _MasterScreenState();

}

class _MasterScreenState extends State<MasterScreen> {

@override
void initState() {
  super.initState();

}

int selectedIndex=0;

 final List<Widget> _pagesFreelancer = const [
    
    FreelancerJobsScreen(),
    JobList(),
    Settings()
  ];
   final List<Widget> _pagesUser = const [
    
    ServiceListScreen(),
    JobList(),
    StoreList(),
    Settings()
  ];



  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);

   
    


    return Scaffold(
     
      appBar: AppBar(
        actions: [Consumer<CartProvider>(
      builder: (_, cart, __) => Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            color:Color.fromRGBO(27, 76, 125, 1),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Cart(),
                ));
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
      ),
    ),],
        automaticallyImplyLeading: false,
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
                      textStyle: const TextStyle(
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

      body: IndexedStack(
        
                index: navProvider.selectedIndex,
                children: AuthProvider.userRoles?.role?.roleName == "User" ? _pagesUser : _pagesFreelancer,
              ),
             
      
      
      
      
      
      bottomNavigationBar:

      AuthProvider.userRoles?.role?.roleName == "User" ?
      
       BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
   currentIndex: navProvider.selectedIndex,

   
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Početna'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.paste), label: 'Poslovi'),
                       BottomNavigationBarItem(
                      icon: Icon(Icons.store), label: 'Trgovine'),
                       BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Račun'),
                ],
                onTap:navProvider.setIndex,
                
      ):
       BottomNavigationBar(
                currentIndex:navProvider.selectedIndex,
                items: const [
                  BottomNavigationBarItem(
                    
                      icon:  Icon(Icons.home), label: 'Početna'),

                  BottomNavigationBarItem(
                      icon: Icon(Icons.paste), label: 'Poslovi'),
                       BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Račun')
                ],
                onTap: navProvider.setIndex,
                
              )

    );
  }
}