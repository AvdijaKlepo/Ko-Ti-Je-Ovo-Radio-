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

class _CompanyEmployeeDetailsState extends State<CompanyEmployeeDetails> with SingleTickerProviderStateMixin {
  late JobProvider jobProvider;
  late PaginatedFetcher<Job> jobPagination;
  late PaginatedFetcher<Job> oldJobPagination;
  late final ScrollController _scrollController;
  late final ScrollController _oldJobScrollController;
  late final TabController _tabController;
  bool _isInitialized = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _oldJobScrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);

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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || isLoading) return const Center(child: CircularProgressIndicator());

    final user = widget.companyEmployee.user;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 700,
        height: 700,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 32),
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildJobSection(
                          jobs: jobPagination.items,
                          controller: _scrollController,
                          emptyMessage: "Trenutno nema aktivnih poslova.",
                        ),
                        _buildJobSection(
                          jobs: oldJobPagination.items,
                          controller: _oldJobScrollController,
                          emptyMessage: "Nema završenih poslova.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  tooltip: 'Zatvori',
                ),
              ),
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
            borderRadius: BorderRadius.circular(16),
            child: user?.image != null
                ? imageFromString(user?.image ?? '')
                : const Image(
                    image: AssetImage('assets/images/Sample_User_Icon.png'),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${user?.firstName ?? ''} ${user?.lastName ?? ''}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 8),
              _infoRow("Telefon", "${user?.phoneNumber ?? ''}"),
              _infoRow("Uloga", "${widget.companyEmployee.companyRoleName ?? ''}"),
              _infoRow("Zaposlen", DateFormat('dd-MM-yyyy').format(widget.companyEmployee.dateJoined ?? DateTime.now())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromRGBO(27, 76, 125, 1),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
        tabs: const [
          Tab(text: "Trenutni poslovi"),
          Tab(text: "Završeni poslovi"),
        ],
      ),
    );
  }

  Widget _buildJobSection({
    required List<Job> jobs,
    required ScrollController controller,
    required String emptyMessage,
  }) {
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      controller: controller,
      itemCount: jobs.length,
      itemBuilder: (_, index) => _jobCard(jobs[index]),
    );
  }

  Widget _jobCard(Job job) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color.fromRGBO(27, 76, 125, 1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.business_center, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Datum: ${DateFormat('dd-MM-yyyy').format(job.jobDate)}",
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _jobDetailRow("Korisnik", "${job.user?.firstName ?? ''} ${job.user?.lastName ?? ''}"),
                  _jobDetailRow("Adresa", job.user?.address ?? ''),
                  _jobDetailRow("Servis", job.jobsServices?.map((e) => e.service?.serviceName ?? '').join(', ') ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jobDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
