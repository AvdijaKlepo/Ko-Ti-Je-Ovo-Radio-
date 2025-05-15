

import 'package:ko_radio_mobile/models/freelancer.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';



class FreelancerProvider extends BaseProvider<Freelancer>{
  FreelancerProvider(): super("Freelancer?");

  @override
  Freelancer fromJson(data) {
    return Freelancer.fromJson(data);
  
  }
}
