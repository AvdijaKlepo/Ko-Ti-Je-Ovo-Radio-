import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ko_radio_mobile/main.dart';
import 'package:ko_radio_mobile/models/company_employee.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/bottom_nav_provider.dart';
import 'package:ko_radio_mobile/providers/cart_provider.dart';
import 'package:ko_radio_mobile/providers/company_employee_provider.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
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
  late FreelancerProvider freelancerProvider;
  late User user = AuthProvider.user!;
  SearchResult<User>? userResult;
  final ExpansionTileController _expansionTileController = ExpansionTileController();
  Freelancer? freelancer;

  SearchResult<CompanyEmployee>? companyEmployeeResult;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
     companyEmployeeProvider = CompanyEmployeeProvider(); 
     userProvider = context.read<UserProvider>();
     freelancerProvider = context.read<FreelancerProvider>();

      await _getUserById();
      await _getUser();
      await _getEmployee();
      if(AuthProvider.user?.freelancer?.freelancerId!=null)
      {
      await _getFreelancer();
      }
    });

 
  }

 Future<void> _getUserById() async {
  try {
    var fetchedUser = await userProvider.getById(AuthProvider.user?.userId ?? 0);
    if(!mounted) return;
        setState(() {
      user = fetchedUser;
    });
  
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}
 Future<void> _getUser() async {
  var filter = {'UserId': AuthProvider.user?.userId ?? 0};
  try {
    var fetchedUser = await userProvider.get(filter: filter);
    if(!mounted) return;
        setState(() {
      userResult = fetchedUser;
    });
  
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}
Future<void> _getFreelancer() async {
  try {
    var fetchedFreelancer = await freelancerProvider.getById(AuthProvider.user?.userId ?? 0);
    setState(() {
      freelancer = fetchedFreelancer;
    });
  } catch (e) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: ${e.toString()}")),
    );
  }
}
  Future<void> _getEmployee() async {
    try {
      var filter = {'IsApplicant':true, 'UserId':AuthProvider.user?.userId};
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

int _companyEmployeeId = (companyEmployeeResult?.result?.isNotEmpty ?? false)
    ? (companyEmployeeResult!.result.first.companyEmployeeId ?? 0)
    : 0;

int _userId = AuthProvider.user?.userId ?? 0;

int? _companyId = (companyEmployeeResult?.result?.isNotEmpty ?? false)
    ? (companyEmployeeResult!.result.first.companyId ?? 0)
    : null;


  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
       Row(
  children: [
    InkWell(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: user.image != null
            ? imageFromString(user.image!, width: 100, height: 100)
            : Image.network(
                'https://www.gravatar.com/avatar/${_userId}?s=200&d=identicon',
                width: 100,
                height: 100,
              ),
      ),
      onTap: () async {
        final updated = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserUpdate(user: AuthProvider.user!,locationId: userResult?.result.first.location?.locationId ?? 0,),
          ),
        );
        if (updated == true) {
          await _getUserById();
        } else if (updated == false) {
          setState(() {});
        }
      },
    ),
    const SizedBox(width: 10),
    // 👇 This ensures text shrinks inside remaining width
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user.firstName} ${user.lastName}',
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${AuthProvider.user?.email}',
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (user.freelancer?.freelancerId != null &&
              AuthProvider.selectedRole == "Freelancer" &&
              freelancer?.rating != 0)
            RatingBar.builder(
              itemSize: 30,
              initialRating: freelancer?.rating ?? 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              ignoreGestures: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (_) {},
            ),
        ],
      ),
    ),
  ],
),

        const SizedBox(height: 10,),
       
       
       const SizedBox(height: 10,),

     Card(
      color: const Color.fromRGBO(27, 76, 125, 25),
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
          MaterialPageRoute(builder: (_) => UserUpdate(user: user,locationId: userResult?.result.first.location?.locationId ?? 0,)),
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
     if(AuthProvider.selectedRole=="Freelancer") 
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
          MaterialPageRoute(builder: (_) => FreelancerUpdate(freelancer: AuthProvider.user?.freelancer)),
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
                SignalRProvider signalRProvider = context.read<SignalRProvider>();
                signalRProvider.stopConnection();

                CartProvider cartProvider = context.read<CartProvider>();
                cartProvider.clear();

               
         
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
        },
      )
     ),
     const SizedBox(height: 10,),

    Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  margin: const EdgeInsets.only(top: 12, bottom: 4),
  decoration: BoxDecoration(
    color: const Color.fromRGBO(27, 76, 125, 0.05), 
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Text(
    'Želite se prijaviti kao radnik? Imate svoju firmu?\nImate svoju trgovinu? Neka korisnici tačno saznaju Ko Im Je Ovo Radio.',
    style: TextStyle(
      color: Color.fromRGBO(27, 76, 125, 1), 
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
),


     ExpansionTile(
  title: const Text('Prijave'),
  controller: _expansionTileController,
  iconColor: const Color.fromRGBO(27, 76, 125, 25),
  textColor: const Color.fromRGBO(27, 76, 125, 25),
  collapsedTextColor: Colors.white,
  collapsedIconColor: Colors.white,
  collapsedBackgroundColor: const Color.fromRGBO(27, 76, 125, 25),
  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  children: [
    // Only show the "Apply as Freelancer" tile if the user is not already a freelancer
    if (user.freelancer?.freelancerId == null && AuthProvider.selectedRole != "Freelancer")
      Card(
        color: const Color.fromRGBO(27, 76, 125, 25),
        elevation: 2,
        margin: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: const Icon(Icons.work, color: Colors.white),
          title: const Text(
            'Prijava Radnika',
            style: TextStyle(color: Colors.white),
          ),
          trailing: const Icon(Icons.arrow_forward, color: Colors.white),
          onTap: () async {
            final message = ScaffoldMessenger.of(context);

            // Double-check just before navigation
            if (user.freelancer?.freelancerId != null) {
              message.showSnackBar(
                const SnackBar(content: Text("Već ste freelancer!")),
              );
              return;
            }

            final updated = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => UserFreelancerApply(user: user)),
            );

            if (updated == true) {
              _expansionTileController.collapse();
              await _getUserById();
              setState(() {});
            } else if (updated == false) {
              setState(() {});
            } 
          },
        ),
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
     

    


        const SizedBox(height: 30,),
        if (companyEmployeeResult == null)
          const Center(child: CircularProgressIndicator())
        else if (companyEmployeeResult!.result.isEmpty)
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
                                      "roles": [5],
                                      
                                      "companyRoleId": null,
                                      "dateJoined": DateTime.now().toIso8601String(),
                                  }
                              );
                            
                               ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Zapošljenje uspješno!")),
          
        );
        await _getEmployee();
        
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
                            try{
                              await companyEmployeeProvider.delete(_companyEmployeeId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Zahtjev odbijen.")),
                              );
                              await _getEmployee();
                            }
                            catch(e){
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Greška. Molimo pokušajte ponovo.")),
                              );
                            }
                           
                         
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