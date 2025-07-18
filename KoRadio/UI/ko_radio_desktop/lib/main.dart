import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_desktop/layout/master_screen.dart';
import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/company_job_assignment.dart';
import 'package:ko_radio_desktop/models/product.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/user_role.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/company_role_provider.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/order_provider.dart';
import 'package:ko_radio_desktop/providers/product_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:ko_radio_desktop/providers/user_provider.dart';
import 'package:ko_radio_desktop/screens/user_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:ko_radio_desktop/providers/signalr_provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_)=> UserProvider()),
      ChangeNotifierProvider(create: (_)=>FreelancerProvider()),
      ChangeNotifierProvider(create: (_)=>ServiceProvider()),
      ChangeNotifierProvider(create: (_)=>LocationProvider()),
      ChangeNotifierProvider(create: (_)=>CompanyProvider()),
      ChangeNotifierProvider(create: (_)=>CompanyEmployeeProvider()),
      ChangeNotifierProvider(create: (_)=>CompanyRoleProvider()),
      ChangeNotifierProvider(create: (_)=>CompanyJobAssignmentProvider()),
      ChangeNotifierProvider(create: (_)=>StoreProvider()),
      ChangeNotifierProvider(create: (_)=>JobProvider()),
      ChangeNotifierProvider(create: (_)=>ProductProvider()),
      ChangeNotifierProvider(create: (_)=>OrderProvider()),

    ],
    child: const MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.white, primary: const Color.fromRGBO(27, 76, 125, 25)),
        useMaterial3: true,
         fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      home: Center(
        child: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final SignalRProvider _signalRProvider = SignalRProvider('notifications-hub');

  @override
  void initState() {
    super.initState();


    if (AuthProvider.isSignedIn) {
      _signalRProvider.stopConnection();
      AuthProvider.connectionId = null;
      AuthProvider.isSignedIn = false;
    }

    _signalRProvider.startConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/images/logo.png"),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.password),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      AuthProvider.username = usernameController.text;
                      AuthProvider.password = passwordController.text;

                      final userProvider = UserProvider();
                      final signalRProvider = SignalRProvider('notifications-hub');

                      final user = await userProvider.login(
                        AuthProvider.username,
                        AuthProvider.password,
                        AuthProvider.connectionId,
                      );

                      signalRProvider.startConnection();

              

                      AuthProvider.user = user;
                      AuthProvider.userRoles = user.userRoles?.isNotEmpty == true
                          ? user.userRoles!.first
                          : null;
                      AuthProvider.isSignedIn = true;

                      final companyEmployees = user.companyEmployees ?? [];
                   

                      if (companyEmployees.length > 1) {
                        await showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                            title: const Text("Odaberite firmu: "),
                            children: companyEmployees.map((company)  {
                              return SimpleDialogOption(
                                onPressed: () {
                                  AuthProvider.selectedCompanyId = company.companyId;
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MasterScreen()),
                                  );
                                },
                                child: Text(company.companyName ?? 'Nepoznata firma', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              );
                            }).toList(),
                          ),
                        );
                        return;
                      }

                      if (companyEmployees.length == 1) {
                        AuthProvider.selectedCompanyId = companyEmployees.first.companyId;
                      }
                      
                      final stores = user.stores ?? [];
                      if (stores.length > 1) {
                        await showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                            title: const Text("Odaberite trgovinu: "),
                            children: stores.map((store)  {
                              return SimpleDialogOption(
                                onPressed: () {
                                  AuthProvider.selectedStoreId = store.storeId;
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MasterScreen()),
                                  );
                                },
                                child: Text(store.storeName ?? 'Nepoznata trgovina', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              );
                            }).toList(),
                          ),
                        );
                        return;
                      }
                      if (stores.length == 1) {
                        AuthProvider.selectedStoreId = stores.first.storeId;
                      
             
                        
                      }

                      debugPrint('Role: ${AuthProvider.userRoles?.role?.roleName}');
                      debugPrint('CompanyId: ${AuthProvider.selectedCompanyId}');
                         
                         
                         if(AuthProvider.userRoles?.role?.roleName=="Admin" ||
                      AuthProvider.userRoles?.role?.roleName=="Company Admin" ||
                      AuthProvider.userRoles?.role?.roleName=="StoreAdministrator")
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MasterScreen()),
                      );
                      else{
                         showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Greška"),
                          content: Text('Pogrešan email ili password'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                      }
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Greška"),
                          content: Text(e.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text("Prijavi se"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



