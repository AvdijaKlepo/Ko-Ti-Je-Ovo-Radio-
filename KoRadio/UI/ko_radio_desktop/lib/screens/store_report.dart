import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ko_radio_desktop/models/order.dart';
import 'package:ko_radio_desktop/models/product.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/store.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/order_provider.dart';
import 'package:ko_radio_desktop/providers/product_provider.dart';
import 'package:ko_radio_desktop/providers/stores_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
class StoreReport extends StatefulWidget {
  const StoreReport({super.key});

  @override
  State<StoreReport> createState() => _StoreReportState();
}

class _StoreReportState extends State<StoreReport> {
  late StoreProvider storeProvider;
  late ProductProvider productProvider;
  late OrderProvider orderProvider;
  SearchResult<Store>? storeResult;
  SearchResult<Product>? productResult;
  SearchResult<Order>? orderResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      storeProvider = context.read<StoreProvider>();
      productProvider = context.read<ProductProvider>();
      orderProvider = context.read<OrderProvider>();

      await _loadStores();
      await _loadProducts();
      await _loadOrders();
    
    });
  }
  Future<void> _loadStores() async {
    var filter = {'StoreId':AuthProvider.selectedStoreId};
    try {
  final fetchedStores =
      await storeProvider.get(filter: filter);
  
  setState(() {
    storeResult = fetchedStores;
  });
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Greška: ${e.toString()}")),
  );
}
  }

  Future<void> _loadProducts() async {
    var filter = {'StoreId':AuthProvider.selectedStoreId};
    try {
  final fetchedProducts =
      await productProvider.get(filter: filter);
  
  setState(() {
    productResult = fetchedProducts;
  });
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Greška: ${e.toString()}")),
  );
}
  }
   Future<void> _loadOrders() async {
    var filter = {'StoreId':AuthProvider.selectedStoreId};
    try {
  final fetchedOrders =
      await orderProvider.get(filter: filter);
  
  setState(() {
    orderResult = fetchedOrders;
  });
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Greška: ${e.toString()}")),
  );
}
  }
    Future<void> _generatePdf() async {
    final summedInvoice = (orderResult?.result ?? [])
    .fold<double>(0, (sum, e) => sum + (e.orderItems?.map((e) => e.product?.price ?? 0).reduce((a, b) => a + b) ?? 0));

   
    final pdf = pw.Document();
  final fontData = await rootBundle.load("assets/fonts/Roboto-VariableFont_wdth,wght.ttf");
  final ttf = pw.Font.ttf(fontData);

    
    var ukupno = (orderResult?.result ?? []).length;

    try {
      pdf.addPage(

        pw.Page(

          build: (pw.Context context) {
            return pw.Column(
              children: [
                
                pw.Text('Broj narudžbi: ${orderResult?.count ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
                      pw.Text('Broj proizvoda: ${productResult?.count ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
                  
                     pw.Text('Ukupna zarada: ${summedInvoice ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
               
               
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final vrijeme = DateTime.now();
      String path =
          '${dir.path}/Izvjestaj-Dana-${formatDate(vrijeme.toString())}.pdf';
      File file = File(path);
      file.writeAsBytes(await pdf.save());
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izvještaj uspješno sačuvan')),
      );
    } on Exception catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
        final summedInvoice = (orderResult?.result ?? [])
    .fold<double>(0, (sum, e) => sum + (e.orderItems?.map((e) => e.product?.price ?? 0).reduce((a, b) => a + b) ?? 0));
    return  Scaffold(
 
      body: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
   
    
        children: [
          Text('Pregled statistike za trgovinu ${storeResult?.result.first.storeName}',style: TextStyle(fontSize: 35,fontFamily: GoogleFonts.lobster().fontFamily),),
          const SizedBox(height: 200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            
          
          
           Card(
             
                color: Colors.white,
                
                
                child: SizedBox(
                  width: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.local_grocery_store, size: 50),
                        const SizedBox(height: 16),
                        ListTile(
                          
                          title:const Text(
                          'Broj proizvoda',
                          style: TextStyle(fontSize: 16),
                  
                        ),
                        subtitle: Center(
                          child: Text(
                            '${productResult?.count ?? 0}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ),
                      
                      ]
                    ),
                                ),
                ),
            ),
              Card(
                 
                    color: Colors.white,
                    
                    
                    child: SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.shopping_cart, size: 50),
                            const SizedBox(height: 16),
                            ListTile(
                              
                              title:const Text(
                              'Broj narudžbi',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${orderResult?.count ?? 0}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ),
                          
                          ]
                        ),
                                    ),
                    ),
                ),
                   
                 Card(
                 
                    color: Colors.white,
                    
                    
                    child: SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.monetization_on, size: 50),
                            const SizedBox(height: 16),
                            ListTile(
                              
                              title:const Text(
                              'Ukupna zarada',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${summedInvoice}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ),
                          
                          ]
                        ),
                                    ),
                    ),
                ),
                  
               
           
            ],
            
          ),
          const SizedBox(height: 20,),
          
           const SizedBox(height: 10,),
          

        //   _buildStats(),
                const SizedBox(height: 10,),
            Center(
            child:  ElevatedButton(onPressed: (){
             _generatePdf();
           }, child: const Text('Generiši izvještaj',style: TextStyle(color: Colors.white),),
           
           style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B4C7D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
           ),
          ),
            ),
          
        ],
      )
    );
  }
  

}