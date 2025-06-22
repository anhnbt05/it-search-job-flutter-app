import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../Helpers/helpers.dart';
import '../../Models/Categories.dart';
import '../../Models/ResponseModel.dart';
import '../../Services/category_service.dart';

class CategoryManagementViewModel extends ChangeNotifier {
  List<cCategories>? _categories;
  List<cCategories>? _categoryList;
  late Future<List<cCategories>> _categoryF;
  final TextEditingController _nameController = TextEditingController();

  Future<List<cCategories>> get categoryF => _categoryF;
  List<cCategories>? get categories => _categories;
  List<cCategories>? get categoryList => _categoryList;
  TextEditingController get nameController => _nameController;

  CategoryManagementViewModel(BuildContext context) {
    _categoryF = CategoryService().getCategory2(context: context).then((jsonList) {
      _categoryList = jsonList?.map<cCategories>((json) => cCategories.fromJson(json)).toList();
      _categoryList?.sort((a, b) => a.CategoryName!.compareTo(b.CategoryName!));
      _categories = _categoryList;
      notifyListeners();
      return _categories!;
    });
  }

  Future<bool> addCategory(BuildContext context, String categoryName) async {
    ResponseModel responseModel = await CategoryService().addCategory(context: context, categoryName: categoryName);
    if (responseModel.success) {
      nameController.clear();
      print(responseModel.data);
      _categories = responseModel.data;
      _categories!.sort((a, b) => a.CategoryName!.compareTo(b.CategoryName!));
      notifyListeners();
      return true;
    }
    return false;
  }

  void filterCategoryByName(String query) {
    final q = query.toLowerCase().trim();
    _categories = _categoryList?.where((e) {
      final title = e.CategoryName!.toLowerCase() ?? '';
      return removeVietnameseAccentsRegex(title).contains(removeVietnameseAccentsRegex(q));
    }).toList();
    notifyListeners();
  }
}
