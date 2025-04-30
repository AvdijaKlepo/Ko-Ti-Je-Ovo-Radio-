import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/freelancer_list.dart';
import 'package:provider/provider.dart';
class ServiceListScreen extends StatefulWidget {
  ServiceListScreen({super.key});


  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  late ServiceProvider serviceProvider;
  SearchResult<Service>? result;
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      serviceProvider = context.read<ServiceProvider>();
      _getServices();
    });
  }
  @override
  void didChangeDependencies(){
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
  return MasterScreen(
child: 
      ListView.builder(
        itemCount: result?.result?.length ?? 0,
        itemBuilder: (context, index) {
          var e = result!.result[index];
          return e.serviceName != null
              ? InkWell(
                  child: Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          imageFromString(e.image!),
                          Text("${e.serviceName}")
                        ],
                      )),
                  onTap:()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=>FreelancerList(e.serviceId)))
                )
              : SizedBox.shrink();
        },
      ),
    );
}

}

