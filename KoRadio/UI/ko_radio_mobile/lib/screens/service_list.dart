import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/freelancer_list.dart';
import 'package:provider/provider.dart';



class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}


class _ServiceListScreenState extends State<ServiceListScreen> {
  late ServiceProvider serviceProvider;
  SearchResult<Service>? result;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      serviceProvider = context.read<ServiceProvider>();
      _getServices();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    serviceProvider = context.read<ServiceProvider>();
  }

  _getServices() async {
    var services = await serviceProvider.get();
    setState(() {
      result = services;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
      itemCount: result?.result.length ?? 0,
     itemBuilder: (context, index) {
  var e = result!.result[index];
  return e.serviceName != null
      ? InkWell(
          child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth * 1;
                      final height = width * 0.45;
                      return SizedBox(
                        width: width,
                        height: height,
                        child: imageFromString(
                          e.image!,
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text("${e.serviceName}", style: const TextStyle(fontSize: 16)),
                ],
              )),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => FreelancerList(e.serviceId))),
        )
      : const SizedBox.shrink();
}

    );
  }
}
