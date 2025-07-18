

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_desktop/main.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/screens/company_employee_list.dart';
import 'package:ko_radio_desktop/screens/company_job.dart';
import 'package:ko_radio_desktop/screens/company_list.dart';
import 'package:ko_radio_desktop/screens/company_report.dart';
import 'package:ko_radio_desktop/screens/freelancer_list_screen.dart';
import 'package:ko_radio_desktop/screens/report.dart';
import 'package:ko_radio_desktop/screens/service_list_screen.dart';
import 'package:ko_radio_desktop/screens/settings.dart';
import 'package:ko_radio_desktop/screens/store_orders.dart';
import 'package:ko_radio_desktop/screens/store_product_list.dart';
import 'package:ko_radio_desktop/screens/store_report.dart';
import 'package:ko_radio_desktop/screens/stores_list.dart';
import 'package:ko_radio_desktop/screens/user_list_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;

  final List<NavigationRailDestination>destinationsAdmin = const <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Korisnici'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.construction_outlined),
      selectedIcon: Icon(Icons.construction),
      label: Text('Samozaposleni'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.business_outlined),
      selectedIcon: Icon(Icons.business),
      label: Text('Firme'),
    ),
      NavigationRailDestination(
      icon: Icon(Icons.store_outlined),
      selectedIcon: Icon(Icons.store),
      label: Text('Trgovine'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.electrical_services_outlined),
      selectedIcon: Icon(Icons.electrical_services),
      label: Text('Servisi'),
    ),
     NavigationRailDestination(
      icon: Icon(Icons.report_outlined),
      selectedIcon: Icon(Icons.report),
      label: Text('Izveštaji'),
    ),
 
    NavigationRailDestination(
      icon: Icon(Icons.manage_accounts_outlined),
      selectedIcon: Icon(Icons.manage_accounts),
      label: Text('Uredi Profil'),
    ),
 
 
  ];

  final List<NavigationRailDestination> destinationsCompanyAdmin = const <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: Text('Lista Zaposlenika'),
    ),
      NavigationRailDestination(
      icon: Icon(Icons.work_outline),
      selectedIcon: Icon(Icons.work),
      label: Text('Poslovi'),
    ),
      NavigationRailDestination(
      icon: Icon(Icons.report_outlined),
      selectedIcon: Icon(Icons.report),
      label: Text('Izveštaji'),
    ),
  ];

  final List<NavigationRailDestination> destinationsStoreManager = const <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.paste_rounded),
      selectedIcon: Icon(Icons.people),
      label: Text('Lista Proizvoda'),
    ),
      NavigationRailDestination(
      icon: Icon(Icons.shopify_outlined),
      selectedIcon: Icon(Icons.shopify),
      label: Text('Narudžbe'),
    ),
      NavigationRailDestination(
      icon: Icon(Icons.report_outlined),
      selectedIcon: Icon(Icons.report),
      label: Text('Izvještaji'),
    ),
  ];

  final List _pagesAdmin = [
    const UserListScreen(),
    const FreelancerListScreen(),
    const CompanyList(),
    const StoresList(),
    const ServicesListScreen(),
    const Report(),
    const Settings(),
  
  ];
    final List _pagesCompanyAdmin = [
    const CompanyEmployeeList(),
    const CompanyJob(),
    const CompanyReport()
  
  ];
  final List _pagesStoreManager = [
    const StoreProductList(),
    const StoreOrders(),
    const StoreReport(),
  
  ];
  String get primaryRole {
  final roles = AuthProvider.user?.userRoles?.map((r) => r.role?.roleName).toList() ?? [];

  if (roles.contains("Admin")) return "Admin";
  if (roles.contains("Company Admin")) return "Company Admin";
  if (roles.contains("StoreAdministrator")) return "StoreAdministrator";

  return "User"; 
}

List<NavigationRailDestination> get destinationsForUser {
  switch (primaryRole) {
    case "Admin":
      return destinationsAdmin;
    case "Company Admin":
      return destinationsCompanyAdmin;
    case "StoreAdministrator":
    return destinationsStoreManager;
    default:
      return destinationsAdmin;
  }
}

List get pagesForUser {
  switch (primaryRole) {
    case "Admin":
      return _pagesAdmin;
    case "Company Admin":
      return _pagesCompanyAdmin;
    case "StoreAdministrator":
      return _pagesStoreManager;
    default:
      return _pagesAdmin; 
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
       
          NavigationRail(
            extended: true,
         
            trailing:Padding(padding: const EdgeInsets.only(right: 110),

            child: Row(

      
              children: [
              
               IconButton(alignment: Alignment.topLeft,icon: const Icon(Icons.logout),color: Colors.white, onPressed: ()  {
                    
            
              AuthProvider().logout();
        
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>  const LoginPage()), (route) => false);
           
            }),
            const SizedBox(width: 25,),
            const Text('Odjava',style: TextStyle(color: Colors.white),),
            ]
            )
            ,),
             
            backgroundColor: const Color(0xFF1B4C7D),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Ko Ti Je Ovo Radio?",
                    style: GoogleFonts.lobster(
                      textStyle: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                   if(AuthProvider.selectedCompanyId!=null)
                    Text(
                      "${AuthProvider.user!.companyEmployees!.where((element) => element.companyId==AuthProvider.selectedCompanyId).map((e) => e.companyName).first}",
                      style: GoogleFonts.lobster(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                ],
              ),

            ),
            
            unselectedIconTheme: const IconThemeData(color: Colors.white),
            selectedIconTheme: const IconThemeData(color: Colors.amberAccent),
            selectedLabelTextStyle: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white),
            destinations: destinationsForUser
          
            
            
             
          ),
          const VerticalDivider(thickness: 1, width: 1),
         
          
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                
                pagesForUser[_selectedIndex],
              ),
            ),
           
              
         
        ],
      ),
    );
  }
}
