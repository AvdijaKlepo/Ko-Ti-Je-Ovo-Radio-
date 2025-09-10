import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/models/job.dart';
import 'package:ko_radio_mobile/models/job_status.dart';
import 'package:ko_radio_mobile/models/search_result.dart';
import 'package:ko_radio_mobile/providers/job_provider.dart';
import 'package:ko_radio_mobile/providers/messages_provider.dart';
import 'package:ko_radio_mobile/providers/utils.dart';
import 'package:ko_radio_mobile/screens/approve_job_edit.dart';
import 'package:ko_radio_mobile/screens/edit_job_freelancer.dart';
import 'package:provider/provider.dart';

class ApproveJob extends StatefulWidget {
  const ApproveJob({required this.job, required this.freelancer, super.key});
  final Job job;
  final Freelancer freelancer;

  @override
  State<ApproveJob> createState() => _ApproveJobState();
}

class _ApproveJobState extends State<ApproveJob> {
  late JobProvider jobProvider;
  late MessagesProvider messagesProvider;
  late SearchResult<Job> jobResult;
  late SearchResult<Job> jobFreelancerResult;
  bool _isLoading = false;
  bool multiDateJob=false;
  late Set<int> _workingDayInts;
  final Map<String, int> _dayStringToInt = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };
 
  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading=true;
    });
      jobProvider = context.read<JobProvider>();
      messagesProvider = context.read<MessagesProvider>();
        _workingDayInts = widget.job.freelancer?.workingDays
            ?.map((day) => _dayStringToInt[day] ?? -1)
            .where((dayInt) => dayInt != -1)
            .toSet() ??
        {};

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    
      await _getJob();
      await _getOtherFreelancersJobs();
      setState(() {
        _isLoading=false;
      });
  
    });
   

  }
  bool _isWorkingDay(DateTime day) {
    return  _workingDayInts.contains(day.weekday);
  }
  Future<void> _getJob() async {
    if(!mounted) return;
    setState(() {
      _isLoading=true;
    });

    try {
      var fetchedJob = await jobProvider.get(filter: {'JobId': widget.job.jobId});
      if(!mounted) return;
      setState(() {
        jobResult = fetchedJob;
        _isLoading=false;
      });
    } on Exception catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
    Future<void> _getOtherFreelancersJobs() async {
    setState(() {
      _isLoading=true;
    });

    try {
      var fetchedJob = await jobProvider.get(filter: {'FreelancerId': widget.job.freelancer?.freelancerId,
      'DateRange': widget.job.jobDate,
      'JobStatus': JobStatus.approved.name
      });
      setState(() {
        jobFreelancerResult = fetchedJob;
        _isLoading=false;
      });
    } on Exception catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white), 
      ),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors. white),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildImageRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: value,
          ),
        ],
      ),
    );
  }
  _openImageDialog() {
    return AlertDialog(
      backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
      title: const Text('Proslijeđena slika',style: TextStyle(color: Colors.white),),
      content: imageFromString(widget.job.image!),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),))
      ],
    );
  }
  _openCancelDialog() {
    return AlertDialog(
      backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
      title:  Text( widget.job.jobStatus==JobStatus.unapproved ? 'Odbaci posao' : 'Otkaži posao',style: TextStyle(color: Colors.white),),
      content: const Text('Jeste li sigurni da želite da otkažete ovaj posao?',style: TextStyle(color: Colors.white),),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Nazad",style: TextStyle(color: Color.fromRGBO(27, 76, 125, 25)),)),
            TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromRGBO(27, 76, 125, 25),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
            onPressed: () async {
              final navigator = Navigator.of(context);
                final message = ScaffoldMessenger.of(context);
                var jobUpdateRequest = {
                "userId": widget.job.user?.userId,
                "freelancerId": widget.job.freelancer?.freelancerId,
                "companyId": null,
                "jobTitle": widget.job.jobTitle,
                "isTenderFinalized": false,
                "isFreelancer": true,
                "isInvoiced": false,
                "isRated": false,
                "startEstimate": widget.job.startEstimate,
                "endEstimate": null,  
                "payEstimate": null,
                "payInvoice": null,
                "jobDate": widget.job.jobDate.toIso8601String(),
                "dateFinished": null,
                "jobDescription": widget.job.jobDescription,
                "image": widget.job.image,
                "jobStatus": JobStatus.cancelled.name,
                "serviceId": widget.job.jobsServices
                        ?.map((e) => e.service?.serviceId)
                        .toList(),
          };
               var messageRequest = {
                'message1': "Posao ${widget.job.jobTitle} koji ste zakazali za ${DateFormat('dd-MM-yyyy').format(widget.job.jobDate)} je odbijen od strane radnika ${widget.job.freelancer?.freelancerNavigation?.firstName} ${widget.job.freelancer?.freelancerNavigation?.lastName}",
                'userId': widget.job.user?.userId,
                'createdAt': DateTime.now().toIso8601String(),
                'isOpened': false,
              };
              try{
                
                await messagesProvider.insert(messageRequest);
                await jobProvider.update(widget.job.jobId,
                jobUpdateRequest
                );
                message.showSnackBar( SnackBar(content: Text( widget.job.jobStatus==JobStatus.unapproved ? 'Posao odbijen.' : 'Posao otkazan.')));
                navigator.pop(true);
                navigator.pop(true);

              } on Exception catch (e) {
                message.showSnackBar(const SnackBar(content: Text('Greška tokom otkazivanja posla. Pokušajte ponovo.')));
              }
              
           
          
     
          
            },
            child:  Text(widget.job.jobStatus==JobStatus.unapproved ? "Odbaci" : "Otkaži",style: TextStyle(color: Colors.white),),
            ),
      ],
    );
  }
  String formatPhoneNumber(String phone) {
  // Step 1: Replace +387 at the start with 0
  String normalized = phone.replaceFirst(RegExp(r'^\+387'), '0');

  // Step 2: Remove any non-digit characters (in case user inputs spaces, dashes, etc.)
  normalized = normalized.replaceAll(RegExp(r'\D'), '');

  // Step 3: Ensure we only format if we have at least 9 digits
  if (normalized.length < 9) return normalized;

  // Step 4: Insert dashes in 3-3-3 format
  String part1 = normalized.substring(0, 3);
  String part2 = normalized.substring(3, 6);
  String part3 = normalized.substring(6, 9);

  return "$part1-$part2-$part3";
}


  

  @override
  Widget build(BuildContext context) {
    if(_isLoading==true)
    {
      final job = null;
    }
    else{
        final job = jobResult.result.first;
    }
  
    final dateFormat = DateFormat('dd.MM.yyyy');
    final _formKey = GlobalKey<FormBuilderState>();
    final job = jobResult.result.first;

final daysInRange = getWorkingDaysInRange(
  jobDate: job.jobDate,
  dateFinished: job.dateFinished!,
  workingDays:  job.freelancer?.workingDays ?? [],
);
    return Scaffold(

      
      appBar: AppBar(scrolledUnderElevation: 0,title:  Text('Detalji posla',style: Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.normal,
      letterSpacing: 1.2,
      fontFamily: GoogleFonts.lobster().fontFamily,
      color: const Color.fromRGBO(27, 76, 125, 25),


    )),
      centerTitle: true,
   

    
      ),
      body: 
      _isLoading==true ? const Center(child: CircularProgressIndicator()) :
      
       SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                Card(
                color: const Color.fromRGBO(27, 76, 125, 25),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (jobResult?.result.first.isEdited == true || jobResult?.result.first.isWorkerEdited == true) ...[
  Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.amber.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.info, color: Colors.black87),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            "Ovaj posao je ažuriran.",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        if(jobResult?.result.first.isEdited==true)
        ElevatedButton(
          onPressed: () async {
            final jobUpdateRequest = {
              "userId": widget.job.user?.userId,
              "freelancerId": widget.job.freelancer?.freelancerId,
              "companyId":null,
              "jobTitle": widget.job.jobTitle,
              "isTenderFinalized": false,
              "isFreelancer": false,
              "isInvoiced": false,
              "isRated": false,
              "startEstimate": widget.job.startEstimate,
              "endEstimate": widget.job.endEstimate,
              "payEstimate": widget.job.payEstimate,
              "payInvoice": null,
              "jobDate": widget.job.jobDate.toIso8601String(),
             

              "jobDescription": widget.job.jobDescription,
              "image": widget.job.image,
              "jobStatus": widget.job.jobStatus.name,
              "serviceId": widget.job.jobsServices
                  ?.map((e) => e.service?.serviceId)
                  .toList(),
              "isEdited": false,

            };

            try {
              await jobProvider.update(widget.job.jobId, jobUpdateRequest);
              await _getJob(); 
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Posao označen kao pregledan.")),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Greška: $e")),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Označi kao pregledano"),
        ),
      ],
    ),
  ),
],
                    
                      _sectionTitle('Radne specifikacije'),
                  _buildDetailRow('Posao', jobResult.result.first.jobTitle?? 'Nije dostupan'), 
                  _buildDetailRow('Servis', widget.job.jobsServices
                          ?.map((e) => e.service?.serviceName)
                          .where((e) => e != null)
                          .join(', ') ??
                      'N/A'),
                 
                  _buildDetailRow('Datum', dateFormat.format(jobResult.result.first.jobDate)),
                  if(jobResult.result.first.dateFinished!=null)
                  _buildDetailRow('Datum završetka', dateFormat.format(jobResult.result.first.dateFinished!)),
                  if(jobResult.result.first.dateFinished!=null)
                 _buildDetailRow('Radni dani',  daysInRange.join(', ')),
             

                  
               
                  _buildDetailRow('Vrijeme početka', widget.job.startEstimate.toString().substring(0,5)),
                 
                  _buildDetailRow('Vrijeme završetka',
                  jobResult.result.first.endEstimate!=null ?
                      jobResult.result.first.endEstimate.toString().substring(0,5) : 'Nije uneseno'),
                  _buildDetailRow('Opis posla', jobResult.result.first.jobDescription),
                   jobResult.result.first.image!=null ?
                        _buildImageRow(
                                  'Slika',
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(context: context, builder: (context) => _openImageDialog());
                                    
                                    
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child:  const Text(
                                      'Otvori sliku',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(27, 76, 125, 25)),
                                    ),
                                  ))
                              : _buildDetailRow('Slika','Nije unesena'),

                  _buildDetailRow('Stanje', jobResult.result.first.jobStatus==JobStatus.unapproved ? 'Posao još nije odoboren' : 'Odobren posao'), 
 if(jobResult.result.first.isEdited==true)
                  const Divider(height: 32,),
                   if(jobResult.result.first.isEdited==true)
                  _sectionTitle('Promjene'),
                   if(jobResult.result.first.isEdited==true)
                  _buildDetailRow('Poruka korisniku', jobResult.result.first.rescheduleNote??'Nije unesena'),

                  const Divider(height: 32),
                  _sectionTitle('Korisnički podaci'),
                  _buildDetailRow(
                    'Ime i prezime',
                    widget.job.user != null
                        ? '${widget.job.user?.firstName ?? ''} ${widget.job.user?.lastName ?? ''}'
                        : 'Nepoznato',
                  ),
                   _buildDetailRow('Broj Telefona', formatPhoneNumber(widget.job.user!.phoneNumber!)),
                   _buildDetailRow('Lokacija', widget.job.user?.location?.locationName??'Nepoznato'),
                  _buildDetailRow(
                    'Adresa',
                    widget.job.user != null
                        ? '${widget.job.user?.address}'
                        : 'Nepoznato',
                  ),

                  const Divider(height: 32),
                  
                
                   jobResult.result.first.payEstimate!=null ?
                  _buildDetailRow('Procijena',
                      '${jobResult.result.first.payEstimate?.toStringAsFixed(2)} KM'):
                      _buildDetailRow('Procijena','Nije unesena'),
                  
                     
                  
                 
                 

                      
                           
                    ],
                    
                
                  ),
                
                ),
                ),
                _buildFreelancerJobView(),
                Padding(padding: const EdgeInsets.all(8.0)
                ,child:  Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     ElevatedButton(onPressed: () {
                      showDialog(context: context, builder: (context) => _openCancelDialog());
                     


             
          },style: ElevatedButton.styleFrom(backgroundColor:  Colors.red,elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),), child:   Text(widget.job.jobStatus==JobStatus.unapproved ? 'Odbaci' : 'Otkaži',style: TextStyle(color: Colors.white),),),
          const SizedBox(width: 15,),
          if((jobResult.result.first.isEdited==false && jobResult.result.first.isWorkerEdited==false) && jobResult.result.first.jobStatus==JobStatus.approved)
          ElevatedButton(onPressed: () async{
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditJobFreelancer(job: jobResult.result.first)));
            await _getJob();
          },
          style: ElevatedButton.styleFrom(backgroundColor:  Colors.amber,elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),child: const Text('Uredi',style: TextStyle(color: Colors.black),),
          ),
          const SizedBox(width: 15,),

             ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(27, 76, 125, 25),elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),),
            onPressed: () async {
              final message = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
               final isValid =
                        _formKey.currentState?.saveAndValidate() ?? false;
          
                    if (!isValid) {
                      return;
                    }
                    
          
                    var values = Map<String, dynamic>.from(
                        _formKey.currentState?.value ?? {});
                        if (values["endEstimate"] is DateTime) {
            final dateTime = values["endEstimate"] as DateTime;
            final formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
            values["endEstimate"] = formattedTime;
          }
            if (values["dateFinished"] is DateTime) {
                  values["dateFinished"] =
                      (values["dateFinished"] as DateTime).toIso8601String().split('T')[0];
                }

          
              var jobUpdateRequest = {
                "userId": widget.job.user?.userId,
                "freelancerId": widget.job.freelancer?.freelancerId,
                "companyId": null,
                "jobTitle": widget.job.jobTitle,
                "isTenderFinalized": false,
                "isFreelancer": true,
                "isInvoiced": false,
                "isRated": false,
                "startEstimate": widget.job.startEstimate,
                "endEstimate": widget.job.jobStatus== JobStatus.unapproved ? values["endEstimate"] : widget.job.endEstimate,  
                "payEstimate": widget.job.jobStatus== JobStatus.unapproved ? values["payEstimate"] : widget.job.payEstimate,
                "payInvoice": widget.job.jobStatus== JobStatus.unapproved ? null : values["payInvoice"],
                "jobDate": widget.job.jobDate.toIso8601String(),
                "dateFinished": values["dateFinished"],
                "jobDescription": widget.job.jobDescription,
                "image": widget.job.image,
                "jobStatus": widget.job.jobStatus== JobStatus.unapproved ? JobStatus.approved.name : JobStatus.finished.name,
                "serviceId": widget.job.jobsServices
                        ?.map((e) => e.service?.serviceId)
                        .toList(),
          };
           try {
           await jobProvider.update(widget.job.jobId,
            jobUpdateRequest
            );
           
             
              
             
            message.showSnackBar( SnackBar(content:  widget.job.jobStatus == JobStatus.unapproved ? const Text('Posao odobren.') : const Text('Faktura poslana korisniku.')));
            
            navigator.pop(true);
        

          } on Exception catch (e) {
            message.showSnackBar(const SnackBar(content: Text('Greška tokom odobravanja posla. Molimo pokušajte ponoovo.')));
            
            

          }
              
           
            },
            child: const Text('Prihvati',style: TextStyle(color: Colors.white),),
          ),
          const SizedBox(width: 15,),
          if(jobResult.result.first.jobStatus== JobStatus.unapproved)
ElevatedButton(onPressed: () async{
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ApproveJobEdit(job: jobResult.result.first)));

},style: ElevatedButton.styleFrom(backgroundColor: Colors.amber,elevation: 0,shape:
 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),), child:  const Text('Uredi',style: TextStyle(color: Colors.black),),),
          
        
                  ],
                )),
               
              ],
            ),
            ),
          ],
        ),
      ),
    
    );
  }

  Widget _buildFreelancerJobView() {
    final job;
   _isLoading==true ? job = null : job = jobResult.result.first;

  
    bool outOfWorkHours = false;
    String? selectedJobTime = widget.job.startEstimate;

    final parts = selectedJobTime!.split(":");
    final parsedTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,

    int.parse(parts[0]),
    int.parse(parts[1]),);
    DateTime normalizeTime(DateTime t) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, t.hour, t.minute, t.second);
    }
    final startTimeString = widget.job.freelancer?.startTime ?? "08:00";
    final endTimeString = widget.job.freelancer?.endTime ?? "17:00";
    final estimatedStartTime = widget.job.startEstimate;
  final listOfOtherStartTimes = jobFreelancerResult.result
    .where((e) => e.jobId != widget.job.jobId)
    .map((e) => e.startEstimate)
    .toList();

final listOfOtherEndTimes = jobFreelancerResult.result
    .where((e) => e.jobId != widget.job.jobId)
    .map((e) => e.endEstimate)
    .toList();


List<DateTime> parsedList = [];
List<DateTime> parsedEndList = [];

final startTime = parseTime(startTimeString);
final endTime = parseTime(endTimeString);
final parsedEstimatedStartTime = parseTimeString(estimatedStartTime ?? '');

if (listOfOtherStartTimes.isNotEmpty) {
  for (var i in listOfOtherStartTimes) {
    parsedList.add(parseTime(i!));
  }
}

if (listOfOtherEndTimes.isNotEmpty) {
  for (var i in listOfOtherEndTimes) {
    parsedEndList.add(parseTime(i!));
  }
}


   

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
     
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Padding(
                   padding: const EdgeInsets.all(  12),
                   child: Text(
                     'Potrebni podaci',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black), 
                   ),
                 ),
                 if(jobResult.result.first.jobStatus==JobStatus.unapproved)
              Checkbox(value: multiDateJob,onChanged: (value){
                setState(() {
                  multiDateJob=value!;
                });
              },),
               
           ],
         ),
       
        const SizedBox(height: 15),
      
        Container(
          padding: const EdgeInsets.all(8.0),
          child:  Column(
              children: [
                if(widget.job.jobStatus == JobStatus.unapproved)
                Column(
                  children: [
                    if(multiDateJob==true && widget.job.jobStatus==JobStatus.unapproved)
                    FormBuilderDateTimePicker(name: 'dateFinished',
                    locale: Locale('bs'),
                    firstDate: widget.job.jobDate,
                    initialDate: widget.job.jobDate,
                    inputType: InputType.date,
                    selectableDayPredicate: _isWorkingDay,
            
                    decoration: const InputDecoration(
                      labelText: 'Datum završetka',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    )
                    ),
                    const SizedBox(height: 15),
                    FormBuilderDateTimePicker(
                      name: "endEstimate",
                      
                      initialTime: parsedEstimatedStartTime,
                      inputType: InputType.time,
                      firstDate: DateTime.now(),
                      currentDate: DateTime.now(),
                      initialDate: DateTime.now(),
               
                      decoration: const InputDecoration(
                        labelText: 'Vrijeme završetka',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: 'Obavezno polje'),
                        (value) {
                          DateTime selected = normalizeTime(value!);
                        
  DateTime threshold = normalizeTime(parsedTime);
                         
                          if (selected.isBefore(threshold)) {
                            return "Vrijeme mora biti nakon rezervisanog vremena od ${parsedTime.toIso8601String().split('T')[1].substring(0, 5)}h";
                          }
                          if(selected==threshold){
                            return "Vrijeme mora biti nakon rezervisanog vremena od ${parsedTime.toIso8601String().split('T')[1].substring(0, 5)}h";
                          }

                          if (selected.isBefore(startTime)) {
                            return "Van radnog vremena";
                          }
                          if(outOfWorkHours==true){
                            return "Unesite novo vrijeme";
                          }
                         for (int j = 0; j < parsedList.length; j++) {
        DateTime bookedStart = parsedList[j];
  DateTime bookedEnd = parsedEndList[j];

  DateTime newStart = threshold; 
  DateTime newEnd = selected;    

  bool overlaps =
      (newStart.isBefore(bookedEnd) && newEnd.isAfter(bookedStart));

  if (overlaps) {
    return "Ovaj termin je već zauzet drugim poslom. Ako želite da zadržite ovaj posao,\n potrebno je izmijeniti vrijeme početka ili datum.";
  }


       
      }
                          return null;
                        }
                      ]),
                      onChanged: (value) {
    if (value == null) return;

    final selected = normalizeTime(value);
    final maxTime = normalizeTime(endTime);

  DateTime threshold = normalizeTime(parsedTime);

  

    if (selected.isAfter(maxTime)) {

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Van opsega radnog vremena'),
          content: Text(
            'Izabrano vrijeme završetka posla, ${selected.toString().substring(11, 16)} je van definisanog radnog vremena. Da li ste sigurni da želite odabrati navedeno vrijeme?',
          ),
          actions: [
           
           
          TextButton(onPressed: () {
            Navigator.of(ctx).pop();
            
            
          },child: const Text("Nazad",style: TextStyle(color: Colors.black),),),
          ],
        ),
      );
    }}
                    ),
                    const SizedBox(height: 15),
                    FormBuilderTextField(
                      name: "payEstimate",
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Moguća Cijena',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                        ]
                      ),
                      valueTransformer: (value) => double.tryParse(value ?? ''),
                    ),
                  ],
                ),
                  if (widget.job.jobStatus == JobStatus.approved)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                   
                      FormBuilderTextField(
                        name: "payInvoice",
                        enabled:  jobResult.result.first.isEdited==true || jobResult.result.first.isWorkerEdited==true ? false:true,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Finalna cijena',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                         validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.numeric(errorText: 'Decimalu diskriminirati sa tačkom'),
                        ]
                      ),
                      valueTransformer: (value) => double.tryParse(value ?? ''),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        
      ],
    );
  }

  Widget _buildInfoRow(String label, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87),
          children: [
            TextSpan(
                text: text,
                style: const TextStyle(fontWeight: FontWeight.normal))
          ],
        ),
      ),
    );
  }
}