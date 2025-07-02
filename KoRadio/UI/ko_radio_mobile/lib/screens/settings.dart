import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/main.dart';
import 'package:ko_radio_mobile/models/company_employee.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/company_employee_provider.dart';
import 'package:ko_radio_mobile/providers/signalr_provider.dart';
import 'package:ko_radio_mobile/screens/messages.dart';
import 'package:ko_radio_mobile/screens/user_company_apply.dart';
import 'package:ko_radio_mobile/screens/user_freelancer_apply.dart';
import 'package:ko_radio_mobile/screens/user_store_apply.dart';
import 'package:signalr_netcore/hub_connection.dart';

class Settings extends StatefulWidget {
 const Settings({super.key});



  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late HubConnection _hubConnection;
  late CompanyEmployeeProvider companyEmployeeProvider;
  SearchResult<CompanyEmployee>? companyEmployeeResult;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     companyEmployeeProvider = CompanyEmployeeProvider(); 
       _getEmployee();
    });

 
  }

  void _getEmployee() async {
    try {
      var filter = {'isApplicant:':true, 'userId:':AuthProvider.user?.userId};
      var fetchedEmployee = await companyEmployeeProvider.get(filter: filter);
      setState(() {
         companyEmployeeResult = fetchedEmployee;
      });
      
    } catch (e) {
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
        ElevatedButton(
          child: const Text('Odjava'),
          onPressed: () async {
            await _hubConnection.stop();
            AuthProvider.connectionId = null;
            AuthProvider.isSignedIn = false;
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginPage()));
          },
        ),
        ElevatedButton(
          child: const Text('Radnik prijava'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => UserFreelancerApply(user: AuthProvider.user)),
          ),
        ),
        ElevatedButton(
          child: const Text('Prijava Firme'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => UserCompanyApply(user: AuthProvider.user)),
          ),
        ),
          ElevatedButton(
          child: const Text('Prijava Trgovine'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => UserStoreApply(user: AuthProvider.user)),
          ),
        ),
        ElevatedButton(
          child: const Text('Poruke'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MessagesScreen()),
          ),
        ),

        const SizedBox(height: 32),

      
        if (companyEmployeeResult == null)
          const Center(child: CircularProgressIndicator())
        else if (companyEmployeeResult!.result.isEmpty || companyEmployeeResult!.result.first.isApplicant == false)
          SizedBox.shrink()
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
                            // Add rejection logic here
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