import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/freelancer_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/freelancer_details.dart';
import 'package:provider/provider.dart';

enum options { Radnici, Firme }

class FreelancerList extends StatefulWidget {
  FreelancerList(this.serviceId, {super.key});
  int serviceId;

  @override
  State<FreelancerList> createState() => _FreelancerListState();
}

options view = options.Radnici;

class _FreelancerListState extends State<FreelancerList> {
  late FreelancerProvider freelancerProvider;
  SearchResult<Freelancer>? result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      freelancerProvider = context.read<FreelancerProvider>();
     
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    freelancerProvider = context.read<FreelancerProvider>(); 
    _getServices();
  }

  _getServices() async {
    var filter = {'ServiceId': widget.serviceId,'IsServiceIncluded':true};
    var freelancer = await freelancerProvider.get(filter: filter);
    setState(() {
      result = freelancer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(title: 'Lista radnika', automaticallyImplyLeading: true),body:  SafeArea(
        child: Column(
            children: [
              SegmentedButton<options>(
                segments: const <ButtonSegment<options>>[
                  ButtonSegment(
                      value: options.Radnici,
                      label: Text('Radnici'),
                      icon: Icon(Icons.construction)),
                  ButtonSegment(
                      value: options.Firme,
                      label: Text('Firme'),
                      icon: Icon(Icons.business)),
                ],
                selected: <options>{view},
                onSelectionChanged: (Set<options> newSelection) {
                  setState(() {
                    view = newSelection.first;
                  });
                },
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: result?.result.length ?? 0,
                itemBuilder: (context, index) {
                  var e = result!.result[index];
                  return Column(
                    children: [
                              
              
                      Row(
                    
                        children: [
                          InkWell(
                            child: e.user.image != null
                                ? SizedBox(
                                    height: 130,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: imageFromString(e.user.image!),
                                    ),
                                  )
                                : Image.network(
                                    "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png",
                                    width: 100,
                                    height: 100,
                                  ),
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => FreelancerDetails(e))),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                           
                            children: [
                              Text('${e.user.firstName} ${e.user.lastName}'),
                              Text('Iskustvo: ${e.experianceYears} godina'),
                              Text('Ocjena: ${e.rating != 0 ? e.rating : 'Neocijenjen'}'),
                              Text('Lokacija: ${e.location}')
                             
                           
                             
                            ],
                          )
                        ],
                      )
                    ],
                  );
                },
              )),
            ],
          ),
      ));
    
  }
}
