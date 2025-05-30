import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/auth_provider.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? baseUrl = const String.fromEnvironment("baseUrl",
      defaultValue: "http://localhost:5053/");
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$baseUrl$_endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
  //  print("response: ${response.request} ${response.statusCode}, ${response.body}");

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

  Future<SearchResult<T>> getById(int? id, {dynamic filter}) async {
    var url = "$baseUrl$_endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString/$id";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

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
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      print(response.body);
      throw Exception("Something bad happened please try again");
    }
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
