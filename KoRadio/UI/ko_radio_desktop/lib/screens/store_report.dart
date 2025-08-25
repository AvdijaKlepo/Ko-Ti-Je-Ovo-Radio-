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

extension NumFormatter on num {
  String format() => toInt().toString();
}

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
  SearchResult<Order>? shippedOrders;
  SearchResult<Order>? cancelledOrders;

  @override
  void initState() {
    super.initState();
    storeProvider = context.read<StoreProvider>();
    productProvider = context.read<ProductProvider>();
    orderProvider = context.read<OrderProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadStore(),
      _loadProducts(),
      _loadShippedOrders(),
      _loadCancelledOrders(),
    ]);
  }

  Future<void> _loadStore() async {
    try {
      final fetched = await storeProvider.get(filter: {'StoreId': AuthProvider.selectedStoreId});
      setState(() => storeResult = fetched);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  Future<void> _loadProducts() async {
    try {
      final fetched = await productProvider.get(filter: {'StoreId': AuthProvider.selectedStoreId});
      setState(() => productResult = fetched);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  Future<void> _loadShippedOrders() async {
    try {
      final fetched = await orderProvider.get(filter: {
        'StoreId': AuthProvider.selectedStoreId,
        'IsShipped': true,
        'IsCancelled': false,
      });
      setState(() => shippedOrders = fetched);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  Future<void> _loadCancelledOrders() async {
    try {
      final fetched = await orderProvider.get(filter: {
        'StoreId': AuthProvider.selectedStoreId,
        'IsShipped': false,
        'IsCancelled': true,
      });
      setState(() => cancelledOrders = fetched);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  double get totalRevenue => shippedOrders?.result.fold<double>(
        0,
        (sum, o) => sum + (o.orderItems?.map((i) => i.product!.price! * i.quantity!).reduce((a, b) => a + b) ?? 0),
      ) ?? 0;

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/fonts/Roboto-VariableFont_wdth,wght.ttf");
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(pw.Page(
      build: (context) => pw.Column(children: [
        pw.Text('Pregled statistike za trgovinu ${storeResult?.result.first.storeName}',
            style: pw.TextStyle(fontSize: 18, font: ttf)),
        pw.SizedBox(height: 10),
        pw.Text('Broj proizvoda: ${productResult?.count ?? 0}', style: pw.TextStyle(font: ttf, fontSize: 16)),
        pw.Text('Poslane narudžbe: ${shippedOrders?.count ?? 0}', style: pw.TextStyle(font: ttf, fontSize: 16)),
        pw.Text('Otkazane narudžbe: ${cancelledOrders?.count ?? 0}', style: pw.TextStyle(font: ttf, fontSize: 16)),
        pw.Text('Ukupna zarada: ${totalRevenue.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 16)),
      ]),
    ));

    final dir = await getApplicationDocumentsDirectory();
    final vrijeme = DateTime.now();
    final path = '${dir.path}/Izvjestaj-Trgovine-${formatDate(vrijeme.toString())}.pdf';
    await File(path).writeAsBytes(await pdf.save());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izvještaj uspješno sačuvan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pregled statistike za trgovinu ${storeResult?.result.first.storeName ?? ""}',
                style: TextStyle(fontSize: 35, fontFamily: GoogleFonts.lobster().fontFamily),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _dashboardCard('Broj proizvoda', Icons.local_grocery_store, productResult?.count ?? 0, Colors.teal),
                  _dashboardCard('Poslane narudžbe', Icons.send, shippedOrders?.count ?? 0, Colors.indigo),
                  _dashboardCard('Otkazane narudžbe', Icons.cancel, cancelledOrders?.count ?? 0, Colors.redAccent),
                  _dashboardCard('Ukupna zarada', Icons.monetization_on, totalRevenue.toInt(), Colors.orangeAccent),
                ],
              ),
              const SizedBox(height: 30),
              _buildOrdersChart(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _generatePdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4C7D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  ),
                  child: const Text('Generiši izvještaj', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard(String title, IconData icon, int value, Color color) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(backgroundColor: color, radius: 30, child: Icon(icon, color: Colors.white, size: 30)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value.format(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersChart() {
    if (shippedOrders == null || shippedOrders!.result.isEmpty) {
      return const Center(
        child: Text('Trenutno nema podataka za prikazati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      );
    }

    List<Order> ordersList = shippedOrders!.result;
    List<int> ordersPerMonth = List.filled(12, 0);
    for (var order in ordersList) {
      ordersPerMonth[order.createdAt!.month - 1]++;
    }

    List<String> months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    List<FlSpot> spots = List.generate(12, (i) => FlSpot(i.toDouble(), ordersPerMonth[i].toDouble()));
    double maxY = ((ordersPerMonth.reduce((a, b) => a > b ? a : b) ~/ 5) + 1) * 5.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: const Color(0xFF1B4C7D),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Broj narudžbi po mjesecima', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 2.5,
              child: LineChart(LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: Colors.white, barWidth: 4, belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(0.3)), dotData: const FlDotData(show: true))],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 5, getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: const TextStyle(color: Colors.white))),
                    axisNameWidget: const Text('Broj narudžbi', style: TextStyle(color: Colors.white, fontSize: 14)),
                    axisNameSize: 30,
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, meta) => Text(months[v.toInt()], style: const TextStyle(color: Colors.white))),
                    axisNameWidget: const Text('Mjesec', style: TextStyle(color: Colors.white, fontSize: 14)),
                    axisNameSize: 30,
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
