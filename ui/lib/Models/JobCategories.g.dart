// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JobCategories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobCategories _$JobCategoriesFromJson(Map<String, dynamic> json) =>
    JobCategories(
      categoryId: json['categoryId'] as String,
      jobId: json['jobId'] as String,
      job: Jobs.fromJson(json['job'] as Map<String, dynamic>),
      category: Categories.fromJson(json['category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobCategoriesToJson(JobCategories instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'jobId': instance.jobId,
      'job': instance.job,
      'category': instance.category,
    };
