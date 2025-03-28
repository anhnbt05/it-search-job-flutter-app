import 'package:flutter/material.dart';

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