import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/user_provider.dart';
import 'package:ko_radio_mobile/screens/freelancer_job_screen.dart';
import 'package:ko_radio_mobile/screens/registration.dart';
import 'package:ko_radio_mobile/screens/service_list.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_)=>ServiceProvider()),
    ChangeNotifierProvider(create: (_)=>FreelancerProvider()),
    ChangeNotifierProvider(create: (_)=>UserProvider()),
    ChangeNotifierProvider(create: (_)=>JobProvider()),

  ],
  child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.blue, primary: const Color.fromRGBO(27, 76, 125, 25)),
        useMaterial3: true,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                   "assets/images/logo.png",
                   
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                        labelText: "Username", prefixIcon: Icon(Icons.email)),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      
                        labelText: "Password",
                        prefixIcon: Icon(Icons.password)),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        var provider = UserProvider();
                        AuthProvider.username = usernameController.text;
                        AuthProvider.password = passwordController.text;

                        try {
                          
                          UserProvider userProvider = new UserProvider();

                          var user = await userProvider.login(AuthProvider.username, AuthProvider.password);

                          AuthProvider.user = user;

                     

                          AuthProvider.user?.userId = user.userId;
                          AuthProvider.user?.firstName = user.firstName;
                          AuthProvider.user?.lastName = user.lastName;
                          AuthProvider.userRoles = user.userRoles?.isNotEmpty == true ? user.userRoles!.first : null;

                          //AuthProvider.userRole = user.userRole;

                          print('UserId: ${AuthProvider.userRoles?.role.roleName}');
                    

                
                         if (
                                  AuthProvider.userRoles!.role.roleName=="Administrator") {
                                    print(AuthProvider.userRoles!.role.roleName);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ServiceListScreen(),
                                ));
                                  }
               
                          
                        
                         
                        } on Exception catch (e) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text("Error"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("Ok"))
                                    ],
                                    content: Text(e.toString()),
                                  ));
                        }
                        try{
                          if (
                                  AuthProvider.userRoles!.role.roleName=="Freelancer") {
                                    print(AuthProvider.userRoles!.role.roleName);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FreelancerJobsScreen(),
                                ));
                                  }
                            
                          //var data = await provider.get();
                          //AuthProvider.user?.firstName =
                            //  data.result['resultList'].firstName;

                          //Navigator.of(context).push(MaterialPageRoute(
                           //   builder: (context) => MasterScreen()));
                          
                        
                         
                        } on Exception catch (e) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text("Error"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("Ok"))
                                    ],
                                    content: Text(e.toString()),
                                  ));

                                  
                        }
                         try{
                          if (
                                  AuthProvider.userRoles!.role.roleName=="User") {
                                    print(AuthProvider.userRoles!.role.roleName);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ServiceListScreen(),
                                ));
                                  }
                            
                          //var data = await provider.get();
                          //AuthProvider.user?.firstName =
                            //  data.result['resultList'].firstName;

                          //Navigator.of(context).push(MaterialPageRoute(
                           //   builder: (context) => MasterScreen()));
                          
                        
                         
                        } on Exception catch (e) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text("Error"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("Ok"))
                                    ],
                                    content: Text(e.toString()),
                                  ));

                                  
                        }
                       
                        

                      },
                      child: Text("Login")),
                      ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: ((context) => RegistrastionScreen())));
                      },
                      child: Text("Registracija"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



