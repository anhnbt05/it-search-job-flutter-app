import 'package:flutter/cupertino.dart';

class UserNavigationViewModel extends ChangeNotifier {
  int _index = 0;
  final PageController _pageController = PageController();

  int get index => _index;
  PageController get pageController => _pageController;

  void onTapAppliedJob_FavJob(int index) {
    if (_index != index) {
      _index = index;
      notifyListeners();
    }

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}