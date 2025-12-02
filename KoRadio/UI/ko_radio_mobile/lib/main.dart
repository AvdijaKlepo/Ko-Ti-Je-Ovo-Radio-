import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/bottom_nav_provider.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/company_job_assignemnt_provider.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
import 'package:ko_radio_mobile/providers/employee_task_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/location_provider.dart';
import 'package:ko_radio_mobile/providers/messages_provider.dart';
import 'package:ko_radio_mobile/providers/order_provider.dart';
import 'package:ko_radio_mobile/providers/product_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/signalr_provider.dart';
import 'package:ko_radio_mobile/providers/store_provider.dart';
import 'package:ko_radio_mobile/providers/tender_bid_provider.dart';
import 'package:ko_radio_mobile/providers/tender_provider.dart';
import 'package:ko_radio_mobile/providers/user_provider.dart';
import 'package:ko_radio_mobile/providers/user_ratings.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/registration.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';


final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ServiceProvider()),
      
      ChangeNotifierProvider(create: (_) => FreelancerProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => JobProvider()),
      ChangeNotifierProvider(create: (_) => BottomNavProvider()),
      ChangeNotifierProvider(create: (_) => LocationProvider()),
      ChangeNotifierProvider(create: (_) => MessagesProvider()),
      ChangeNotifierProvider(create: (_) => UserRatings()),
      ChangeNotifierProvider(create: (_) => CompanyProvider()),
      ChangeNotifierProvider(create: (_) => StoreProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
      ChangeNotifierProvider(create: (_) => TenderProvider()),
      ChangeNotifierProvider(create: (_) => TenderBidProvider()),
      ChangeNotifierProvider(create: (_) => EmployeeTaskProvider()),
      ChangeNotifierProvider(create: (_) => CompanyJobAssignmentProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
 
      ChangeNotifierProvider(create: (_) => SignalRProvider("notifications-hub")),
    ],
    child: const MyApp(),


  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Flutter Demo',
      supportedLocales: const[
      
        Locale('bs', 'Latn'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
     
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: const Color.fromRGBO(27, 76, 125, 25)),
            
        useMaterial3: true,
        fontFamily: GoogleFonts.robotoCondensed().fontFamily,
        
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

       try {               
  AuthProvider.username = usernameController.text;
  AuthProvider.password = passwordController.text;

  final userProvider = UserProvider();

  final user = await userProvider.login(
                              AuthProvider.username,
                              AuthProvider.password,
                              AuthProvider.connectionId);





 

    

    AuthProvider.user = user;
    
    final roles = AuthProvider.user?.userRoles?.map((r) => r.role?.roleName).toList() ?? [];
    final flag=false;
    AuthProvider.isSignedIn = true;

    if (user.userRoles == null || user.userRoles!.isEmpty) {
      throw Exception("Pogrešan email ili lozinka.");
    }
    String translateRole(String? roleName) {
  switch (roleName) {
    case 'User':
      return 'Korisnik';
    case 'Freelancer':
      return 'Radnik';
    case 'CompanyEmployee':
      return 'Zaposlenik firme';
    default:
      return 'Nepoznata uloga';
  }
}





    final filteredRoles = user.userRoles!.where((ur) =>
      ur.role?.roleName == "User" ||
      ur.role?.roleName == "Freelancer" ||
      ur.role?.roleName == "CompanyEmployee").toList();
      BottomNavProvider().setIndex(0);
   
    if (filteredRoles.length > 1) {
  await showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
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
        children: filteredRoles.map((userRole) {
          return SimpleDialogOption(
            onPressed: () async {
            
              AuthProvider.selectedRole = userRole.role?.roleName ?? "";

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

             
              final signalrProvider = context.read<SignalRProvider>();
              await signalrProvider.startConnection();
           

          
              Navigator.pop(context);

              
             final companyEmployees = user.companyEmployees ?? [];

if (AuthProvider.selectedRole == "CompanyEmployee" &&
    companyEmployees.length > 1) {

  final nonOwnerEmployees = companyEmployees.where((ce) => ce.isOwner != true).toList();



  await showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
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
        children: nonOwnerEmployees.map((ce) {
          return SimpleDialogOption(
            onPressed: () {
          
              AuthProvider.selectedCompanyId = ce.companyId;
              AuthProvider.selectedCompanyEmployeeId = ce.companyEmployeeId;
          
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MasterScreen()),
              );
            },
            child:  Container(
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
                        child: Text(ce.companyName ?? 'Nepoznata firma',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    ),
          );
        }).toList(),
      );
    },
  );
}
else {
  if(AuthProvider.selectedRole == "CompanyEmployee"){
   AuthProvider.selectedCompanyId = AuthProvider.user!.companyEmployees?.first.companyId;
      AuthProvider.selectedCompanyEmployeeId =AuthProvider.user!.companyEmployees?.first.companyEmployeeId;
  }
      print(AuthProvider.selectedCompanyId);
      print(AuthProvider.selectedCompanyEmployeeId);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MasterScreen()),
                );
              }
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
              child: Text(translateRole(userRole.role?.roleName),style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
          );
        }).toList(),
      );
    },
  );
}
 else {
   
      final selected = filteredRoles.first;
      AuthProvider.selectedRole = selected.role?.roleName ?? "";
      AuthProvider.userRoles = selected;
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
     
       final signalrProvider = context.read<SignalRProvider>();
                await signalrProvider.startConnection();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MasterScreen()),
      );
    }
  } catch (e) {
    
    showDialog(
    
    
      context: context,
      
      builder: (context) => AlertDialog(
        
        title: const Text("Greška"),
        content: const Text('Pogrešan email ili password.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("U redu"))
        ],
      ),
    );
  }
},


                      child: const Text("Login",style: TextStyle(color: Colors.white),)),
                      
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: ((context) => const RegistrastionScreen())));
                      },
                      child: const Text("Registracija",style: TextStyle(color: Colors.white)))
                ],
              ),
            ),
          ),
        );
      
    
  }
}