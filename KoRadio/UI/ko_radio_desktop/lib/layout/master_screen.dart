


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_desktop/main.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/messages.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/messages_provider.dart';
import 'package:ko_radio_desktop/providers/signalr_provider.dart';
import 'package:ko_radio_desktop/screens/company_employee_list.dart';
import 'package:ko_radio_desktop/screens/company_job.dart';
import 'package:ko_radio_desktop/screens/company_list.dart';
import 'package:ko_radio_desktop/screens/company_report.dart';
import 'package:ko_radio_desktop/screens/company_update_screen.dart';
import 'package:ko_radio_desktop/screens/freelancer_list_screen.dart';
import 'package:ko_radio_desktop/screens/messages_screen.dart';
import 'package:ko_radio_desktop/screens/report.dart';
import 'package:ko_radio_desktop/screens/service_list_screen.dart';
import 'package:ko_radio_desktop/screens/store_orders.dart';
import 'package:ko_radio_desktop/screens/store_product_list.dart';
import 'package:ko_radio_desktop/screens/store_report.dart';
import 'package:ko_radio_desktop/screens/store_update_screen.dart';
import 'package:ko_radio_desktop/screens/stores_list.dart';
import 'package:ko_radio_desktop/screens/tender_screen.dart';
import 'package:ko_radio_desktop/screens/user_list_screen.dart';
import 'package:provider/provider.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  late MessagesProvider messagesProvider;
  late CompanyProvider companyProvider;
  SearchResult<Messages>? result;
  SearchResult<Messages>? notificationResult;
  SearchResult<Company>? companyResult;
  bool isChecked = false;
  DrawerController? drawerController;
  @override
  void initState()  {
    super.initState();
    messagesProvider = context.read<MessagesProvider>();
    companyProvider = context.read<CompanyProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    
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
    Map<String, dynamic> filter = {};
    if(AuthProvider.selectedCompanyId!=null)
    {
       filter = {'CompanyId' : AuthProvider.selectedCompanyId,
    'IsOpened': false};
    }
    else if(AuthProvider.selectedStoreId!=null)
    {
      filter = {'StoreId' : AuthProvider.selectedStoreId,
    'IsOpened': false};
    }
    else{
      filter = {'UserId' : AuthProvider.user?.userId,
    'IsOpened': false};
    }
    
    try {
      var fetched = await messagesProvider.get(filter: filter);
      if(!mounted) return;
      setState(() => result = fetched);
    } catch (e) {
      if(!mounted) return;
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
      icon: Icon(Icons.paste_outlined),
      selectedIcon: Icon(Icons.paste),
      label: Text('Tenderi'),
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

  
  ];
    final List _pagesCompanyAdmin = [
    const CompanyEmployeeList(),
    const CompanyJob(),
    const TenderScreen(),
    const CompanyReport(),

 

   
  
  ];
  final List _pagesStoreManager = [
    const StoreProductList(),
    const StoreOrders(),
    const StoreReport(),
  
  ];
  String get primaryRole {
  final roles = AuthProvider.user?.userRoles?.map((r) => r.role?.roleName).toList() ?? [];

  if (roles.contains("Admin")) return "Admin";
  if (roles.contains("Company Admin") && AuthProvider.selectedCompanyId!=null) return "Company Admin";
  if (roles.contains("StoreAdministrator") && AuthProvider.selectedStoreId!=null) return "StoreAdministrator";

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
      onDrawerChanged: (isOpened) async {
        if (isOpened)  {
        
        } else {
          await _getNotifications();
        }
      },
      drawer:  Drawer(
      

        
        backgroundColor: Colors.white,

        child: Column(
          children: [
        
            MessagesScreen(
              companyId: AuthProvider.selectedCompanyId,
              storeId: AuthProvider.selectedStoreId,
            ),

           
          ],
        ),),
      body: Row(
        children: [
       
          Container( decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight, 
          colors: [Color.fromRGBO(27, 76, 125, 1),Color(0xFF4A90E2)]
      
        ),
      ),
            child: NavigationRail(
              backgroundColor: Colors.transparent,
              extended: true,
                     
              trailing:Padding(padding: const EdgeInsets.only(right: 110),
            
              child: Column(
                children: [
                  if(AuthProvider.selectedCompanyId!=null &&  AuthProvider.selectedStoreId==null)
                  InkWell(
                    onTap: () async {
                 
                 
                 
                await showDialog(
                        context: context,
                        builder: (_) => CompanyUpdateScreen(
                          companyId: AuthProvider.selectedCompanyId!,
                          parentContext: context,
                        ),
                      );
                    
                    },
                    child: Row(
                      children: [
                        IconButton(onPressed: () async {
                         await showDialog(
                            context: context,
                            builder: (_) => CompanyUpdateScreen(
                              companyId: AuthProvider.selectedCompanyId!,
                              parentContext: context,
                            ),
                          );
                        }, icon: const Icon(Icons.settings_outlined,color: Colors.white,),),
                        const SizedBox(width: 10,),
                        const Text('Postavke',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),
                  if(AuthProvider.selectedCompanyId==null && AuthProvider.selectedStoreId!=null)
                  InkWell(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (_) => StoreUpdateScreen(
                          storeId: AuthProvider.selectedStoreId!,
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        IconButton(onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (_) => StoreUpdateScreen(
                              storeId: AuthProvider.selectedStoreId!,
                            ),
                          );
                        }, icon: const Icon(Icons.settings_outlined,color: Colors.white,),),
                        const SizedBox(width: 10,),
                        const Text('Postavke',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),
                  Row(
                  
                        
                    children: [
                    
                     IconButton(alignment: Alignment.topLeft,icon: const Icon(Icons.logout),color: Colors.white, onPressed: ()  {
                          
                  
                    AuthProvider().logout();
                          
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>  const LoginPage()), (route) => false);
                             
                  }),
                  const SizedBox(width: 25,),
                  const Text('Odjava',style: TextStyle(color: Colors.white),),
                  ]
                  ),
                ],
              )
              ,),
               
              
              
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
                      if(AuthProvider.selectedStoreId!=null)
                      Text(
                        "${AuthProvider.user!.stores!.where((element) => element.storeId==AuthProvider.selectedStoreId).map((e) => e.storeName).first}",
                        style: GoogleFonts.lobster(
                          textStyle: const TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ),
                      const SizedBox(height: 20,),
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
