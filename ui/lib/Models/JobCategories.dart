import 'package:json_annotation/json_annotation.dart';

import 'Categories.dart';
import 'Jobs.dart';

part 'JobCategories.g.dart';

@JsonSerializable()
class JobCategories {
  final String categoryId;
  final String jobId;
  final Jobs job;
  final Categories category;

  JobCategories({
    required this.categoryId,
    required this.jobId,
    required this.job,
    required this.category,
  });

  factory JobCategories.fromJson(Map<String, dynamic> json) => _$JobCategoriesFromJson(json);
  Map<String, dynamic> toJson() => _$JobCategoriesToJson(this);
}
