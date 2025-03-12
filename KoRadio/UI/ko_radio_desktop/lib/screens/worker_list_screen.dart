import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ko_radio_desktop/layout/master_Screen.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/worker.dart';
import 'package:ko_radio_desktop/providers/worker_provider.dart';
import 'package:ko_radio_desktop/screens/worker_details_screen.dart';
import 'package:provider/provider.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  
  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}


class _WorkerListScreenState extends State<WorkerListScreen> {

  late WorkerProvider provider;

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    provider = context.read<WorkerProvider>();
  }
  SearchResult<Worker>? result = null;

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
        "Workers",
        Container(
          child: Column(

            children: [
              _buildSearch(),
              _buildResultView()
            ],
          ),
        )
    );
  }
  TextEditingController _gteNameEditingController = TextEditingController();
  TextEditingController _gteLastNameEditingController = TextEditingController();
  Widget _buildSearch(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _gteNameEditingController, decoration: InputDecoration(labelText: "Ime"),)),
          SizedBox(width: 8,),
          Expanded(child: TextField(controller: _gteLastNameEditingController, decoration: InputDecoration(labelText: "Prezime"), )),
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
             Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WorkerDetailsScreen()));

          }, child: Text("Add Worker"))
          
        ],
      ),
    );
  }

  Widget _buildResultView(){
    return Expanded(
      child: Container(
      width: double.infinity,
      child:SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: Text("WorkerID")),
          DataColumn(label: Text("UserId"),),
          DataColumn(label: Text("First Name")),
          DataColumn(label: Text("Last Name"))
        ],
        rows: result?.result.map((e)=>
         DataRow(
            cells:[
            DataCell(Text(e.workerId.toString())),
            DataCell(Text(e.userId.toString())),
            DataCell(Text(e.user?.firstName ?? "")),
            DataCell(Text(e.user?.lastName?? ""))],
            )).toList().cast<DataRow>() ?? [],
      ),
      ),
      ),
    );
  }
}
