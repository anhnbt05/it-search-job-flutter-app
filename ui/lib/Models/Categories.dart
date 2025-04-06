import 'package:json_annotation/json_annotation.dart';

import 'JobCategories.dart';

part 'Categories.g.dart';

@JsonSerializable()
class Categories {
  final String id;
  final String categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<JobCategories> jobCategories;

  Categories({
    required this.id,
    required this.categoryName,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.jobCategories,
  });

  factory Categories.fromJson(Map<String, dynamic> json) => _$CategoriesFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesToJson(this);
}
