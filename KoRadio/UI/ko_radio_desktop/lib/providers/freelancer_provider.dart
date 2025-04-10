import 'package:ko_radio_desktop/models/freelancer.dart';

import 'package:ko_radio_desktop/providers/base_provider.dart';

class FreelancerProvider extends BaseProvider<Freelancer>{
  FreelancerProvider(): super("Freelancer?IsServiceIncluded=true");

  @override
  Freelancer fromJson(data) {
    return Freelancer.fromJson(data);
  }
}
