import 'package:ko_radio_mobile/models/job.dart';

import 'package:ko_radio_mobile/providers/base_provider.dart';

class JobProvider extends BaseProvider<Job> {
  JobProvider() : super("Job");

  @override
  Job fromJson(data) {
    return Job.fromJson(data);
  }
}
