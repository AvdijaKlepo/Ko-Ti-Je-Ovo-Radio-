import 'package:ko_radio_desktop/models/company.dart';
import 'package:ko_radio_desktop/models/role.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/models/user_role.dart';
import 'package:ko_radio_desktop/providers/signalr_provider.dart';

class AuthProvider {
  static String username="";
  static String password="";
  static User? user;
  static Role? role;
  static UserRole? userRoles;
  static String? connectionId;
  static bool isSignedIn = false;
  static int? selectedCompanyId;
  static int? selectedStoreId;
  static Company? selectedCompany;


  static String? getCompanyId() {
    return selectedCompanyId?.toString();
  }

  static setCompanyId(String? companyId) {
    selectedCompanyId = companyId == null ? null : int.parse(companyId);
  }

    SignalRProvider signalRProvider = SignalRProvider('notifications-hub');


    logout() {
    username="";
    password="";
    user=null;
    role=null;
    userRoles=null;
    connectionId=null;
    isSignedIn=false;
    selectedCompanyId=null;
    selectedStoreId=null;
    connectionId=null;

    signalRProvider.stopConnection();
    


  }
}
