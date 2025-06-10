

import 'dart:convert';

import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User>{
  UserProvider(): super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

   Future<User> login(
      String username, String password, String? connectionId) async {
    var url =

        "${BaseProvider.baseUrl}User/Login?username=${username}&password=${password}&connectionId=$connectionId";

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response;
    try {
      response = await http.post(uri, headers: headers);
    } on Exception catch (e) {
      throw new Exception("Greška prilikom prijave.");
    }
    if (username.isEmpty || password.isEmpty) {
      throw new Exception("Molimo unesite korisničko ime i lozinku.");
    }
    if (response.body == "") {
      throw new Exception("Pogrešno korisničko ime ili lozinka.");
    }
      print("API Response: ${response.body}"); // DEBUGGING OUTPUT

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error.");
    }
  }

    
}

  

