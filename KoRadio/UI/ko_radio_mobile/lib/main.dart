import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/bottom_nav_provider.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/company_provider.dart';
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
import 'package:ko_radio_mobile/screens/freelancer_job_screen.dart';
import 'package:ko_radio_mobile/screens/registration.dart';
import 'package:ko_radio_mobile/screens/service_list.dart';
import 'package:provider/provider.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() {
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
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: const Color.fromRGBO(27, 76, 125, 25)),
            
        useMaterial3: true,
        fontFamily: GoogleFonts.roboto().fontFamily,
        
      ),
      home: Center(
        child: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  

  @override
  void initState() { 
     final SignalRProvider _signalRProvider = SignalRProvider('notifications-hub');
     if (AuthProvider.isSignedIn) {
      _signalRProvider.stopConnection();
      AuthProvider.connectionId = null;
      AuthProvider.isSignedIn = false;
    }
    _signalRProvider.startConnection();
    _signalRProvider.onNotificationReceived = (message) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );
};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                  ),
                  TextField(
                    controller: usernameController,
                   
                    decoration: const InputDecoration(
                        labelText: "Username", prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.password)),
                  ),
                  ElevatedButton(
                   onPressed: () async {
  AuthProvider.username = usernameController.text;
  AuthProvider.password = passwordController.text;

  try {
    UserProvider userProvider = UserProvider();
    SignalRProvider signalRProvider = SignalRProvider('notifications-hub');
 

    var user = await userProvider.login(
        AuthProvider.username, AuthProvider.password, AuthProvider.connectionId);

    AuthProvider.user = user;
    AuthProvider.isSignedIn = true;
   signalRProvider.startConnection();

    if (user.userRoles == null || user.userRoles!.isEmpty) {
      throw Exception("Korisnik nema dodijeljenih uloga.");
    }


    final filteredRoles = user.userRoles!.where((ur) =>
      ur.role?.roleName == "User" ||
      ur.role?.roleName == "Freelancer" ||
      ur.role?.roleName == "CompanyEmployee").toList();


    if (filteredRoles.length > 1) {
      await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text("Odaberite ulogu"),
          children: filteredRoles.map((userRole) {
            return SimpleDialogOption(
              onPressed: () {
                AuthProvider.selectedRole = userRole.role?.roleName ?? "";
                print(AuthProvider.selectedRole);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MasterScreen()),
                );
              },
              child: Text(userRole.role?.roleName ?? "Nepoznata uloga"),
            );
          }).toList(),
        ),
      );
    } else {
   
      final selected = filteredRoles.first;
      AuthProvider.selectedRole = selected.role?.roleName ?? "";
      AuthProvider.userRoles = selected;

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
        content: Text(e.toString()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("U redu"))
        ],
      ),
    );
  }
},


                      child: const Text("Login")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: ((context) => const RegistrastionScreen())));
                      },
                      child: const Text("Registracija"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}