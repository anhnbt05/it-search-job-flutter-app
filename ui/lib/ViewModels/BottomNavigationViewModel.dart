import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/recruiter/JobPostViewModel.dart';

import '../Services/CategoryService.dart';

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
    if (jobPostViewModel.categoriesList!.isEmpty || jobPostViewModel.categoriesList == null) {
      jobPostViewModel.categoriesList = await CategoryService().getCategory(
        accessToken: "eyJhbGciOiJIUzI1NiIsImtpZCI6ImVJclVSTTROUldPb3FDS2UiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3F3aWxkZGFxbnJ6bnFiaHVza3p4LnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI2NzRjNzIwNC0xMDZlLTRkN2YtOGRjMy0zZjYzODlkMGFhOGUiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzQ0NTU2NDU5LCJpYXQiOjE3NDQ1NTI4NTksImVtYWlsIjoibGVuZ29jYW5ocHluZTM2M0BnbWFpbC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl0sInJvbGUiOiJyZWNydWl0ZXIifSwidXNlcl9tZXRhZGF0YSI6eyJlbWFpbCI6ImxlbmdvY2FuaHB5bmUzNjNAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInBob25lX3ZlcmlmaWVkIjpmYWxzZSwic3ViIjoiNjc0YzcyMDQtMTA2ZS00ZDdmLThkYzMtM2Y2Mzg5ZDBhYThlIn0sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3NDQ1NTI4NTl9XSwic2Vzc2lvbl9pZCI6IjFmYzhlODY1LTBmNDEtNDkyNS05MTUxLTMzZTcyZDY0ZTJmMiIsImlzX2Fub255bW91cyI6ZmFsc2V9.pTdspdCdWumsm8wI2FMHzogoomsXPyJwDRXiwOZ1yd4"
      );
      jobPostViewModel.jobCategoryIDList = jobPostViewModel.categoriesList!.map((e) => e.keys.first).toList();
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