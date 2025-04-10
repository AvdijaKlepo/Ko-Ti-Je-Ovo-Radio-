import 'package:flutter/material.dart';

import 'package:ko_radio_desktop/layout/master_Screen.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/user.dart';
import 'package:ko_radio_desktop/providers/user_provider.dart';
import 'package:ko_radio_desktop/screens/user_details_screen.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {

  const UserListScreen({super.key});

  
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}


class _UserListScreenState extends State<UserListScreen> {


  late UserProvider provider;

  @override
  void initState(){

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      provider = context.read<UserProvider>();
      _getUsers();
   
    });
  }
  void didChangeDependencies(){
    super.didChangeDependencies();

    provider = context.read<UserProvider>();
  }
    SearchResult<User>? result = null;
  void _getUsers() async {
    var fetchedUsers = await provider.get();
    setState(() {
      result = fetchedUsers;
    });
  }

  

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
  Widget _buildSearch(){
    return Padding(
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
              'isNameIncluded': true
            };
      
           result = await provider.get(filter: filter);


           setState(() {
             
           });
          
          }, child: Text("Search")),
          SizedBox(width: 8,),
           ElevatedButton(onPressed: () async {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>UserDetailsScreen()));

          }, child: Text("Add Worker"))
          
        ],
      ),
    );
  }

  Widget _buildResultView(){

      return Container(
      width: double.infinity,
      child:SingleChildScrollView(
      child: DataTable(
        columns: [
        
          DataColumn(label: Text("First Name"),),
          DataColumn(label: Text("Last Name")),
          DataColumn(label: Text("Email")),
          DataColumn(label: Text("Hiring"))
        ],
        rows: result?.result.map((e)=>
         DataRow(
            cells:[
            
            DataCell(Text(e.firstName ?? "")),
            DataCell(Text(e.lastName?? "")),
            DataCell(Text(e.email ?? "")),
            DataCell(ElevatedButton(onPressed: () async {
             Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>UserDetailsScreen(user:e)));

              
            }, child: Text("Freelancer")))
            ],

            )).toList().cast<DataRow>() ?? [],
      ),
      ),
      );
   
  }
}
