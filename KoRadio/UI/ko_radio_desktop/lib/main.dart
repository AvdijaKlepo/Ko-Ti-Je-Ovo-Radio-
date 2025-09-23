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
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ko Ti Je Ovo Radio?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontFamily: GoogleFonts.lobster().fontFamily,
                letterSpacing: 1.2,
                color: const Color.fromRGBO(27, 76, 125, 1),
                
              ),
            ),
            const SizedBox(height: 32),

            // Username
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(
                  color: Color.fromRGBO(27, 76, 125, 1),
                ),
                labelText: "Email adresa",
                prefixIcon: const Icon(
                  Icons.email,
                  color: Color.fromRGBO(27, 76, 125, 1),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(
                  color: Color.fromRGBO(27, 76, 125, 1),
                ),
                labelText: "Lozinka",
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Color.fromRGBO(27, 76, 125, 1),
                ),
              ),
            ),
            const SizedBox(height: 24),
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

      final companyEmployees = user.companyEmployees?.where((element) => element.isOwner==true) ?? [];
      final stores = user.stores ?? [];
    
      final signalRProvider = context.read<SignalRProvider>();

      if (roles.contains("Company Admin") && roles.contains("StoreAdministrator")) {
        final chosenRole = await showDialog<String>(
          barrierDismissible: true,


          context: context,
          builder: (context) => SimpleDialog(
           
          
             surfaceTintColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
          
            title: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Odabir uloge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(onPressed: () {  
              Navigator.of(context, rootNavigator: true).pop();
                
              
              }, icon: const Icon(Icons.close, color: Colors.white)),
            ],
          )),
            children: [
              Center(child: Text("Dobrodošli ${AuthProvider.user?.firstName ?? ''} ${AuthProvider.user?.lastName ?? ''}")),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: user.image!=null ?
                imageFromString(user.image!,width: 100,height: 100,fit: BoxFit.contain,)
                : const Image(image: AssetImage('assets/images/Sample_User_Icon.png'),fit: BoxFit.contain, width: 100, height: 100,),
              ),
              SimpleDialogOption(

                onPressed: () => Navigator.pop(context, "Company Admin"),
                child: Container(
                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
           borderRadius: BorderRadius.all( Radius.circular(16)),
          ),
                  
                  child: const Center(child: Text("Administrator firme", style: TextStyle(fontSize: 16,color: Colors.white)))),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, "StoreAdministrator"),
                child: Container(
                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.all( Radius.circular(16)),
          ),
                  
                  child: const Center(child: Text("Administrator trgovine", style: TextStyle(fontSize: 16,color: Colors.white)))),
              ),
               
            ],
          ),
        );
        if(chosenRole==null || chosenRole=="cancel") return;

        if (chosenRole == "Company Admin") {
          
          if (companyEmployees.length > 1) {
            await showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                  surfaceTintColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
               title: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Odabirite firmu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(onPressed: () {  
              Navigator.of(context, rootNavigator: true).pop();
                
              
              }, icon: const Icon(Icons.close, color: Colors.white)),
            ],
          )),
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
                    child: Container(
                       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.all( Radius.circular(16)),
          ),
                      child: Center(
                        child: Text(company.companyName ?? 'Nepoznata firma',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    ),
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
      
          if (stores.length > 1) {
            await showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                surfaceTintColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
               title: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Odabirite trgovinu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(onPressed: () {  
              Navigator.of(context, rootNavigator: true).pop();
                
              
              }, icon: const Icon(Icons.close, color: Colors.white)),
            ],
          )),
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
                    child: Container(
                       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.all( Radius.circular(16)),
          ),
                      child: Center(
                        child: Text(store.storeName ?? 'Nepoznata trgovina',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    ),
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



