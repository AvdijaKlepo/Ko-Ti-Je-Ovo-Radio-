import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/main.dart';
import 'package:ko_radio_mobile/models/company_employee.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/company_employee_provider.dart';
import 'package:ko_radio_mobile/providers/signalr_provider.dart';
import 'package:ko_radio_mobile/providers/user_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/messages.dart';
import 'package:ko_radio_mobile/screens/update_freelancer.dart';
import 'package:ko_radio_mobile/screens/user_company_apply.dart';
import 'package:ko_radio_mobile/screens/user_freelancer_apply.dart';
import 'package:ko_radio_mobile/screens/user_store_apply.dart';
import 'package:ko_radio_mobile/screens/user_update.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';

class Settings extends StatefulWidget {
 const Settings({super.key});



  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late UserProvider userProvider;
  late CompanyEmployeeProvider companyEmployeeProvider;
  late User user = AuthProvider.user!;

  SearchResult<CompanyEmployee>? companyEmployeeResult;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     companyEmployeeProvider = CompanyEmployeeProvider(); 
     userProvider = context.read<UserProvider>();

      _getUserById();
       _getEmployee();
    });

 
  }

 Future<void> _getUserById() async {
  try {
    var fetchedUser = await userProvider.getById(AuthProvider.user?.userId ?? 0);
    if(!mounted) return;
        setState(() {
      user = fetchedUser;
    });
    AuthProvider.user = fetchedUser;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}
  void _getEmployee() async {
    try {
      var filter = {'isApplicant:':true, 'userId:':AuthProvider.user?.userId};
      var fetchedEmployee = await companyEmployeeProvider.get(filter: filter);
      setState(() {
         companyEmployeeResult = fetchedEmployee;
      });
      
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
    

 
   
  
 @override
Widget build(BuildContext context) {

 int _companyEmployeeId = 
    AuthProvider.user?.companyEmployees?.isNotEmpty == true
        ? AuthProvider.user!.companyEmployees!.first.companyEmployeeId
        : 0;

  int _userId = AuthProvider.user?.userId ?? 0;

  int? _companyId = 
  AuthProvider.user?.companyEmployees?.isNotEmpty==true ? AuthProvider.user!.companyEmployees!.first.companyId : 0;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            InkWell(
              child:   ClipRRect(
              
              borderRadius: BorderRadius.circular(100),
              child: user.image!=null ?   
              imageFromString(user.image!,width: 100,height: 100)
              :
              
               Image.network(
                'https://www.gravatar.com/avatar/${_userId}?s=200&d=identicon',
                width: 100,
                height: 100,
              ),
            ),
            onTap: () async {
           final updated =    await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserUpdate(user: AuthProvider.user!),
                ),
              );
              if(updated==true){
                await _getUserById();
       
              }
              else if(updated==false){
                setState(() {
                  
                });
              }

            },
            
            ),
           const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${AuthProvider.user?.email}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 10,),
       
       
       const SizedBox(height: 10,),

     Card(
      color: Color.fromRGBO(27, 76, 125, 25),
      elevation: 2,
      margin: const EdgeInsets.all(5),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.white),
        title: const Text('Korisnički Račun',style: TextStyle(color: Colors.white),),
        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
        onTap: () async { 
          final updated = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UserUpdate(user: user,)),
        );
        if(updated==true){
          await _getUserById();
        }
        else if(updated==false){
          setState(() {
            
          });
        }
        },
      )
     ),
     if(AuthProvider.user?.freelancer?.freelancerId!=null) 
       Card(
      color: const Color.fromRGBO(27, 76, 125, 25),
      elevation: 2,
      margin: const EdgeInsets.all(5),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    
      child: ListTile(
        leading: const Icon(Icons.construction, color: Colors.white),
        title: const Text('Radnički Račun',style: TextStyle(color: Colors.white),),
        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
        onTap: () async { 
          final updated = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FreelancerUpdate(freelancer: AuthProvider.user?.freelancer,)),
        );
        if(updated==true){
          await _getUserById();
        }
        else if(updated==false){
          setState(() {
            
          });
        }
        },
      )
     ),

     
      Card(
      color: Color.fromRGBO(27, 76, 125, 25),
      elevation: 2,
      margin: const EdgeInsets.all(5),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.white),
        title: const Text('Odjava',style: TextStyle(color: Colors.white),),
        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
        onTap: () async { 
           AuthProvider.selectedRole = "";
                AuthProvider.connectionId = null;
                AuthProvider.isSignedIn = false;
                AuthProvider.user = null;
                AuthProvider.userRoles = null;
                AuthProvider.freelancer = null;
         
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
        },
      )
     ),
     SizedBox(height: 10,),

    Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  margin: const EdgeInsets.only(top: 12, bottom: 4),
  decoration: BoxDecoration(
    color: const Color.fromRGBO(27, 76, 125, 0.05), 
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    'Želite se prijaviti kao radnik? Imate svoju firmu?\nImate svoju trgovinu? Neka korisnici tačno saznaju Ko Im Je Ovo Radio.',
    style: TextStyle(
      color: const Color.fromRGBO(27, 76, 125, 1), 
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
),


     ExpansionTile(title: const Text('Prijave'),
     

     iconColor: Color.fromRGBO(27, 76, 125, 25),
     textColor: Color.fromRGBO(27, 76, 125, 25),
     collapsedTextColor: Colors.white,

     collapsedIconColor: Colors.white,
     collapsedBackgroundColor: Color.fromRGBO(27, 76, 125, 25),
     collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
     children: [
      if(AuthProvider.user?.freelancer?.freelancerId==null)
       Card(
      color: const Color.fromRGBO(27, 76, 125, 25),
      elevation: 2,
      margin: const EdgeInsets.all(5),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    
      child: ListTile(
        leading: const Icon(Icons.work, color: Colors.white),
        title: const Text('Prijava Radnika',style: TextStyle(color: Colors.white),),
        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
        onTap: () async { 
          final updated = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UserFreelancerApply(user: user,)),
        );
        if(updated==true){
          await _getUserById();
        }
        else if(updated==false){
          setState(() {
            
          });
        }
        },
      )
     ),

      Card(
      color: const Color.fromRGBO(27, 76, 125, 25),
      elevation: 2,
      margin: const EdgeInsets.all(5),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    
      child: ListTile(
        leading: const Icon(Icons.business, color: Colors.white),
        title: const Text('Prijava Firme',style: TextStyle(color: Colors.white),),
        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
        onTap: () async { 
          final updated = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UserCompanyApply(user: user,)),
        );
        if(updated==true){
          await _getUserById();
        }
        else if(updated==false){
          setState(() {
            
          });
        }
        },
      )
     ),
   
      Card(
      color: const Color.fromRGBO(27, 76, 125, 25),
      elevation: 2,
      margin: const EdgeInsets.all(5),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    
      child: ListTile(
        leading: const Icon(Icons.store, color: Colors.white),
        title: const Text('Prijava Trgovine',style: TextStyle(color: Colors.white),),
        trailing: const Icon(Icons.arrow_forward, color: Colors.white),
        onTap: () async { 
          final updated = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UserStoreApply(user: user,)),
        );
        if(updated==true){
          await _getUserById();
        }
        else if(updated==false){
          setState(() {
            
          });
        }
        },
      )
     ),

     ],
     ),
     

    


      
        if (companyEmployeeResult == null)
          const Center(child: CircularProgressIndicator())
        else if (companyEmployeeResult!.result.isEmpty || companyEmployeeResult!.result.first.isApplicant == false)
          const SizedBox.shrink()
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "U slučaju da niste imali dogovor, intervju ili niste već pripadnik ove organizacione jedinice, molimo da odbijete ovaj zahtjev!",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Firma: ${companyEmployeeResult!.result.first.companyName ?? 'Nepoznata'}'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: 'Prihvati',
                          onPressed: () async {
                            try {
                              companyEmployeeProvider.update(_companyEmployeeId,
                                  {
                                     "userId": _userId,
                                      "companyId": _companyId,
                                      "isDeleted": false,
                                      "isApplicant": false,
                                      
                                      "companyRoleId": null,
                                      "dateJoined": DateTime.now().toUtc().toIso8601String(),
                                  }
                              );
                               ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Zapošljenje uspješno!")),
          
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Odbaci',
                          onPressed: () async {
                         
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
}