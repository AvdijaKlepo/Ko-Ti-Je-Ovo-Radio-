
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/role.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/models/user_role.dart';

class AuthProvider {
  static String username="";
  static String password="";
  static User? user;
  static Role? role;
  static UserRole? userRoles;
  static Freelancer? freelancer;
  static String? connectionId;
  static bool isSignedIn = false;
}
