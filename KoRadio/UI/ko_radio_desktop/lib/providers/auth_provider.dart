import 'package:ko_radio_desktop/models/role.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/models/user_role.dart';

class AuthProvider {
  static String username="";
  static String password="";
  static User? user;
  static Role? role;
  static UserRole? userRoles;
  static String? connectionId;
  static bool isSignedIn = false;
}
