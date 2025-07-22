import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? baseUrl = const String.fromEnvironment("baseUrl",
      defaultValue: "http://10.0.2.2:5053/");
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
      throw new Exception("Unknown error");
    }
    // print("response: ${response.request} ${response.statusCode}, ${response.body}");
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

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

 bool isValidResponse(Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return true;
  }

  String message = "Unknown error";

  try {
    var json = jsonDecode(response.body);
    if (json is Map<String, dynamic> && json.containsKey("errors")) {
      // Flatten error messages into a single string
      final errors = (json["errors"] as Map).values.expand((v) => v).join('\n');
      message = errors;
    }
  } catch (_) {
    message = response.body; 
  }

  throw Exception(message);
}


  Map<String, String> createHeaders() {
   String username = AuthProvider.username ?? "";
  String password = AuthProvider.password ?? "";

  var headers = {
    "Content-Type": "application/json",
  };

  if (username.isNotEmpty && password.isNotEmpty) {
    String basicAuth = "Basic ${base64Encode(utf8.encode('$username:$password'))}";
    headers["Authorization"] = basicAuth;
  }

  return headers;
  }

  String getQueryString(Map params,
      {String prefix = '&', bool inRecursion = false}) {
    String query = '';
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
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }
}

class UserException implements Exception {
  final String exMessage;

  UserException(this.exMessage);

  @override
  String toString() => exMessage;
}
