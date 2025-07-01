

import 'package:ko_radio_desktop/models/job.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class JobProvider extends BaseProvider<Job> {
  JobProvider() : super("Job");

  @override
  Job fromJson(data) {
    return Job.fromJson(data);
  }
}
