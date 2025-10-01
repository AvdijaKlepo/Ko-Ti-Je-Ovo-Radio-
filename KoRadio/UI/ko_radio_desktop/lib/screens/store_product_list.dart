import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/product.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';
import 'package:ko_radio_desktop/providers/product_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/product_add_update_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class StoreProductList extends StatefulWidget {
  const StoreProductList({super.key});

  @override
  State<StoreProductList> createState() => _StoreProductListState();
}

class _StoreProductListState extends State<StoreProductList> {
  late ProductProvider productProvider;
  late ServiceProvider serviceProvider;
  late PaginatedFetcher<Product> productPagination;
  late StoreProvider storeProvider;
  int currentPage=1;
  SearchResult<Product>? productResult;
  SearchResult<Service>? serviceResult;

  final TextEditingController _productNameController = TextEditingController();
  bool showDeleted = false;
  bool _isInitialized = false;
  bool isLoading = false;
  Timer? _debounce;
  int? selectedServiceId;
  Set<int> selectedProductIds = {};
  String? _base64Image;
  File? _pdfFile;
String? _base64Pdf;



  @override
  void initState() {
    super.initState(); 
    setState(() {
      isLoading=true;
    });
   
    productPagination = PaginatedFetcher<Product>(
      pageSize: 20,
      initialFilter: {},
      fetcher: ({
        required int page,
        required int pageSize,
        Map<String, dynamic>? filter,
        
      }) async {
        final result = await productProvider.get(filter: filter);
        return PaginatedResult(result: result.result, count: result.count);
      },
    );
      productProvider = context.read<ProductProvider>();
      serviceProvider = context.read<ServiceProvider>();
      storeProvider = context.read<StoreProvider>();
      productPagination = PaginatedFetcher<Product>(
        pageSize: 18,
        initialFilter: {},
        fetcher: ({
          required int page,
          required int pageSize,
          Map<String, dynamic>? filter,
          
        }) async {
          final result = await productProvider.get(filter: filter);
          return PaginatedResult(result: result.result, count: result.count);
        },
      );
      productPagination.addListener(() {
        if(!mounted) return;
        setState(() {});
      });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
      });
      await productPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'storeId': AuthProvider.selectedStoreId,
        'SortDirection': 'asc',
      });
      await _getServices();
      final now = DateTime.now();
  final expiredSales = productPagination.items
      .where((p) => p.saleExpires != null && p.saleExpires!.isBefore(now) && p.isOnSale==true)
      .toList();

  try {
  if (expiredSales.isNotEmpty) {
    for (var p in expiredSales) {
      await productProvider.update(p.productId, {
        'productName': p.productName,
        'productDescription': p.productDescription,
        'price': p.price,
        'stockQuantity': p.stockQuantity,
        'isOnSale': false,
        'salePrice': null,
        'saleExpires': null,
        'isDeleted': false,
        'image': p.image,
        'serviceId': p.productsServices?.map((ps) => ps.serviceId).toList(),
      });
    }
    

    await productPagination.refresh(newFilter: {
      'isDeleted': showDeleted,
      'storeId': AuthProvider.selectedStoreId,
      'SortDirection': 'asc',
    });
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Akcija je završila. Proizvodi vraćeni regularnoj cijeni.")),
    );
  }
} on Exception catch (e) {
  if(!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Došlo je do greške tokom ažuriranja akcije. Pokušajte ponovo.")),
  );
}
      if(!mounted) return;
      setState(() {
        _isInitialized = true;
        isLoading = false;
      });

  
    });
    
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _productNameController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1), _refreshWithFilter);
  }
  void _toggleProductSelection(Product p, bool? selected) {
  setState(() {
    if (selected == true) {
      selectedProductIds.add(p.productId);
    } else {
      selectedProductIds.remove(p.productId);
    }
  });
}
Future<void> _refreshWithFilter() async {
  setState(() => isLoading = true);

  final filter = <String, dynamic>{
    'isDeleted': showDeleted,
    'storeId': AuthProvider.selectedStoreId,
  };

  if (_productNameController.text.trim().isNotEmpty) {
    filter['Name'] = _productNameController.text.trim();
  }
  if (selectedServiceId != null) {
    filter['ServiceId'] = selectedServiceId;
  }

  await productPagination.refresh(newFilter: filter);

  if (!mounted) return;
  setState(() => isLoading = false);
}


  final storeId = AuthProvider.selectedStoreId;

  Future<void> _getServices() async {
  try {
    final result = await serviceProvider.get();
    if (!mounted) return;
    setState(() => serviceResult = result);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

  Future<void> _openProductDialog({Product? product}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ProductDetailsDialog(product: product),
    );
    if (result == true) {
      await productPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'storeId': AuthProvider.selectedStoreId,
        'SortDirection': 'asc',
      });
    }
  }

  Future<void> _getProducts() async {
  final filter = {
    'isDeleted': showDeleted,
    'storeId': storeId,
    if (selectedServiceId != null) 'serviceId': selectedServiceId,
    if (_productNameController.text.trim().isNotEmpty)
      'productName': _productNameController.text.trim(),
  };

  try {
    final result = await productProvider.get(filter: filter);
    if (!mounted) return;
    setState(() => productResult = result);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

    void _openUserDeleteDialog({required Product product}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Izbriši?'),
      content: const Text('Jeste li sigurni da želite izbrisati ovaj proizvod?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Ne'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await productProvider.delete(product.productId);
              await productPagination.refresh(newFilter: {
                'isDeleted': showDeleted,
                'storeId': AuthProvider.selectedStoreId,
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Proizvod je uspješno izbrisan.")),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        "Greška tokom brisanja podataka. Pokušajte ponovo.")),
              );
            }
            if (!mounted) return;
            Navigator.of(context).pop(true);
          },
          child: const Text('Da'),
        ),
      ],
    ),
  );
}


void _openUserRestoreDialog({required Product product}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Vrati?'),
      content: const Text('Jeste li sigurni da želite vratiti ovaj proizvod?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Ne'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await productProvider.delete(product.productId);
              await productPagination.refresh(newFilter: {
                'isDeleted': showDeleted,
                'storeId': AuthProvider.selectedStoreId,
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Proizvod je uspješno reaktiviran.")),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        "Greška tokom brisanja podataka. Pokušajte ponovo.")),
              );
            }
            if (!mounted) return;
            Navigator.of(context).pop(true);
          },
          child: const Text('Da'),
        ),
      ],
    ),
  );
}


  Future<void> _openUserSaleDialog(Product product) async {
     final formKey = GlobalKey<FormBuilderState>();

  final result = await showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Akcija za${product.productName}"),
      content: FormBuilder(
        key: formKey,
        child: SingleChildScrollView(
         
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'salePrice',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Postotak sniženja (%)",
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(1),
                  FormBuilderValidators.max(100),
                ]),
              ),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(

                name: 'saleExpires',
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                inputType: InputType.date,
                decoration: const InputDecoration(
                  labelText: "Datum isteka",
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.required(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Odustani"),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.saveAndValidate() ?? false) {
             
              Navigator.pop(context, formKey.currentState!.value);
            }
          },
          child: const Text("Spremi"),
        ),
      ],
    ),
  );

  if (result != null) {
   final discountStr = result['salePrice']?.toString();
final discount = discountStr != null ? double.tryParse(discountStr) : null;
final expiry = result['saleExpires'] as DateTime?;

    if (discount != null) {


        await productProvider.update(product.productId, {
  'productName': product.productName,
  'productDescription': product.productDescription,
  'price': product.price,
  'stockQuantity': product.stockQuantity,
  'isOnSale': true,
  'salePrice': product.price! - (product.price! * (discount / 100.0)),
  'saleExpires': expiry?.toIso8601String(),
  'isDeleted': false,
  'image': product.image,
  'serviceId': product.productsServices?.map((ps) => ps.serviceId).toList(),
});

      await productPagination.refresh(newFilter: {
        'isDeleted': showDeleted,
        'storeId': AuthProvider.selectedStoreId,
      });
    }
  }
  
  }
  Future<void> _pickPdf() async {
  var result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  if (result != null && result.files.single.path != null) {
    setState(() {
      _pdfFile = File(result.files.single.path!);
      _base64Pdf = base64Encode(_pdfFile!.readAsBytesSync());
    });
  }
}
  Future _openCatalogueDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
        return  AlertDialog(
          surfaceTintColor: Colors.white,
          titlePadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Objavi katalog proizvoda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
              ],
            )),
             actions: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FormBuilder(child: 
                FormBuilderField(
                  name: "storeCatalogue",
                  validator: (val) {
                    if (_pdfFile == null) {
                      return "Obavezno je učitati PDF dokument";
                    }
                    return null;
                  },
                  builder: (field) {
                    return InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Katalog (PDF)",
                        border: OutlineInputBorder(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: _pdfFile != null
                    ? Text(_pdfFile!.path.split('/').last)
                    : const Text("Nema učitanog PDF dokumenta"),
                trailing: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                  ),
                  icon: const Icon(Icons.file_upload, color: Colors.white),
                  label: _pdfFile == null
                      ? const Text("Odaberi", style: TextStyle(color: Colors.white))
                      : const Text("Promijeni PDF", style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                     await _pickPdf();
                     setStateDialog((){});
                },
                  
                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ),
              ),
               ElevatedButton(
                child: const Text("Pošalji korisnicima", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
          
              backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
            ),
                onPressed: () async {
                  try {
          await storeProvider.update(AuthProvider.selectedStoreId!,
          {
            
            'storeCatalogue': _base64Pdf,
            'storeCataloguePublish': DateTime.now().toIso8601String(),
          });
        } on UserException catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.exMessage)));
         
        }
        
        on Exception catch (e) {
          
        }
                 
                },
              ),
           
          ],
        
        );}
      ),
    );
  }

Future<void> _openBatchSaleDialog(List<Product> products) async {
  final formKey = GlobalKey<FormBuilderState>();

  final result = await showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (_) => AlertDialog(
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: EdgeInsets.zero,
      title: Container(
         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(
         gradient: LinearGradient(
        colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Akcija za ${products.length} proizvoda", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
          ],
        ),
      ),
      
      content: FormBuilder(
        key: formKey,
        child: SingleChildScrollView(
         
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              products.any((p) => p.isOnSale==true) ? 
              const Text("Dodani proizvodi koji su već na akciji. Novi unos će prepisati stare vrijednosti.",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),):const SizedBox.shrink(),
              const SizedBox(height: 15,),
              FormBuilderTextField(
                name: 'salePrice',
                
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Postotak sniženja (%)",
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.percent),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required( errorText: 'Obavezno polje'),
                  FormBuilderValidators.numeric(errorText: 'Vrijednost mora biti broj'),
                  FormBuilderValidators.min(1,errorText: 'Minimalno je 1%'),
                  FormBuilderValidators.max(100,errorText: 'Maksimalno je 100%'),
                ]),
              ),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(
                locale: const Locale('bs'),
                name: 'saleExpires',
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: DateTime.now().add(const Duration(days: 1)),
                inputType: InputType.date,
                decoration: const InputDecoration(
                  labelText: "Datum isteka",
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                validator: FormBuilderValidators.required(errorText: 'Obavezno polje'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Odustani"),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.saveAndValidate() ?? false) {
             
              Navigator.pop(context, formKey.currentState!.value);
            }
          },
          style: ElevatedButton.styleFrom(
        
            backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
          ),
          child: const Text("Sačuvaj", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (result != null) {
    
   final discountStr = result['salePrice']?.toString();
final discount = discountStr != null ? double.tryParse(discountStr) : null;
final expiry = result['saleExpires'] as DateTime?;

    if (discount != null) {
      setState(() {
        isLoading = true;
      });
      for (final p in products) {

        await productProvider.update(p.productId, {
  'productName': p.productName,
  'productDescription': p.productDescription,
  'price': p.price,
  'stockQuantity': p.stockQuantity,
  'isOnSale': true,
  'salePrice': p.price! - (p.price! * (discount / 100.0)),
  'saleExpires': expiry?.toIso8601String(),
  'isDeleted': false,
  'image': p.image,
  'serviceId': p.productsServices?.map((ps) => ps.serviceId).toList(),
});

      try {
  await productPagination.refresh(newFilter: {
    'IsDeleted': showDeleted,
    'StoreId': AuthProvider.selectedStoreId,
    'IsOnSale': true
  });
} on Exception catch (e) {

}
    }
    setState(() {
      isLoading=false;
    });
  }
  }
}



  Future<void> _openCatalogDialog(List<Product> selected) async {
  if (selected.length != 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Generisani katalog mora imati 6 proizvoda.")),
    );
    return;
  }

  await showDialog(
    context: context,
    builder: (_) {
      String? selectedBackground;
      return AlertDialog(
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Kreiraj katalog",
                style: TextStyle(color: Colors.white),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
            ],
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text("Odabrani proizvodi (${selected.length}):"),
                const SizedBox(height: 8),
                ...selected.map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text("• ${p.productName} - ${p.price} KM"),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Spasi lokalno"),
            onPressed: () {
              Navigator.pop(context);
              _generatePdfCatalog(selected, selectedBackground, true);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Spasi lokalno i pošalji korisnicima"),
            onPressed: () {
              Navigator.pop(context);
              _generatePdfCatalog(selected, selectedBackground, false);
            },
          ),
        ],
      );
    },
  );
}



  Future<pw.ImageProvider?> _loadBackground(String? key) async {
  if (key == null) return null;
  final map = {
    'bg1': 'assets/images/background.png',
    'bg2': 'assets/images/catalogue.png',
  };
  final path = map[key];
  if (path == null) return null;
  final bytes = await rootBundle.load(path);
  return pw.MemoryImage(bytes.buffer.asUint8List());
}

Future<void> _generatePdfCatalog(List<Product> products, String? backgroundKey,bool isLocal) async {
  final pdf = pw.Document();
  final background = await _loadBackground(backgroundKey??'bg2');
  final fontRegular = pw.Font.ttf(
    await rootBundle.load("assets/fonts/ArchivoBlack-Regular.ttf"),
  );


  final positions = [
    const PdfPoint(-50, 420),
    const PdfPoint(350, 420),
    const PdfPoint(750, 420),
    const PdfPoint(-50, 760),
    const PdfPoint(350, 760),
    const PdfPoint(750, 760),
  ];

  const double boxWidth = 500;
  const double boxHeight = 300;
  final storeName = AuthProvider.user?.stores?.where((element) => element.storeId==AuthProvider.selectedStoreId).first.storeName ?? "";

  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(1165, 1219),
      build: (context) {
        return pw.Stack(
          children: [
            if (background != null)
              pw.Positioned.fill(child: pw.Image(background, fit: pw.BoxFit.cover)),
               pw.Positioned(
              left: 70,
              right: 0,
              top: 130, 
              child: pw.Transform.rotate(
                angle: 0.2,
                child:
                
                
                 pw.Text(
                  storeName.toUpperCase(),
                  style: pw.TextStyle(
               
                    fontSize: 80,
                    fontWeight: pw.FontWeight.bold,
                    font: fontRegular,
                    color: PdfColors.yellow,
                  ),
                ),
              ),
            ),
           
            ...List.generate(positions.length, (index) {
              if (index >= products.length) return pw.Container();
              final p = products[index];

              pw.Widget imageWidget = pw.Container();
              if (p.image != null) {
                final bytes = base64Decode(p.image!);
                imageWidget = pw.Image(
                  pw.MemoryImage(bytes),
                  height: boxHeight * 0.45,
                  fit: pw.BoxFit.contain,
                );
              }

              return pw.Positioned(
                left: positions[index].x,
                top: positions[index].y,
                child: pw.Container(
                  width: boxWidth,
                  height: boxHeight,
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Stack(
                    children: [
                     
                      pw.Positioned(
                        left:p.isOnSale == false? 140:90,
                        top: 8,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                        
                          child: p.isOnSale == true
                              ? pw.Row(
                                  mainAxisSize: pw.MainAxisSize.min,
                                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                                  children: [
                                    pw.Text(
                                      "${p.price?.toStringAsFixed(2)} KM",
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        font: fontRegular,
                                        color:  PdfColor.fromHex("#fccf08"),
                                        decoration: pw.TextDecoration.lineThrough,
                                      ),
                                    ),
                                    pw.SizedBox(width: 6),
                                    pw.Text(
                                      "${p.salePrice?.toStringAsFixed(2)} KM",
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                        font: fontRegular,
                                        color: PdfColors.yellow,
                                      ),
                                    ),
                                  ],
                                )
                              : pw.Text(
                                  "${p.price?.toStringAsFixed(2)} KM",
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    font: fontRegular,
                                    color:  PdfColor.fromHex("#fccf08"),
                                  ),
                                ),
                        ),
                      ),

               
                      pw.Center(
                        child: pw.Column(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            imageWidget,
                            pw.SizedBox(height: 8),
                            pw.Text(
                              p.productName ?? '',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                font: fontRegular,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    ),
  );

final pdfBytes = await pdf.save();


  if (isLocal==true) {
    // Save to local storage
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/Lokalno_${storeName}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf');
    await file.writeAsBytes(pdfBytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Katalog je spremljen u dokumente.")));
  } else {

    final base64Pdf = base64Encode(pdfBytes);

     try {
  await storeProvider.update(AuthProvider.selectedStoreId!,
  {
  
    'storeCatalogue': base64Pdf,
    'storeCataloguePublish': DateTime.now().toIso8601String(),
  });
} on UserException catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.exMessage)));
 
} on Exception catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Greška tokom slanja kataloga. Pokušajte ponovo.')));
}
  }
}




  @override
  Widget build(BuildContext context) {
    if(!_isInitialized) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
    
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
             crossAxisAlignment: WrapCrossAlignment.center,
            
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _productNameController,
                  decoration:  InputDecoration(
                    labelText: 'Naziv proizvoda',
                    prefixIcon: const Icon(Icons.search_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                     suffixIcon: _productNameController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _productNameController.clear();
                            _onSearchChanged();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
            
              const SizedBox(width: 16),


              SizedBox(
                width: 250,
                child: DropdownButtonFormField<int?>(
                  value: selectedServiceId,
                 
                  decoration: const InputDecoration(labelText: "Tip proizvoda",border: OutlineInputBorder()),
                
                  hint: const Text("Filter po usluzi"),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Svi tipovi")),
                    ...?serviceResult?.result.map((s) => DropdownMenuItem(
                          value: s.serviceId,
                          child: Text(s.serviceName ?? ''),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => selectedServiceId = value);
                    _onSearchChanged();
                  },
                ),
              ),
     const SizedBox(width: 8),
       Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Prikaži izbrisane"),
                   Switch(
                value: showDeleted,
                onChanged: (val) {
                  setState(() => showDeleted = val);
                  _onSearchChanged();
                },
              ),
                ],
              ),
     const SizedBox(width: 8),

              SizedBox(
                width: 200,
                child: ElevatedButton(onPressed:  () async{
                            await showDialog(context: context, builder: (_) => const ProductDetailsDialog());
                          },style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ) ,child: const Text("Dodaj proizvod",style: TextStyle(color: Colors.white),)),
              ),
              const SizedBox(width: 16),
               SizedBox(
                width: 200,
                 child: ElevatedButton(onPressed:  () async{
                             _openCatalogueDialog(context);
                           },style: ElevatedButton.styleFrom(
                             backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                           ) ,child: const Text("Dodaj katalog",style: TextStyle(color: Colors.white),)),
               ),

                
              const SizedBox(width: 16),
            
             
            ],
          ),
          const SizedBox(height: 16),
Container(
     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(
         gradient: LinearGradient(
        colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
        ),
  child: const Row(
    children: [
      Expanded(flex: 2, child: Text("Naziv", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      Expanded(flex: 4, child: Text("Opis", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      Expanded(flex: 2, child: Text("Cijena", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
    
      Expanded(flex: 2, child: Text("Na lageru", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      Expanded(flex: 3, child: Text("Tip", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
        Expanded(flex: 2, child: Text("Akcijska cijena", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      Expanded(flex: 2, child: Text("Vrijedi do", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      Expanded(flex: 3, child: Center(child: Text("Slika", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
      Expanded(flex: 1, child: Center(child: Text("Akcije", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
    ],
  ),
),

const SizedBox(height: 8),
 _buildBulkActionBar(),
    const SizedBox(height: 8),
Expanded(
  child:Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: productPagination.items.isEmpty && !isLoading
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/usersNotFound.webp', width: 250, height: 250),
              const SizedBox(height: 16),
              const Text(
                'Proizvodi nisu pronađeni.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          )
        : ListView.separated(
   
            itemCount: productPagination.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = productPagination.items[index];
              if(isLoading) return const Center(child: CircularProgressIndicator());
               return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: index.isEven ? Colors.grey.shade50 : Colors.white,
                    child: _buildProducts(p),
                  ),
                );
            },
        )
  )
  ),
  if (_productNameController.text.isEmpty && productPagination.hasNextPage == false)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            children: List.generate(
              (productPagination.count / productPagination.pageSize).ceil(),
              (index) {
                final pageNum = index + 1;
                final totalPages = (productPagination.count / productPagination.pageSize).ceil();
                final isActive = currentPage == pageNum;

                
                final bool isSinglePage = totalPages <= 1;

                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isActive 
                        ? const Color.fromRGBO(27, 76, 125, 1) 
                        : isSinglePage ? Colors.grey : Colors.white,
                    foregroundColor: isActive 
                        ? Colors.white 
                        : Colors.black87,
                    side: BorderSide(
                      color: isActive 
                        ? Colors.transparent 
                        : isSinglePage ? Colors.grey.shade400 : Colors.grey.shade300, 
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: isSinglePage 
                      ? null
                      : () async {
                          if (!mounted) return;
                          setState(() {
                            currentPage = pageNum;
                            isLoading = true;
                          });
                          await productPagination.goToPage(
                            pageNum,
                            filter: {
                              'isDeleted': showDeleted,
                              
                            },
                          );
                          if (!mounted) return;
                          setState(() {
                            isLoading = false;
                          });
                        },
                  child: Text("$pageNum",style: TextStyle(color: isActive ? Colors.white : Colors.black87),),
                );
              },
            ),
          ),


        const SizedBox(height: 8),

                if (_productNameController.text.isEmpty && productPagination.hasNextPage == false)

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Prikazano ${(currentPage - 1) * productPagination.pageSize + 1}"
              " - ${(currentPage - 1) * productPagination.pageSize + productPagination.items.length}"
              " od ${productPagination.count}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),

        
        ],
      ),
    );
  }
  Widget _buildProducts(Product p) {
  final isSelected = selectedProductIds.contains(p.productId);

  return  InkWell(
    onDoubleTap: ()=> _toggleProductSelection(p, !isSelected),
    child: Container(
      color:  isSelected ? Colors.lightBlue[50] : Colors.white,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            
        
        
            children: [
              
              
      
              Expanded(flex: 2, child: Text(p.productName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
        
      
              Expanded(flex: 4, child: Text(p.productDescription ?? '', maxLines: 2, overflow: TextOverflow.ellipsis)),
        
      
              Expanded(
                flex: 2,
                child: p.isOnSale == true
                    ? Text(
                        "${p.price?.toStringAsFixed(2)} KM",
                        style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
                      )
                    : Text("${p.price?.toStringAsFixed(2)} KM"),
              ),
        
      
          
        
      
              Expanded(flex: 2, child: Text(p.stockQuantity!>1 ? "${p.stockQuantity} komada" : "Van zaliha")),
       
              Expanded(
                flex: 3,
                child: Text(
                  p.productsServices?.map((e) => e.service?.serviceName ?? '').join('\n') ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
                  Expanded(
                flex: 2,
                child: p.isOnSale == true
                    ? Text("${p.salePrice?.toStringAsFixed(2)} KM",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                    : const Text("-"),
              ),
      
              Expanded(
                flex: 2,
                child: p.isOnSale == true && p.saleExpires != null
                    ? Text("${p.saleExpires!.day}.${p.saleExpires!.month}.${p.saleExpires!.year}")
                    : const Text("-"),
              ),
        
      
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
                    child: ClipOval(
                      child: p.image != null
                          ? imageFromString(p.image!)
                          : const Image(
                              image: AssetImage('assets/images/Image_not_available.png'),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
                            !showDeleted ?
                            Expanded(flex:1,child: 
                            Center(
                              child: PopupMenuButton<String>(
                                surfaceTintColor: Colors.white,
                                tooltip: 'Uredi/Izbriši',
                                icon: const Icon(Icons.more_vert),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                itemBuilder: (context) => [
                                
                                  const PopupMenuItem(value: 'sale', child: Text('Stavi na akciju')),
                                  const PopupMenuItem(value: 'edit', child: Text('Uredi')),
                                  const PopupMenuItem(value: 'delete', child: Text('Izbriši')),
                                ],
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    await showDialog(context: context, builder: (_) => ProductDetailsDialog(product: p));
                                    await productPagination.refresh(newFilter: {
                                      'isDeleted': showDeleted,
                                      'storeId': AuthProvider.selectedStoreId,
                                      'IsOnSale': true
                                    });
                                  } else if (value == 'delete') {
                                    _openUserDeleteDialog(product: p);
                                  }
                                  else if(value=='sale')
                                  {
                                    if(p.isOutOfStock==true)
                                    {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Proizvoda nema na lageru.")));
                                   
                                    }
                                    else{
                                      _toggleProductSelection(p, true);
                                    }
                                
                                      
                                    
                                   
                                  }
                                },
                                ),
                                ),
        
                              ) : 
                              Expanded(child: 
                              Center(
                                child: IconButton(
                                  icon: const Icon(Icons.restore_outlined),
                                  tooltip: 'Vrati',
                                  onPressed: () async {
                                    _openUserRestoreDialog(product: p);
                                    await productPagination.refresh(newFilter: {
                                      'isDeleted': showDeleted,
                                      'storeId': AuthProvider.selectedStoreId,
                                    });
                                  },
                                ),
                                ),
                                )
                          ],
                        ),
                      ),
    ),
  );
                  
                   
   
  }
  Widget _buildBulkActionBar() {
  if (selectedProductIds.isEmpty) return const SizedBox.shrink();

  return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: const BoxDecoration(
           gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
          ),
    child: Row(
      children: [
        selectedProductIds.length==1 ?
        Text('${selectedProductIds.length} proizvod odabran',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold))
        : Text('${selectedProductIds.length} proizvoda odabrana',style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

        const Spacer(),

       ElevatedButton.icon(
  icon: const Icon(Icons.local_offer),
  label: const Text("Stavi na akciju"),
  onPressed: () async {
    // Find all selected products
    final selected = productPagination.items
        .where((p) => selectedProductIds.contains(p.productId))
        .toList();

    // Check if any are out of stock
    final outOfStock = selected.any((p) => (p.isOutOfStock==true));

    if (outOfStock) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Ne možete staviti proizvod na akciju ako nema zaliha.")),
      );
      return;
    }

    // Otherwise proceed with sale dialog
    await _openBatchSaleDialog(selected);
  },
),


        const SizedBox(width: 8),

        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Kreiraj katalog"),
          onPressed: () async {
        
            final selected = productPagination.items
                .where((p) => selectedProductIds.contains(p.productId))
                .toList();
            final outOfStock = selected.any((p) => (p.isOutOfStock==true));
            final noImage = selected.any((element) => element.image==null);
             if (outOfStock) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Ne možete staviti proizvod na katalog ako nema zaliha.")),
      );
      return;
    }
      if (noImage) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Ne možete staviti proizvod na katalog ako nema sliku.")),
      );
      return;
    }
    
            await _openCatalogDialog(selected);
          },
        ),
          const SizedBox(width: 8),

        ElevatedButton.icon(
          icon: const Icon(Icons.cancel),
          label: const Text("Odustani"),
          onPressed: () async {
            selectedProductIds.clear();
            if(!mounted) return;
           setState(() {
             
           });
            
          },
        ),
      ],
    ),
  );
}



}
