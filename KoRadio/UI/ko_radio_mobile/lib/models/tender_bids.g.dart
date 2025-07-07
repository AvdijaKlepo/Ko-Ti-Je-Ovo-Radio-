// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tender_bids.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenderBid _$TenderBidFromJson(Map<String, dynamic> json) => TenderBid(
      (json['tenderBidId'] as num).toInt(),
    )
      ..jobId = (json['jobId'] as num?)?.toInt()
      ..freelancerId = (json['freelancerId'] as num?)?.toInt()
      ..companyId = (json['companyId'] as num?)?.toInt()
      ..startEstimate = json['startEstimate'] as String?
      ..endEstimate = json['endEstimate'] as String?
      ..bidAmount = (json['bidAmount'] as num?)?.toDouble()
      ..bidDescription = json['bidDescription'] as String?
      ..dateFinished = json['dateFinished'] == null
          ? null
          : DateTime.parse(json['dateFinished'] as String)
      ..createdAt = json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String)
      ..company = json['company'] == null
          ? null
          : Company.fromJson(json['company'] as Map<String, dynamic>)
      ..freelancer = json['freelancer'] == null
          ? null
          : Freelancer.fromJson(json['freelancer'] as Map<String, dynamic>)
      ..job = json['job'] == null
          ? null
          : Job.fromJson(json['job'] as Map<String, dynamic>);

Map<String, dynamic> _$TenderBidToJson(TenderBid instance) => <String, dynamic>{
      'tenderBidId': instance.tenderBidId,
      'jobId': instance.jobId,
      'freelancerId': instance.freelancerId,
      'companyId': instance.companyId,
      'startEstimate': instance.startEstimate,
      'endEstimate': instance.endEstimate,
      'bidAmount': instance.bidAmount,
      'bidDescription': instance.bidDescription,
      'dateFinished': instance.dateFinished?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'company': instance.company,
      'freelancer': instance.freelancer,
      'job': instance.job,
    };
