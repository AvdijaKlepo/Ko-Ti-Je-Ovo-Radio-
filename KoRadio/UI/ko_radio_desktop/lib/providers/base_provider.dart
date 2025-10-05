import 'dart:convert';



import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? baseUrl= const String.fromEnvironment("baseUrl", 
      defaultValue: "http://localhost:8080/");
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
  
  }
  

   Future<SearchResult<T>> get({
    dynamic filter,
    int? page,
    int? pageSize,
    String? orderBy,
    String? sortDirection,
  }) async {
    var url = "$baseUrl$_endpoint";

    Map<String, dynamic> queryParams = {};
    if (filter != null) {
      queryParams.addAll(filter);
    }
    if (page != null) {
      queryParams['page'] = page;
    }
    if (pageSize != null) {
      queryParams['pageSize'] = pageSize;
    }
    if (orderBy != null) {
      queryParams['orderBy'] = orderBy;
    }
    if (sortDirection != null) {
      queryParams['sortDirection'] = sortDirection;
    }

    if (queryParams.isNotEmpty) {
      var queryString = getQueryString(queryParams);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    // throw new Exception("Greška");
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();

      result.count = data['count'];

      for (var item in data['resultList']) {
        result.result.add(fromJson(item));
      }
   
      return result;
    } else {
      throw Exception("Unknown error");
    }
    // print("response: ${response.request} ${response.statusCode}, ${response.body}");
  }
  Future<T> insert(dynamic request) async {
    var url = "$baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
   Future<T> insertDTO(dynamic request) async {
    var url = "$baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
    Future delete(int id) async {
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      return;
    } else {
      throw Exception("Unknown error");
    }
  }
  Future<T> getById(int? id) async {
  if (id == null) throw Exception("ID must not be null");

  var url = "$baseUrl$_endpoint/$id"; 
  var uri = Uri.parse(url);
  var headers = createHeaders();

  var response = await http.get(uri, headers: headers);

  if (isValidResponse(response)) {
    var data = jsonDecode(response.body);

    return fromJson(data); 
  } else {
    throw Exception("Unknown error");
  }
}




  T fromJson(data) {
    throw Exception("Method not implemented");
  }

bool isValidResponse(Response response) {
  // Success
  if (response.statusCode < 300) return true;

  // Unauthorized
  if (response.statusCode == 401) {
    throw Exception("Unauthorized");
  }

  // Attempt to parse backend error messages
  try {
    final data = jsonDecode(response.body);

    if (data is Map) {
      // Handle explicit UserException from backend
      if (data.containsKey('exMessage')) {
        throw UserException(data['exMessage']);
      }

      // Handle ASP.NET ExceptionFilter errors
      if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstErrorList = errors[firstKey];
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            throw UserException(firstErrorList.first.toString());
          }
        }
      }

      // Generic message field
      if (data.containsKey('message')) {
        throw UserException(data['message']);
      }
    }

    // fallback if JSON but not expected format
    throw Exception("Sistemska greška, molimo pokušajte ponovo.");
  } catch (e) {
    // If decoding or type casting fails, fallback
    if (e is UserException) throw e; // preserve
    throw Exception("Sistemska greška, molimo pokušajte ponovo.");
  }
}


// Helper method to parse backend error and throw UserException
void _handleErrorResponse(Response response) {
  try {
    final data = jsonDecode(response.body);
    if (data is Map) {
      // Handle UserException via exMessage
      if (data.containsKey('exMessage')) {
        throw UserException(data['exMessage']);
      }
      // Handle ModelState errors from ASP.NET ExceptionFilter
      if (data.containsKey('errors')) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstErrorList = errors[firstKey] as List;
          if (firstErrorList.isNotEmpty) {
            throw UserException(firstErrorList.first.toString());
          }
        }
      }
      // Handle generic message key
      if (data.containsKey('message')) {
        throw UserException(data['message']);
      }
    }
    // fallback if response body is JSON but not expected format
    throw Exception("Sistemska greška, molimo pokušajte ponovo.");
  } catch (_) {
    // fallback if response.body is not JSON
    throw Exception("Sistemska greška, molimo pokušajte ponovo.");
  }
}





  Map<String, String> createHeaders() {
    String username = AuthProvider.username;
    String password = AuthProvider.password;



    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };

    return headers;
  }

  String getQueryString(Map params,
    {bool inRecursion = false}) {
  List<String> parts = [];

  params.forEach((key, value) {
    if (inRecursion) {
      if (key is int) {
        key = '[$key]';
      } else if (value is List || value is Map) {
        key = '.$key';
      } else {
        key = '.$key';
      }
    }

    if (value is String || value is int || value is double || value is bool) {
      var encoded = value is String ? Uri.encodeComponent(value) : value;
      parts.add('$key=$encoded');
    } else if (value is DateTime) {
      parts.add('$key=${value.toIso8601String()}');
    } else if (value is List || value is Map) {
      if (value is List) value = value.asMap();
      value.forEach((k, v) {
        parts.addAll(
            getQueryString({k: v}, inRecursion: true).split('&'));
      });
    }
  });

  return parts.join('&');
}

}
class UserException implements Exception {
  String exMessage;

  UserException(this.exMessage);

  @override
  String toString() => exMessage;
}
