import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/layout/master_screen.dart';
import 'package:ko_radio_desktop/models/freelancer.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/providers/freelancer_provider.dart';
import 'package:provider/provider.dart';

class FreelancerListScreen extends StatefulWidget {
  const FreelancerListScreen({super.key});

  @override
  State<FreelancerListScreen> createState() => _FreelancerListScreenState();
}

class _FreelancerListScreenState extends State<FreelancerListScreen> {
  late FreelancerProvider provider;

  @override
  void initState(){

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      provider = context.read<FreelancerProvider>();
      _getFreelancers();
   
    });
  }
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    provider = context.read<FreelancerProvider>();
  }
  _getFreelancers() async{
    var fetchedUsers = await provider.get();
    setState(() {
      result = fetchedUsers;
    });
  }
  SearchResult<Freelancer>? result = null;
  @override
  Widget build(BuildContext context) {

        return Container(
          child: Column(

            children: [
              _buildSearch(),
              _buildResultView()
            ],
          ),
  
    );
  }
   TextEditingController _gteNameEditingController = TextEditingController();
  TextEditingController _gteLastNameEditingController = TextEditingController();
  String? service='true';
  Widget _buildSearch() {
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
              'IsServiceIncluded=':service
             
              
            };
      
           result = await provider.get(filter: filter);
         


           setState(() {
             
           });
          
          }, child: Text("Search")),
          SizedBox(width: 8,),
        
          
        ],
      ),
    );
  }

  Widget _buildResultView() {
     return Container(
      width: double.infinity,
      child:SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:FittedBox(
          
      child: DataTable(
        columns: [
    
          DataColumn(label: Text("First Name"),),
          DataColumn(label: Text("Last Name")),
          DataColumn(label: Text("Email")),
          DataColumn(label: Text("Bio")),
          DataColumn(label: Text("ExperianceYears")),


          DataColumn(label: Text("Rating")),
          DataColumn(label: Text("Services")),
        ],
        rows: result?.result.map((e)=>
       
         DataRow(
            cells:[
              
            DataCell(Text(e.user.firstName?? "")),
            DataCell(Text(e.user.lastName ?? "")),
            DataCell(Text(e.user.email ?? "")),
            DataCell(Text(e.bio ?? "")),
            DataCell(Text(e.experianceYears.toString())),
   
            DataCell(Text(e.rating.toString())),
            DataCell(Wrap(
              spacing: 8.0,
              children: e.freelancerServices?.map((e){
                return SizedBox( width: 120,child: Text(e.service?.serviceName ?? "Unknown",
                 ) 
                );
              }).toList() ?? [],
            ))
            



       
        
            ],
            

            )).toList().cast<DataRow>() ?? [],
      ),
        )
      ),
      );
  }
}