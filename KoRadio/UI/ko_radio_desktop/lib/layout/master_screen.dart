

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_desktop/main.dart';
import 'package:ko_radio_desktop/models/messages.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/messages_provider.dart';
import 'package:ko_radio_desktop/providers/signalr_provider.dart';
import 'package:ko_radio_desktop/screens/company_employee_list.dart';
import 'package:ko_radio_desktop/screens/company_job.dart';
import 'package:ko_radio_desktop/screens/company_list.dart';
import 'package:ko_radio_desktop/screens/company_report.dart';
import 'package:ko_radio_desktop/screens/freelancer_list_screen.dart';
import 'package:ko_radio_desktop/screens/message_details.dart';
import 'package:ko_radio_desktop/screens/messages_screen.dart';
import 'package:ko_radio_desktop/screens/report.dart';
import 'package:ko_radio_desktop/screens/service_list_screen.dart';
import 'package:ko_radio_desktop/screens/settings.dart';
import 'package:ko_radio_desktop/screens/store_orders.dart';
import 'package:ko_radio_desktop/screens/store_product_list.dart';
import 'package:ko_radio_desktop/screens/store_report.dart';
import 'package:ko_radio_desktop/screens/stores_list.dart';
import 'package:ko_radio_desktop/screens/user_list_screen.dart';
import 'package:provider/provider.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  late MessagesProvider messagesProvider;
  SearchResult<Messages>? result;
  SearchResult<Messages>? notificationResult; 
  bool isChecked = false;
  @override
  void initState()  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    messagesProvider = context.read<MessagesProvider>();
     await _getNotifications();
     await _getNotificationsList();
     
    });
    final signalR = context.read<SignalRProvider>();
signalR.onNotificationReceived = (message) async {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );
  await _getNotifications();
  await _getNotificationsList();
};

  }
  Future<void> _getNotifications() async {
    Map<String, dynamic> filter = {};
    if(AuthProvider.selectedCompanyId!=null)
    {
       filter = {'CompanyId' : AuthProvider.selectedCompanyId,
    'IsOpened': false};
    }
    if(AuthProvider.selectedStoreId!=null)
    {
      filter = {'StoreId' : AuthProvider.selectedStoreId,
    'IsOpened': false};
    }
    
    try {
      var fetched = await messagesProvider.get(filter: filter);
      setState(() => result = fetched);
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
        
      );
    }
  }
  Future<void> _getNotificationsList() async {
    Map<String, dynamic> filter = {};
    if(AuthProvider.selectedCompanyId!=null)
    {
       filter = {'CompanyId' : AuthProvider.selectedCompanyId};
    }
    if(AuthProvider.selectedStoreId!=null)
    {
      filter = {'StoreId' : AuthProvider.selectedStoreId};
    }
    
    try {
      var fetched = await messagesProvider.get(filter: filter,orderBy: 'desc');
      setState(() => notificationResult = fetched);
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
        
      );
    }
  }
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


final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.white,

        child: Column(
          children: [
        
               Row(
                 children: [
                   Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    value: isChecked, 
                    onChanged: (bool? value)async {
                   setState(() {
                     isChecked = true;
                     _getNotifications();
                     _getNotificationsList();
                     
                   });
                   if (isChecked) {
                    for (var message in result!.result.where((element) => element.isOpened == false)) {
                      var request = {
                        'messageId': message.messageId, 
              'message1': message.message1,
              'companyId': AuthProvider.selectedCompanyId,
              'isOpened': true,
            };
                      await messagesProvider.update(message.messageId!,request);
                    }
                     
                   }
                      await _getNotificationsList();
                      await _getNotifications();
                    },
                                 ),
                                 Container(margin:EdgeInsets.only(),
                   child:  Text('Označi sve kao pročitano',style: TextStyle(color: Colors.black),)
                    ,
                               ),
                 ],
               ),
               Expanded(child:   ListView.builder(
              itemCount: notificationResult?.result.length ?? 0,
              itemBuilder: (context, index) {
                var e = notificationResult!.result[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape:  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: e.isOpened == true ?Color.fromRGBO(27, 76, 125, 25) : Colors.amberAccent,
                    onTap: () async { 
                      showDialog(context: context, builder: (_)  =>   MessageDetails(messages: e,));
                      setState(() {
                        _getNotifications();
                        _getNotificationsList();
                      });
                      await _getNotifications();
                      await _getNotificationsList();
                     
                    },
                    leading: Text(e.message1.toString().split('.')[0],style: TextStyle(color: e.isOpened == true ?Colors.white : Colors.black),),
                  ),
                );
              },
            ),),
          
         
           
          ],
        ),),
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
                    SizedBox(height: 20,),
                Padding(padding: const EdgeInsets.only(right: 110),
                child:  Row(
                       children: [
                         Stack(
                                       
                                     alignment: Alignment.topLeft,
                                     children: [
                                      
                                     
                                       IconButton(
                                         icon: const Icon(Icons.notifications),
                                         style: IconButton.styleFrom(
                                     
                                          
                                         ),
                                         color:  Colors.white,
                                         onPressed: () async {
                                         _scaffoldKey.currentState?.openDrawer();
                                      
                                         setState(() {
                                           isChecked = false;
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
                                   ),
                                 
                                   const Text('Notifikacije',style: TextStyle(color: Colors.white),),
                       ],
                     ) ,)
                    
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
