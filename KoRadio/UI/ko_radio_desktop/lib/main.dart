import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_desktop/layout/master_screen.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/company_employee_provider.dart';
import 'package:ko_radio_desktop/providers/company_job_assignment_provider.dart';
import 'package:ko_radio_desktop/providers/company_provider.dart';
import 'package:ko_radio_desktop/providers/company_role_provider.dart';
import 'package:ko_radio_desktop/providers/employee_task_provider.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/messages_provider.dart';
import 'package:ko_radio_desktop/providers/order_provider.dart';
import 'package:ko_radio_desktop/providers/product_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:ko_radio_desktop/providers/tender_bid_provider.dart';
import 'package:ko_radio_desktop/providers/tender_provider.dart';
import 'package:ko_radio_desktop/providers/user_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:ko_radio_desktop/providers/signalr_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
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
      ChangeNotifierProvider(create: (_)=>MessagesProvider()),
      ChangeNotifierProvider(create: (_)=>TenderProvider()),
      ChangeNotifierProvider(create: (_)=>TenderBidProvider()),
      ChangeNotifierProvider(create: (_)=>EmployeeTaskProvider()),
      ChangeNotifierProvider(create: (_)=>SignalRProvider('notifications-hub')),

    ],
    child: const MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Flutter Demo',
       supportedLocales: const[
        Locale('en', 'Latn'),
        Locale('bs', 'Latn'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
     
      theme: ThemeData(
       
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.white, primary: const Color.fromRGBO(27, 76, 125, 25)),
        useMaterial3: true,
         fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      home: const Center(
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
  bool _isLoading=false;


  @override
  void initState() {
    super.initState();
     final signalRProvider = context.read<SignalRProvider>();

  if (AuthProvider.isSignedIn) {
    signalRProvider.stopConnection();
    AuthProvider.connectionId = null;
    AuthProvider.isSignedIn = false;
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 Flexible(child: Text('Ko Ti Je Ovo Radio?',style: TextStyle(fontSize: 45,fontFamily: GoogleFonts.lobster().fontFamily,letterSpacing: 1.2,color: const Color.fromRGBO(27, 76, 125, 25)),)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      child: TextField(
                        controller: usernameController,
                       
                        decoration:  InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            labelStyle: const TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),
                            labelText: "Email adresa", prefixIcon: const Icon(Icons.email,color: Color.fromRGBO(27, 76, 125, 25))),
                      ),
                    ),
                  ),
              
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      child: TextField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        controller: passwordController,
                        decoration:  InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            labelStyle: const TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),
                            labelText: "Lozinka",
                            prefixIcon: const Icon(Icons.password,color: Color.fromRGBO(27, 76, 125, 25))),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    clipBehavior: Clip.hardEdge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
  onPressed: () async {
    
    setState(() {
      _isLoading=true;
    });
    try {
      AuthProvider.username = usernameController.text;
      AuthProvider.password = passwordController.text;

      final userProvider = UserProvider();
      final user = await userProvider.login(
        AuthProvider.username,
        AuthProvider.password,
        AuthProvider.connectionId,
      );

      AuthProvider.user = user;
      if (!validateAccountStatus(user)) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Greška"),
      content: const Text("Ovaj račun je deaktiviran ili nije odobren."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("U redu"),
        ),
      ],
    ),
  );
  return; 
}
      final roles = AuthProvider.user?.userRoles?.map((r) => r.role?.roleName).toList() ?? [];
      AuthProvider.isSignedIn = true;

      final companyEmployees = user.companyEmployees ?? [];
      final stores = user.stores ?? [];
    
      final signalRProvider = context.read<SignalRProvider>();

      if (roles.contains("Company Admin") && roles.contains("StoreAdministrator")) {
        final chosenRole = await showDialog<String>(
          barrierDismissible: false,

          context: context,
          builder: (context) => Card(
            borderOnForeground: true,
            surfaceTintColor: Colors.white,
            child: SimpleDialog(
            
              
            
              title:  Text("Dobrodošli ${AuthProvider.user?.firstName ?? ''} ${AuthProvider.user?.lastName ?? ''}!"),
              children: [
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, "Company Admin"),
                  child: const Text("Administrator firme"),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, "StoreAdministrator"),
                  child: const Text("Administrator trgovine"),
                ),
                 
              ],
            ),
          ),
        );

        if (chosenRole == "Company Admin") {
          
          if (companyEmployees.length > 1) {
            await showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text("Odaberite firmu:"),
                children: companyEmployees.map((company) {
                  return SimpleDialogOption(
                    onPressed: () async {
                      AuthProvider.selectedCompanyId = company.companyId;
                     if (!validateAccountStatus(user)) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Greška"),
      content: const Text("Ova firme je deaktivirana."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("U redu"),
        ),
      ],
    ),
  );
  return; 
}
                      await signalRProvider.startConnection();
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MasterScreen()),
                      );
                    },
                    child: Text(company.companyName ?? 'Nepoznata firma',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  );
                }).toList(),
              ),
            );
            return;
          }

          if (companyEmployees.length == 1) {
            AuthProvider.selectedCompanyId = companyEmployees.first.companyId;
            if (!validateAccountStatus(user)) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Greška"),
      content: const Text("Ova firma je deaktivirana."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("U redu"),
        ),
      ],
    ),
  );
  return; 
}
            await signalRProvider.startConnection();
          }
        } else if (chosenRole == "StoreAdministrator") {
          // --- STORE SELECTION ---
          if (stores.length > 1) {
            await showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text("Odaberite trgovinu:"),
                children: stores.map((store) {
                  return SimpleDialogOption(
                    onPressed: () async {
                      AuthProvider.selectedStoreId = store.storeId;
                      if (!validateAccountStatus(user)) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Greška"),
      content: const Text("Ovaj trgovina je deaktivirana ili nije odobrena."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("U redu"),
        ),
      ],
    ),
  );
  return; 
}
                      await signalRProvider.startConnection();
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MasterScreen()),
                      );
                    },
                    child: Text(store.storeName ?? 'Nepoznata trgovina',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  );
                }).toList(),
              ),
            );
            return;
          }

          if (stores.length == 1) {
            print(stores.length);
            AuthProvider.selectedStoreId = stores.first.storeId;
            if (!validateAccountStatus(user)) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Greška"),
      content: const Text("Ovaj trgovina je deaktivirana ili nije odobrena."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("U redu"),
        ),
      ],
    ),
  );
  return; 
}
            print(AuthProvider.selectedStoreId);
            await signalRProvider.startConnection();
          }
        }
       
      } else {
        // --- FALLBACK: only company OR only store logic (your existing one) ---
        if (companyEmployees.length > 1) {
          await showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              title: const Text("Odaberite firmu:"),
              children: companyEmployees.map((company) {
                return SimpleDialogOption(
                  onPressed: () async {
                    AuthProvider.selectedCompanyId = company.companyId;
                    if (!validateAccountStatus(user)) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Greška"),
      content: const Text("Ovaj račun je deaktiviran ili nije odobren."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("U redu"),
        ),
      ],
    ),
  );
  return; 
}
                    await signalRProvider.startConnection();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MasterScreen()),
                    );
                  },
                  child: Text(company.companyName ?? 'Nepoznata firma',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                );
              }).toList(),
            ),
          );
          return;
        }

        if (companyEmployees.length == 1) {
          AuthProvider.selectedCompanyId = companyEmployees.first.companyId;
          await signalRProvider.startConnection();
        }

        if (stores.length > 1) {
          await showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              title: const Text("Odaberite trgovinu:"),
              children: stores.map((store) {
                return SimpleDialogOption(
                  onPressed: () async {
                    AuthProvider.selectedStoreId = store.storeId;
                    if (!validateAccountStatus(user)) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Greška"),
      content: const Text("Ovaj račun je deaktiviran ili nije odobren."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("U redu"),
        ),
      ],
    ),
  );
  return; 
}
                    await signalRProvider.startConnection();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MasterScreen()),
                    );
                  },
                  child: Text(store.storeName ?? 'Nepoznata trgovina',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                );
              }).toList(),
            ),
          );
          return;
        }

        if (stores.length == 1) {
          AuthProvider.selectedStoreId = stores.first.storeId;
          if (!validateAccountStatus(user)) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Greška"),
      content: const Text("Ovaj račun je deaktiviran ili nije odobren."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("U redu"),
        ),
      ],
    ),
  );
  return; 
}
          await signalRProvider.startConnection();
        }
      }

      // --- FINAL NAVIGATION ---
      if (roles.contains("Admin") && AuthProvider.selectedCompanyId == null && AuthProvider.selectedStoreId == null) {
        await signalRProvider.startConnection();
      }

      debugPrint('Role(s): $roles');
      debugPrint('CompanyId: ${AuthProvider.selectedCompanyId}');
      debugPrint('StoreId: ${AuthProvider.selectedStoreId}');

      if (roles.contains("Admin") ||
          roles.contains("Company Admin") ||
          roles.contains("StoreAdministrator")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MasterScreen()),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) =>  AlertDialog(
            title: const Text("Greška"),
            content: const Text('Pogrešan email ili password'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
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
  child: const Text("Prijavi se",style: TextStyle(color: Colors.white),),
)


              ],
            ),
          ),
        ),
      );
    
   
  }
}



