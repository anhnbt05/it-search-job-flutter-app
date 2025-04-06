// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Companies.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Companies _$CompaniesFromJson(Map<String, dynamic> json) => Companies(
  id: json['id'] as String,
  name: json['name'] as String,
  websiteUrl: json['websiteUrl'] as String?,
  logoUrl: json['logoUrl'] as String?,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  companyLocations:
      (json['companyLocations'] as List<dynamic>)
          .map((e) => CompanyLocations.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CompaniesToJson(Companies instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'websiteUrl': instance.websiteUrl,
  'logoUrl': instance.logoUrl,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'companyLocations': instance.companyLocations,
};
