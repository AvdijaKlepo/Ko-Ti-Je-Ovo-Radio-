

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';



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
Future<void> openPdfFromString(String base64Pdf, {String fileName = "document.pdf"}) async {
  try {
    // Decode base64 to bytes
    final bytes = base64Decode(base64Pdf);

    // Save temporarily to device
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(bytes);

    // Open with system default PDF viewer
    await OpenFilex.open(file.path);
  } catch (e) {
    debugPrint("Error opening PDF: $e");
  }
}


void showPdfDialog(BuildContext context, String base64Pdf, {String title = "Dokument"}) {
  final Uint8List pdfBytes = base64Decode(base64Pdf);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Custom title bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color.fromRGBO(27, 76, 125, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // PDF Viewer
              Expanded(

                child: SfPdfViewer.memory(
  pdfBytes,
  initialZoomLevel: 0.5, // try between 0.5 - 0.8 for a good fit
)
,

              ),
            ],
          ),
        ),
      );
    },
  );
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
  int count = 0;

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

  Future<void> _fetchPage({Map<String, dynamic>? filter, bool replace=false}) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await fetcher(
        page: _page,
        pageSize: pageSize,
        filter: _activeFilter,
      );
      if(replace)
      {
        items = result.result;
      }
      else
      {
        items.addAll(result.result);
      }
      count = result.count;
    
        hasNextPage = false;
      
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> goToPage(int page, {Map<String, dynamic>? filter}) async {
    if(isLoading) return;
    _page = page;
    hasNextPage = true;
    items.clear();
    _activeFilter = filter;
    await _fetchPage(filter: filter,replace:true);
  }
}


class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // remove everything except digits and +
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9+]'), '');

    // format as +38761-234-312
    String formatted = digits;

    if (digits.startsWith('+387')) {
      // Only start formatting after +387
      final rest = digits.substring(4);

      if (rest.length > 2) {
        formatted = '+387' + rest.substring(0, 2);
        if (rest.length > 2) {
          formatted += '-' + rest.substring(2, rest.length > 5 ? 5 : rest.length);
        }
        if (rest.length > 5) {
          formatted += '-' + rest.substring(5, rest.length > 8 ? 8 : rest.length);
        }
        if (rest.length > 8) {
          formatted += '-' + rest.substring(8, rest.length > 11 ? 11 : rest.length);
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String formatPhoneNumber(String phone) {
  // Step 1: Replace +387 at the start with 0
  String normalized = phone.replaceFirst(RegExp(r'^\+387'), '0');

  // Step 2: Remove any non-digit characters (in case user inputs spaces, dashes, etc.)
  normalized = normalized.replaceAll(RegExp(r'\D'), '');

  // Step 3: Ensure we only format if we have at least 9 digits
  if (normalized.length < 9) return normalized;

  // Step 4: Insert dashes in 3-3-3 format
  String part1 = normalized.substring(0, 3);
  String part2 = normalized.substring(3, 6);
  String part3 = normalized.substring(6, 9);

  return "$part1-$part2-$part3";
}