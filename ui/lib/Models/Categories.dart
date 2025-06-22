import 'JobCategories.dart';

class cCategories {
  String? ID;
  String? CategoryName;
  List<cJobCategories>? JobCategories;

  cCategories({required this.ID, required this.CategoryName});

  factory cCategories.fromJson(Map<String, dynamic> json) {
    return cCategories(
      ID: json['ID'],
      CategoryName: json['CategoryName'],
    );
  }
}