import 'package:flutter/material.dart';
import 'package:ko_radio_mobile/layout/master_screen.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';

class FreelancerDetails extends StatefulWidget {
  FreelancerDetails(this.e, {super.key});
  Freelancer e;
  @override
  State<FreelancerDetails> createState() => _FreelancerDetailsState();
}

class _FreelancerDetailsState extends State<FreelancerDetails> {
   DateTime? selectedDate;
 Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2021, 7, 25),
      firstDate: DateTime(2021),
      lastDate: DateTime(2022),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }
  @override
  
  Widget build(BuildContext context) {
    
    return MasterScreen(
      child: Scaffold(
        body: Column(
          children: [
            Text("${widget.e.user.firstName} ${widget.e.user.lastName}"),
            Text("${widget.e.location}"),
            Text("${widget.e.hourlyRate}"),
            Text("${widget.e.rating}"),
            Text("${widget.e.bio}"),
            Expanded(child: DatePickerDialog(firstDate:DateTime(2025) ,lastDate:DateTime(2035) ,))


          ],
        ),
      ));
  }
}