import 'package:json_annotation/json_annotation.dart';
import 'CompanyLocations.dart';

part 'Locations.g.dart';

@JsonSerializable()
class Locations {
  final String id;
  final String name;
  final String country;
  final DateTime? deletedAt;
  final List<CompanyLocations> companyLocations;

  Locations({
    required this.id,
    required this.name,
    required this.country,
    this.deletedAt,
    required this.companyLocations,
  });

  factory Locations.fromJson(Map<String, dynamic> json) => _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);
}
