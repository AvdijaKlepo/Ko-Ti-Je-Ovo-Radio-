

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';


String formatNumber(dynamic) {
  var f = NumberFormat('###,##0.00', 'de_DE');
  if (dynamic == null) {
    return "";
  }
  return f.format(dynamic);
}


String formatDate(String date) {
  return DateFormat('dd-MM-yyyy').format(DateTime.parse(date).toLocal());
}

Image imageFromString(String input, {double? width, double? height, BoxFit? fit = BoxFit.cover, }) {
  return Image.memory(base64Decode(input), width: width, height: height,fit:fit,);
}


typedef PaginatedDataFetcher<T> = Future<PaginatedResult<T>> Function({
  required int page,
  required int pageSize,
  Map<String, dynamic>? filter,
});

class PaginatedResult<T> {
  final List<T> result;
  final int count;

  PaginatedResult({required this.result, required this.count});
}

class PaginatedFetcher<T> extends ChangeNotifier {
  final PaginatedDataFetcher<T> fetcher;
  final int pageSize;
  final Map<String, dynamic>? initialFilter;

  List<T> items = [];
  int _page = 1;
  bool isLoading = false;
  bool hasNextPage = true;

  Map<String, dynamic>? _activeFilter; 

  PaginatedFetcher({
    required this.fetcher,
    this.pageSize = 20,
    this.initialFilter,
  }) {
    _activeFilter = initialFilter; 
  }

  Future<void> refresh({Map<String, dynamic>? newFilter}) async {
    _page = 1;
    hasNextPage = true;
    items.clear();

    _activeFilter = newFilter ?? initialFilter; 
    await _fetchPage(filter: _activeFilter);
  }

  Future<void> loadMore() async {
    if (isLoading || !hasNextPage) return;
    _page++;
    await _fetchPage(filter: _activeFilter); 
  }

  Future<void> _fetchPage({Map<String, dynamic>? filter}) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await fetcher(
        page: _page,
        pageSize: pageSize,
        filter: _activeFilter,
      );
      items.addAll(result.result);
      if (items.length >= result.count) {
        hasNextPage = false;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
