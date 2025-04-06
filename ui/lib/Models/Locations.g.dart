// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
  id: json['id'] as String,
  name: json['name'] as String,
  country: json['country'] as String,
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  companyLocations:
      (json['companyLocations'] as List<dynamic>)
          .map((e) => CompanyLocations.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'country': instance.country,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'companyLocations': instance.companyLocations,
};
