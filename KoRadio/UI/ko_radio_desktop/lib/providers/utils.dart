

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:ko_radio_desktop/layout/master_screen.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/signalr_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
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
 DateTime parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }
    List<String> localizeWorkingDays(List<dynamic>? days) {
  if (days == null) return [];

  const dayNamesHR = [
    "Nedjelja",
    "Ponedjeljak",
    "Utorak",
    "Srijeda",
    "Četvrtak",
    "Petak",
    "Subota"
  ];

  const mapping = {
    "Sunday": "Nedjelja",
    "Monday": "Ponedjeljak",
    "Tuesday": "Utorak",
    "Wednesday": "Srijeda",
    "Thursday": "Četvrtak",
    "Friday": "Petak",
    "Saturday": "Subota"
  };

  return days.map((d) {
    if (d is int && d >= 0 && d <= 6) return dayNamesHR[d];
    if (d is String) return mapping[d] ?? d;
    return d.toString();
  }).toList();
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
final dayNamesMap = {
    0: 'Nedjelja',
    1: 'Ponedjeljak',
    2: 'Utorak',
    3: 'Srijeda',
    4: 'Četvrtak',
    5: 'Petak',
    6: 'Subota',
  };

  final shortDayNamesMap = {
    0: 'Ned',
    1: 'Pon',
    2: 'Uto',
    3: 'Sri',
    4: 'Čet',
    5: 'Pet',
    6: 'Sub',
  };

  List<String> getWorkingDaysShort(List<dynamic>? workingDays) {
  final localized = localizeWorkingDays(workingDays);

  return localized.map((day) {
    return shortDayNamesMap[day] ?? 
           (day.length > 3 ? day.substring(0, 3) : day);
  }).toList();
}
bool validateAccountStatus(User user) {
  if (user.isDeleted == true) {
    return false;
  }

  // --- STORES ---
  final stores = user.stores ?? [];
  if (AuthProvider.selectedStoreId != null) {
    final selectedStore = stores.firstWhere(
      (s) => s.storeId == AuthProvider.selectedStoreId,
     
    );
    if (selectedStore != null) {
      if (selectedStore.isDeleted == true || selectedStore.isApplicant == true) {
        return false;
      }
    }
  }

  // --- COMPANIES ---
  final companies = user.companyEmployees ?? [];
  if (AuthProvider.selectedCompanyId != null) {
    final selectedCompany = companies.firstWhere(
      (c) => c.companyId == AuthProvider.selectedCompanyId,
      
    );
    if (selectedCompany != null) {
      if (selectedCompany.isDeleted == true ||
          selectedCompany.isApplicant == true ||
          (selectedCompany.company?.isDeleted == true)) {
        return false;
      }
    }
  }

  return true; 
}


List<String> getWorkingDaysInRange({
  required DateTime jobDate,
  required DateTime dateFinished,
  required List<String> workingDays,
}) {

  final normalized =  workingDays.map((d) => d.toLowerCase()).toSet();

  final result = <String>[];
  DateTime current = jobDate;

  while (!current.isAfter(dateFinished)) {
    final dayName = _dayName(current.weekday); 
    if (normalized.contains(dayName.toLowerCase())) {
      result.add(dayName);
    }
    current = current.add(const Duration(days: 1));
  }

  return localizeWorkingDays(result);
}

String _dayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return "Monday";
    case DateTime.tuesday:
      return "Tuesday";
    case DateTime.wednesday:
      return "Wednesday";
    case DateTime.thursday:
      return "Thursday";
    case DateTime.friday:
      return "Friday";
    case DateTime.saturday:
      return "Saturday";
    case DateTime.sunday:
      return "Sunday";
    default:
      return "";
  }
}


void showPdfDialog(BuildContext context, String base64Pdf, String title) {
  final Uint8List pdfBytes = base64Decode(base64Pdf);
  final PdfViewerController pdfController = PdfViewerController();

  showDialog(
    context: context,
    builder: (context) {
      final size = MediaQuery.of(context).size;

      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: SizedBox(
          width: size.width * 0.7,
          height: size.height * 0.85,
          child: Column(
            children: [
              // Title bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color.fromRGBO(27, 76, 125, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                  controller: pdfController,
                  pageLayoutMode: PdfPageLayoutMode.single, // center each page
                  canShowScrollHead: true,
                  canShowPaginationDialog: true,
                  enableDoubleTapZooming: true,
                  initialZoomLevel: 1.0, // start at 100%
                ),
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

Future<void> _showWelcomeDialog(BuildContext context, User user) async {
  final signalRProvider = context.read<SignalRProvider>();
  final roles = user.userRoles?.map((r) => r.role?.roleName).whereType<String>().toList() ?? [];
  final companyEmployees = user.companyEmployees ?? [];
  final stores = user.stores ?? [];

  String? selectedRole;
  int? selectedCompanyId;
  int? selectedStoreId;

  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text("Dobrodošli ${user.firstName ?? ''} ${user.lastName ?? ''}!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  
                  child: user.image != null
                      ? imageFromString(user.image!, width: 40, height: 40)
                      : const Image(
                          image: AssetImage(
                            'assets/images/Sample_User_Icon.png',
                          ),
                          fit: BoxFit.contain,
                          width: 40,
                          height: 40,
                        ),
                ),
                      
                
                const SizedBox(height: 16),

                // Role selection
                if (roles.length > 1)
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: "Odaberite ulogu"),
                    items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setState(() => selectedRole = val),
                  )
                else if (roles.length == 1)
                  Builder(builder: (_) {
                    selectedRole = roles.first;
                    return Text("Uloga: ${roles.first}");
                  }),

                const SizedBox(height: 12),

                // Company selection if role is Company Admin
                if (selectedRole == "Company Admin" && companyEmployees.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: selectedCompanyId,
                    decoration: const InputDecoration(labelText: "Odaberite firmu"),
                    items: companyEmployees
                        .map((c) => DropdownMenuItem(
                              value: c.companyId,
                              child: Text(c.companyName ?? "Nepoznata firma"),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCompanyId = val),
                  ),

                // Store selection if role is StoreAdministrator
                if (selectedRole == "StoreAdministrator" && stores.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: selectedStoreId,
                    decoration: const InputDecoration(labelText: "Odaberite trgovinu"),
                    items: stores
                        .map((s) => DropdownMenuItem(
                              value: s.storeId,
                              child: Text(s.storeName ?? "Nepoznata trgovina"),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedStoreId = val),
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  // Validation logic identical to your old dialogs
                  if (selectedRole == "Company Admin") {
                    if (companyEmployees.length == 1) {
                      AuthProvider.selectedCompanyId = companyEmployees.first.companyId;
                    } else if (selectedCompanyId != null) {
                      AuthProvider.selectedCompanyId = selectedCompanyId;
                    } else {
                      return; // keep dialog open until chosen
                    }
                  } else if (selectedRole == "StoreAdministrator") {
                    if (stores.length == 1) {
                      AuthProvider.selectedStoreId = stores.first.storeId;
                    } else if (selectedStoreId != null) {
                      AuthProvider.selectedStoreId = selectedStoreId;
                    } else {
                      return;
                    }
                  }

                  // Account validation check
                  if (!validateAccountStatus(user)) {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text("Greška"),
                        content: Text("Ovaj račun ili entitet je deaktiviran."),
                      ),
                    );
                    return;
                  }

                  await signalRProvider.startConnection();
                  Navigator.pop(context); // close welcome dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MasterScreen()),
                  );
                },
                child: const Text("Nastavi"),
              ),
            ],
          );
        },
      );
    },
  );
}
