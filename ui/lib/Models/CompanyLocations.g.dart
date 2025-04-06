// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CompanyLocations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyLocations _$CompanyLocationsFromJson(Map<String, dynamic> json) =>
    CompanyLocations(
      id: json['id'] as String,
      branchName: json['branchName'] as String,
      address: json['address'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt:
          json['deletedAt'] == null
              ? null
              : DateTime.parse(json['deletedAt'] as String),
      companyId: json['companyId'] as String,
      locationId: json['locationId'] as String,
      company: Companies.fromJson(json['company'] as Map<String, dynamic>),
      location: Locations.fromJson(json['location'] as Map<String, dynamic>),
      recruiters:
          (json['recruiters'] as List<dynamic>)
              .map((e) => Recruiters.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$CompanyLocationsToJson(CompanyLocations instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branchName': instance.branchName,
      'address': instance.address,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'companyId': instance.companyId,
      'locationId': instance.locationId,
      'company': instance.company,
      'location': instance.location,
      'recruiters': instance.recruiters,
    };
