import 'JobCategories.dart';

class cCategories {
  String? ID;
  String? CategoryName;
  DateTime? CreatedAt;
  DateTime? UpdatedAt;
  DateTime? DeletedAt;
  List<cJobCategories>? JobCategories;

  cCategories({required this.ID, required this.CategoryName});
}
