// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tender.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tender _$TenderFromJson(Map<String, dynamic> json) => Tender(
      (json['tenderId'] as num).toInt(),
    )
      ..jobDate = json['jobDate'] == null
          ? null
          : DateTime.parse(json['jobDate'] as String)
      ..jobDescription = json['jobDescription'] as String?
      ..image = json['image'] as String?
      ..isFinalized = json['isFinalized'] as bool?
      ..userId = (json['userId'] as num?)?.toInt()
      ..freelancerId = (json['freelancerId'] as num?)?.toInt()
      ..companyId = (json['companyId'] as num?)?.toInt()
      ..isFreelancer = json['isFreelancer'] as bool?
      ..company = json['company'] == null
          ? null
          : Company.fromJson(json['company'] as Map<String, dynamic>)
      ..user = json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>)
      ..freelancer = json['freelancer'] == null
          ? null
          : Freelancer.fromJson(json['freelancer'] as Map<String, dynamic>)
      ..tenderBids = (json['tenderBids'] as List<dynamic>?)
          ?.map((e) => TenderBid.fromJson(e as Map<String, dynamic>))
          .toList()
      ..tenderServices = (json['tenderServices'] as List<dynamic>?)
          ?.map((e) => TenderService.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$TenderToJson(Tender instance) => <String, dynamic>{
      'tenderId': instance.tenderId,
      'jobDate': instance.jobDate?.toIso8601String(),
      'jobDescription': instance.jobDescription,
      'image': instance.image,
      'isFinalized': instance.isFinalized,
      'userId': instance.userId,
      'freelancerId': instance.freelancerId,
      'companyId': instance.companyId,
      'isFreelancer': instance.isFreelancer,
      'company': instance.company,
      'user': instance.user,
      'freelancer': instance.freelancer,
      'tenderBids': instance.tenderBids,
      'tenderServices': instance.tenderServices,
    };
