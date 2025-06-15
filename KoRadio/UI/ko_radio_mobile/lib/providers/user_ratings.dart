

import 'package:ko_radio_mobile/models/user_ratings.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class UserRatings extends BaseProvider<UserRating> {
  UserRatings() : super("UserRating");

  @override
  UserRating fromJson(data) {
    return UserRating.fromJson(data);
  }
}