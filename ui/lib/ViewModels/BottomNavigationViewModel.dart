import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/Constants/api_constants.dart';
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
      _pageController.jumpToPage(index);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}