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
  SearchResult<Order>? cancelledOrderResult;

  @override
  void initState() {
    super.initState();
    storeProvider = context.read<StoreProvider>();
      productProvider = context.read<ProductProvider>();
      orderProvider = context.read<OrderProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      

      await _loadStores();
      await _loadProducts();
      await _loadOrders();
      await _loadCancelledOrders();
    
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
  Future<void> _loadCancelledOrders() async {
    var filter = {'StoreId':AuthProvider.selectedStoreId,
    'IsShipped': false,
    'IsCancelled': true};
    try {
  final fetchedOrders =
      await orderProvider.get(filter: filter);
  
  setState(() {
    cancelledOrderResult = fetchedOrders;
  });
} on Exception catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Greška: ${e.toString()}")),
  );
}
  }
   Future<void> _loadOrders() async {
    var filter = {'StoreId':AuthProvider.selectedStoreId,
    'IsShipped': true,
    'IsCancelled': false};
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
    .fold<double>(0, (sum, e) => sum + (e.orderItems?.map((e) => e.product!.price!*e.quantity!).reduce((a, b) => a + b) ?? 0));

   
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
                    pw.Text('Broj poslanih narudžbi: ${orderResult?.result.where((element) => element.isShipped==true).length ?? 0}',
                    style:  pw.TextStyle(fontSize: 18,font: ttf)),
                    pw.Text('Broj otkazanih narudžbi: ${orderResult?.result.where((element) => element.isCancelled==true).length ?? 0}',
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
    .fold<double>(0, (sum, e) => sum + (e.orderItems?.map((e) => e.product!.price!*e.quantity!).reduce((a, b) => a + b) ?? 0));
    
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
                            const Icon(Icons.send, size: 50),
                            const SizedBox(height: 16),
                            ListTile(
                              
                              title:const Text(
                              'Broj poslanih narudžbi',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${orderResult?.result.where((element) => element.isShipped==true).length ?? 0}',
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
                            const Icon(Icons.cancel, size: 50),
                            const SizedBox(height: 16),
                            ListTile(
                              
                              title:const Text(
                              'Broj otkazanih narudžbi',
                              style: TextStyle(fontSize: 16),
                      
                            ),
                            subtitle: Center(
                              child: Text(
                                '${cancelledOrderResult?.count}',
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
                                '$summedInvoice',
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
          

          _buildStats(),
                const SizedBox(height: 10,),
            Center(
            child:  ElevatedButton(onPressed: (){
             _generatePdf();
           },
           
           style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B4C7D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
           ), child: const Text('Generiši izvještaj',style: TextStyle(color: Colors.white),),
          ),
            ),
          
        ],
      )
    );
  }

  Widget _buildStats() {
  if (orderResult == null || orderResult!.result.isEmpty) {
    return const Center(
      child: Text(
        'Trenutno nema podataka za prikazati',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

 
  List<Order> orderList = orderResult!.result
     
      .toList();

  List<int> ordersPerMonth = List.filled(12, 0);
  for (var order in orderList) {
    int monthIndex = order.createdAt!.month - 1;
    ordersPerMonth[monthIndex]++;
  }


  List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];


  List<FlSpot> spots = List.generate(
    12,
    (index) => FlSpot(index.toDouble(), ordersPerMonth[index].toDouble()),
  );

  double maxValue = ordersPerMonth.isNotEmpty
      ? ordersPerMonth.reduce((a, b) => a > b ? a : b).toDouble()
      : 1;
  double maxY = ((maxValue ~/ 5) + 1) * 5;

  return Padding(
    padding: const EdgeInsets.all(15),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: const Color(0xFF1B4C7D),
        width: double.infinity,
        height: 600,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Broj narudžbi po mjesecima ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        color: Colors.white,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            if (value % 5 == 0) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white),
                              );
                            }
                            return Container();
                          },
                        ),
                        axisNameWidget: const Text(
                          "Broj narudžbi",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        axisNameSize: 30,
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 && value < months.length) {
                              return Text(
                                months[value.toInt()],
                                style: const TextStyle(color: Colors.white),
                              );
                            }
                            return Container();
                          },
                        ),
                        axisNameWidget: const Text(
                          "Mjesec",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        axisNameSize: 30,
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  

}