import 'package:flutter/material.dart';
import 'package:ui/model.dart';
class BottomNavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  final PageController _pageController = PageController();

  int get selectedIndex => _selectedIndex;
  PageController get pageController => _pageController;
  AnimationController get animationController => _animationController;

  void setAnimationController(AnimationController controller) {
    _animationController = controller;
  }

  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void onCenterButtonTap() {
    _animationController.forward().then((_) => _animationController.reverse());
    _selectedIndex = 2;
    notifyListeners();

    if (_pageController.hasClients) {
      _pageController.jumpToPage(2);
    }
  }

  void onItemTapped(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();

      if (_pageController.hasClients) {
        if ((index - (_pageController.page ?? 0)).abs() > 1) {
          // Nhảy trực tiếp nếu trang đích không nằm kế bên
          _pageController.jumpToPage(index);
        } else {
          // Hiệu ứng trượt nếu trang đích là trang liền kề
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class JoblistNavigationProvider extends ChangeNotifier{
  int _joblistIndex = 0;
  final PageController _joblistController = PageController();

  int get joblistIndex => _joblistIndex;
  PageController get joblistController => _joblistController;

  void onTapAppliedJob_FavJob(int index) {
    if (_joblistIndex != index) {
      _joblistIndex = index;
      notifyListeners();
    }

    if (_joblistController.hasClients) {
      _joblistController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _joblistController.dispose();
    super.dispose();
  }
}

class JobPostProvider extends ChangeNotifier {
  List<bool> _selectedLocations = List.generate(5, (index) => false);
  String? _jobTypeSelected = null;
  String? _jobLevelSelected = null;
  Color _jobTypeBorderColor = Colors.grey.shade400;
  Color _jobLevelBorderColor = Colors.grey.shade400;
  Color _salaryUnitBorderColor = Colors.grey.shade400;
  Color _salaryTypeBorderColor = Colors.grey.shade400;
  Color _jobCategoryBorderColor = Colors.grey.shade400;
  bool _isAccept = false;
  String? _salaryTypeSelected = null;
  String? _salaryUnitSelected = "option 1";
  DateTime? _selectedDate;
  List<String>? _jobCategoryList = jobCategory.map((e) => e['key']!).toList();
  List<String> _jobCategorySelectedList = [];
  String? _jobCategorySelected = null;
  final TextEditingController _textEditingController = TextEditingController();

  List<bool> get selectedLocations => _selectedLocations;
  String? get jobTypeSelected => _jobTypeSelected;
  String? get jobLevelSelected => _jobLevelSelected;
  Color get jobLevelBorderColor => _jobLevelBorderColor;
  Color get jobTypeBorderColor => _jobTypeBorderColor;
  Color get salaryUnitBorderColor => _salaryUnitBorderColor;
  Color get salaryTypeBorderColor => _salaryTypeBorderColor;
  Color get jobCategoryBorderColor => _jobCategoryBorderColor;
  bool get isAccept => _isAccept;
  String? get salaryTypeSelected => _salaryTypeSelected;
  String? get salaryUnitSelected => _salaryUnitSelected;
  DateTime? get selectedDate => _selectedDate;
  List<String>? get jobCategoryList => _jobCategoryList;
  List<String> get jobCategorySelectedList => _jobCategorySelectedList;
  String? get jobCategorySelected => _jobCategorySelected;
  TextEditingController get textEditingController => _textEditingController;

  void setLocationSelected(int index, bool? value) {
    _selectedLocations[index] = value!;
    notifyListeners();
  }

  void setJobTypeSelected(String? newValue){
    _jobTypeSelected = newValue;
    notifyListeners();
  }

  void setJobTypeBorderColor(Color value) {
    _jobTypeBorderColor = value;
    notifyListeners();
  }

  void setJobLevelBorderColor(Color value) {
    _jobLevelBorderColor = value;
    notifyListeners();
  }

  void setJobLevelSelected(String? newValue) {
    _jobLevelSelected = newValue;
    notifyListeners();
  }

  void setIsAccept() {
    _isAccept = !_isAccept;
    notifyListeners();
  }

  void setSalaryTypeSelected(String? value) {
    _salaryTypeSelected = value;
    notifyListeners();
  }

  void setSalaryUnitSelected(String? value) {
    _salaryUnitSelected = value;
    notifyListeners();
  }

  void setSalaryUnitBorderColor(Color value) {
    _salaryUnitBorderColor = value;
    notifyListeners();
  }

  void setSalaryTypeBorderColor(Color value) {
    _salaryTypeBorderColor = value;
    notifyListeners();
  }

  void setJobCategoryBorderColor (Color value) {
    _jobCategoryBorderColor = value;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void deleteSelectedJobCategory(int index) {
    _jobCategoryList?.add(jobCategory[jobCategory.indexWhere((e) => e['value'] == jobCategorySelectedList[index])]['key']!);
    _jobCategorySelectedList.removeAt(index);
    notifyListeners();
  }

  void setSelectedJobCategory(String? value) {
    if (_jobCategoryList != null) {
      _jobCategoryList!.removeWhere((e) => e.toString() == value);
      _jobCategorySelectedList.add(jobCategory[jobCategory.indexWhere((e) => e['key'] == value)]['value']!);
      notifyListeners();
      print(_jobCategorySelectedList);
      print(_jobCategoryList);
    }
  }
}