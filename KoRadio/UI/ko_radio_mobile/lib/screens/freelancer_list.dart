import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/models/service.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/service_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/freelancer_details.dart';
import 'package:provider/provider.dart';

class FreelancerList extends StatefulWidget {
  FreelancerList(this.serviceId,{super.key});
  int serviceId;

  @override
  State<FreelancerList> createState() => _FreelancerListState();
}

class _FreelancerListState extends State<FreelancerList> {
  late FreelancerProvider freelancerProvider;
  SearchResult<Freelancer>? result;


  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      freelancerProvider = context.read<FreelancerProvider>();
      _getServices();
    });
  }
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    freelancerProvider = context.read<FreelancerProvider>();
  }

  _getServices() async {
    var filter = {
      'ServiceId':widget.serviceId
    };
    var freelancer = await freelancerProvider.get(filter: filter);
    setState(() {
      result = freelancer;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: ListView.builder(
        itemCount: result?.result?.length ?? 0,
        itemBuilder: (context, index) {
          var e = result!.result[index];
          return Container(
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      child: e.user.image != null
                          ? Container(
                              width: 100,
                              height: 100,
                              child: imageFromString(e.user.image!),
                            )
                          : Image.network(
                              "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png",
                              width: 100,
                              height: 100,
                            ),
                            onTap:()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=>FreelancerDetails())),
                    ),
                    Text(
                        '${e.user.firstName} ${e.availability} ${e.hourlyRate}'),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}