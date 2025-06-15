// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_ratings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRating _$UserRatingFromJson(Map<String, dynamic> json) => UserRating()
  ..userId = (json['userId'] as num?)?.toInt()
  ..freelancerId = (json['freelancerId'] as num?)?.toInt()
  ..jobId = (json['jobId'] as num?)?.toInt()
  ..rating = (json['rating'] as num?)?.toDouble()
  ..user = json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>)
  ..freelancer = json['freelancer'] == null
      ? null
      : Freelancer.fromJson(json['freelancer'] as Map<String, dynamic>)
  ..job = json['job'] == null
      ? null
      : Job.fromJson(json['job'] as Map<String, dynamic>);

Map<String, dynamic> _$UserRatingToJson(UserRating instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'freelancerId': instance.freelancerId,
      'jobId': instance.jobId,
      'rating': instance.rating,
      'user': instance.user,
      'freelancer': instance.freelancer,
      'job': instance.job,
    };
