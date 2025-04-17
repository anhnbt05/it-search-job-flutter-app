import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/%20Constants/api_constants.dart';
import 'package:ui/Services/application_recruiter_service.dart';
import 'package:ui/Services/job_service.dart';
import 'package:ui/ViewModels/recruiter/JobPostViewModel.dart';

import '../Services/category_service.dart';

class BottomNavigationViewModel extends ChangeNotifier {
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

  void onCenterButtonTap(BuildContext context) async {
    final jobPostViewModel = Provider.of<JobPostViewModel>(context, listen: false);
    _animationController.forward().then((_) => _animationController.reverse());
    _selectedIndex = 2;
    notifyListeners();
    if (_pageController.hasClients) {
      _pageController.jumpToPage(2);
    }
    if (jobPostViewModel.categoriesList == null || jobPostViewModel.categoriesList!.isEmpty) {
      jobPostViewModel.categoriesList = await CategoryService().getCategory(
        accessToken: APIConstants.token
      );
      jobPostViewModel.jobCategoryIDList = jobPostViewModel.categoriesList?.map((e) => e.keys.first).toList();
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