import 'dart:convert';

import 'package:ko_radio_mobile/models/company.dart';
import 'package:ko_radio_mobile/models/company_recommended_dto.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/freelancer_recommended_dto.dart';
import 'package:ko_radio_mobile/models/product.dart';
import 'package:ko_radio_mobile/models/user.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

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

        "${BaseProvider.baseUrl}User/Login?username=$username&password=$password&connectionId=$connectionId";

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
      throw UserException("Unknown error");
    }
}
Future<List<FreelancerRecommendedDto>> getRecommended(int serviceId) async {
  var url = "${BaseProvider.baseUrl}User/RecommendedFreelancers/${AuthProvider.user?.userId}?serviceId=${serviceId}";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var response = await http.get(uri, headers: headers);

  if (isValidResponse(response)) {
    var data = jsonDecode(response.body) as List;
    return data.map((e) => FreelancerRecommendedDto.fromJson(e)).toList();
  } else {
    throw UserException("Unknown error");
  }
}
Future<List<CompanyRecommendedDto>> getRecommendedCompanies(int serviceId) async {
  var url = "${BaseProvider.baseUrl}User/RecommendedCompanies/${AuthProvider.user?.userId}?serviceId=${serviceId}";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var response = await http.get(uri, headers: headers);

  if (isValidResponse(response)) {
    var data = jsonDecode(response.body) as List;
    return data.map((e) => CompanyRecommendedDto.fromJson(e)).toList();
  } else {
    throw UserException("Unknown error");
  }
}
Future<List<Product>> getRecommendedProducts(int userId) async {
  var url = "${BaseProvider.baseUrl}User/RecommendedProducts/${AuthProvider.user?.userId}";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var response = await http.get(uri, headers: headers);

  if (isValidResponse(response)) {
    var data = jsonDecode(response.body) as List;
    return data.map((e) => Product.fromJson(e)).toList();
  } else {
    throw UserException("Unknown error");
  }
}


 
}
class UserException implements Exception {
  final String exMessage;

  UserException(this.exMessage);

  @override
  String toString() => exMessage;
}