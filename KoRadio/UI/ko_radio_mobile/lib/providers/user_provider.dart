import 'dart:convert';

import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User>{
  UserProvider(): super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  
  }
   Future<User> login(
      String username, String password) async {
    var url =

        "${BaseProvider.baseUrl}User/Login?username=$username&password=$password";

    var uri = Uri.parse(url);
    var headers = createHeaders();

    http.Response response;
    try {
      response = await http.post(uri, headers: headers);
    } on Exception {
      throw Exception("Greška prilikom prijave.");
    }
    if (username.isEmpty || password.isEmpty) {
      throw Exception("Molimo unesite korisničko ime i lozinku.");
    }
    if (response.body == "") {
      throw Exception("Pogrešno korisničko ime ili lozinka.");
    }
      print("API Response: ${response.body}"); 

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error.");
    }
  }

  Future<User> registration(Map<dynamic, dynamic> data) async {
  var url = "${BaseProvider.baseUrl}User/Registration";
  var uri = Uri.parse(url);
  var headers = {
    ...createHeaders(),
    "Content-Type": "application/json",
  };

  var jsonRequest = jsonEncode(data);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new UserException("Unknown error");
    }
}

 
}
class UserException implements Exception {
  final String exMessage;

  UserException(this.exMessage);

  @override
  String toString() => exMessage;
}