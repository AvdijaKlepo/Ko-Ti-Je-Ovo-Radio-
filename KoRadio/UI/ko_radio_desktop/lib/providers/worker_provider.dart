import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';

class WorkerProvider {
  WorkerProvider() {}
  Future<dynamic> get() async {
    var url = "http://localhost:5053/Worker?isNameIncluded=true";
    var uri = Uri.parse(url);
    var response = await http.get(uri /*,headers:createHeaders(); */);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw new Exception("Data invalid");
    }
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unauthorized");
    } else {
      throw new Exception("Server not responding.");
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    String basicAuth =
        "Basic ${base64Encode(utf8.encode("$username:$password"))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };

    return headers;
  }
}
