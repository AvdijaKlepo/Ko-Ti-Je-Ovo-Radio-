import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/bottom_nav_provider.dart';
import 'package:ko_radio_mobile/screens/freelancer_job_screen.dart';
import 'package:ko_radio_mobile/screens/freelancer_list.dart';
import 'package:ko_radio_mobile/screens/job_list.dart';
import 'package:ko_radio_mobile/screens/service_list.dart';
import 'package:provider/provider.dart';



class MasterScreen extends StatefulWidget {
  MasterScreen({super.key,this.child});
  final Widget? child;




  
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
    JobList()
  ];
   final List<Widget> _pagesUser = const [
    
    ServiceListScreen(),
  ];



  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);

   
    


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

      body: widget.child ?? IndexedStack(
              index: navProvider.selectedIndex,
              children: AuthProvider.userRoles?.role.roleName == "User" ? _pagesUser : _pagesFreelancer,
            ),
      
      
      
      
      bottomNavigationBar:
      AuthProvider.userRoles?.role.roleName == "User" ?
      
       BottomNavigationBar(
   currentIndex: navProvider.selectedIndex,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Početna'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.paste), label: 'Poslovi'),
                ],
                onTap: navProvider.setIndex,
      ):
       BottomNavigationBar(
                currentIndex:navProvider.selectedIndex,
                items: const [
                  BottomNavigationBarItem(
                    
                      icon:  Icon(Icons.home), label: 'Početna'),

                  BottomNavigationBarItem(
                      icon: Icon(Icons.paste), label: 'Poslovi'),
                ],
                onTap: navProvider.setIndex,
                
              )

    );
  }
}
