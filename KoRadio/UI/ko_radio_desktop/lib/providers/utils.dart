

import 'dart:convert';

import 'package:flutter/widgets.dart';





Image imageFromString(String input) {
  return Image.memory(base64Decode(input));
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

  PaginatedFetcher({
    required this.fetcher,
    this.pageSize = 20,
    this.initialFilter,
  });

  Future<void> refresh({Map<String, dynamic>? newFilter}) async {
    _page = 1;
    hasNextPage = true;
    items.clear();
    await _fetchPage(filter: newFilter ?? initialFilter);
  }

  Future<void> loadMore() async {
    if (isLoading || !hasNextPage) return;
    _page++;
    await _fetchPage(filter: initialFilter);
  }

  Future<void> _fetchPage({Map<String, dynamic>? filter}) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await fetcher(
        page: _page,
        pageSize: pageSize,
        filter: filter,
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