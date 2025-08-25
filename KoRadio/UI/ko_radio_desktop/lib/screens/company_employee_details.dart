import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ko_radio_desktop/models/company_employee.dart';
import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/models/job_status.dart';
import 'package:ko_radio_desktop/providers/job_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class CompanyEmployeeDetails extends StatefulWidget {
  const CompanyEmployeeDetails({required this.companyEmployee, super.key});
  final CompanyEmployee companyEmployee;

  @override
  State<CompanyEmployeeDetails> createState() => _CompanyEmployeeDetailsState();
}

class _CompanyEmployeeDetailsState extends State<CompanyEmployeeDetails> {
  late JobProvider jobProvider;
  late PaginatedFetcher<Job> jobPagination;
  late PaginatedFetcher<Job> oldJobPagination;
  late final ScrollController _scrollController;
  late final ScrollController _oldJobScrollController;
  bool _isInitialized = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _oldJobScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    jobProvider = context.read<JobProvider>();

    jobPagination = _createJobPagination(JobStatus.approved.name, _scrollController);
    oldJobPagination = _createJobPagination(JobStatus.finished.name, _oldJobScrollController);

    await jobPagination.refresh();
    await oldJobPagination.refresh();

    setState(() {
      _isInitialized = true;
      isLoading = false;
    });
  }

  PaginatedFetcher<Job> _createJobPagination(String status, ScrollController controller) {
    final fetcher = PaginatedFetcher<Job>(
      pageSize: 20,
      initialFilter: {
        'CompanyEmployeeId': widget.companyEmployee.companyEmployeeId,
        'JobStatus': status,
      },
      fetcher: ({
        required int page,
        required int pageSize,
        Map<String, dynamic>? filter,
      }) async {
        final result = await jobProvider.get(page: page, pageSize: pageSize, filter: filter);
        return PaginatedResult(result: result.result, count: result.count);
      },
    );

    fetcher.addListener(() => setState(() {}));

    controller.addListener(() {
      if (controller.position.pixels >= controller.position.maxScrollExtent - 100 &&
          fetcher.hasNextPage &&
          !fetcher.isLoading) {
        fetcher.loadMore();
      }
    });

    return fetcher;
  }

  @override
  void dispose() {
    jobPagination.dispose();
    oldJobPagination.dispose();
    _scrollController.dispose();
    _oldJobScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || isLoading) return const Center(child: CircularProgressIndicator());

    final user = widget.companyEmployee.user;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 700,
        height: 700,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildJobSection(
                        title: "Trenutni poslovi",
                        jobs: jobPagination.items,
                        controller: _scrollController,
                        emptyMessage: "Trenutno nema aktivnih poslova.",
                      ),
                      const SizedBox(height: 20),
                      _buildJobSection(
                        title: "Završeni poslovi",
                        jobs: oldJobPagination.items,
                        controller: _oldJobScrollController,
                        emptyMessage: "Nema završenih poslova.",
                      ),
                      const SizedBox(height: 20),

                    
                      
                    ],
                  ),
                ),
              ),
                Align(alignment: Alignment.bottomRight,child: FloatingActionButton(onPressed: (){Navigator.of(context).pop();},child: const Icon(Icons.close,color: Colors.white,),)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: user?.image != null
                ? imageFromString(user?.image ?? '')
                : const Image(
                    image: AssetImage('assets/images/Sample_User_Icon.png'),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("Ime:", "${user?.firstName ?? ''} ${user?.lastName ?? ''}"),
              _infoRow("Telefon:", "${user?.phoneNumber ?? ''}"),
              _infoRow("Uloga:", "${widget.companyEmployee.companyRoleName ?? ''}"),
              _infoRow("Zaposlen:", DateFormat('dd-MM-yyyy')
                  .format(widget.companyEmployee.dateJoined ?? DateTime.now())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSection({
    required String title,
    required List<Job> jobs,
    required ScrollController controller,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const Divider(),
        jobs.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                controller: controller,
                itemCount: jobs.length,
                itemBuilder: (_, index) => _jobCard(jobs[index]),
              ),
             
      ],
    );
  }

  Widget _jobCard(Job job) {
    return Card(
      color: const Color.fromRGBO(27, 76, 125, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Datum: ${DateFormat('dd-MM-yyyy').format(job.jobDate)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  _jobDetailRow("Korisnik:", "${job.user?.firstName ?? ''} ${job.user?.lastName ?? ''}"),
                  _jobDetailRow("Telefon:", "${job.user?.phoneNumber ?? ''}"),
                  _jobDetailRow("Adresa:", "${job.user?.address ?? ''}"),
                  _jobDetailRow("Posao:", "${job.jobTitle ?? ''}"),
                  _jobDetailRow("Opis:", "${job.jobDescription ?? ''}"),
                  _jobDetailRow("Status:", job.isInvoiced == true ? 'Plaćen' : 'Nije plaćen'),
             

                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.work_outline, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _jobDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text("$label $value", style: const TextStyle(color: Colors.white)),
    );
  }
}
