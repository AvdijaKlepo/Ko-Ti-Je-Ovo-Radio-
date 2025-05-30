import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/location_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:ko_radio_desktop/screens/service_details_screen.dart';
import 'package:provider/provider.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  late ServiceProvider serviceProvider;
  late LocationProvider locationProvider;
   @override
  void initState(){

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      serviceProvider = context.read<ServiceProvider>();
      _getServices();
    });

     WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      locationProvider = context.read<LocationProvider>();
      _getLocations();
    });
  }
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    serviceProvider = context.read<ServiceProvider>();
    locationProvider = context.read<LocationProvider>();
  }
  _getServices() async{
    var fetchedUsers = await serviceProvider.get();
    setState(() {
      result = fetchedUsers;
    });
  }
    _getLocations() async{
    var fetchedLocations = await locationProvider.get();
    setState(() {
      locationResult = fetchedLocations;
    });
  }
  SearchResult<Service>? result;
  SearchResult<Location>? locationResult;
  @override
  Widget build(BuildContext context) {
    return Container(
          child: Column(

            children: [
              _buildSearch(),
              _buildResultView(),
              SizedBox(height: 8,),
              _buildLocationView()
            ],
          ),
  
    );
  }
  TextEditingController _gteNameEditingController = TextEditingController();
  TextEditingController _gteLastNameEditingController = TextEditingController();
  _buildSearch() {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _gteNameEditingController, decoration: InputDecoration(labelText: "First Name"),)),
          SizedBox(width: 8,),
          Expanded(child: TextField(controller: _gteLastNameEditingController, decoration: InputDecoration(labelText: "Last Name"), )),
          ElevatedButton(onPressed: () async {
           
            var filter= {
              'FirstNameGTE': _gteNameEditingController.text,
              'LastNameGTE': _gteLastNameEditingController.text,
              'IsServiceIncluded': true
              
            };
      
           result = await serviceProvider.get(filter: filter);
         


           setState(() {
             
           });
          
          }, child: Text("Search")),
          SizedBox(width: 8,),
           ElevatedButton(onPressed: () async {
            print("exec");
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ServiceDetailScreen()));
          }, child: Text("Dodaj"))
        
          
        ],
      ),
    );
  }
  
  _buildResultView() {
    return Container(
      width: double.infinity,
      child:SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:FittedBox(
          
      child: DataTable(
        columns: [
    
          DataColumn(label: Text("Service Name"),),
          DataColumn(label: Text("Slika"),
          
          ),
 
        ],
        rows: result?.result.map((e)=>
        
         DataRow(
          onSelectChanged: (selected)=>{
            if (selected==true){
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>ServiceDetailScreen(service:e)))
            }
          },
            cells:[
              
            DataCell(Text(e.serviceName??  "")),
            DataCell(e.image != null ? Container(width: 100,height:100,
            child: imageFromString(e.image!),): Text("")),
           



        
            ],
            

            )).toList().cast<DataRow>() ?? [],
      ),
        )
      ),
      );
  }
  
  _buildLocationView() {
     return Container(
      width: double.infinity,
      child:SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:FittedBox(
          
      child: DataTable(
        columns: [
    
          DataColumn(label: Text("Naziv"),),
       
 
        ],
        rows: locationResult?.result.map((e)=>
        
         DataRow(
         
            cells:[
              
            DataCell(Text(e.locationName??  "")),
          



        
            ],
            

            )).toList().cast<DataRow>() ?? [],
      ),
        )
      ),
      );
  }
}