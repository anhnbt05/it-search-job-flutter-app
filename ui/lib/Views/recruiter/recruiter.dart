import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/Models/model.dart';

import '../../Models/Jobs.dart';
import '../../ViewModels/BottomNavigationViewModel.dart';
import 'CandidatesAppliedView.dart';
import 'JobPostView.dart';
import '../../Models/Applications.dart';

List<Widget> pageView_recruiter(BuildContext context, Future<List<cJobs_recruiter?>> jobsFuture, Future<List<List<cApplications_recruiter>?>> applicationsFuture) {
  return [
    ManagementScreen(),
    CandidatesAppliedScreen(context, jobsFuture, applicationsFuture),
    PostJobScreen(context),
    NotificationsScreen(),
    ProfileScreen(),
  ];
}

Widget ManagementScreen() {
  return Container(
    color: Colors.amberAccent.shade100,
    child: Center(
      child: Text("Quản lý", style: TextStyle(fontSize: 24)),
    ),
  );
}

Widget NotificationsScreen() {
  // TODO: Modify section below
  return Container(
    color: Colors.red.shade100,
    child: Center(
      child: Text(
        "Thông báo",
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}

Widget ProfileScreen() {
  // TODO: Modify section below
  return Container(
    color: Colors.orange.shade100,
    child: Center(
      child: Text(
        "Hồ sơ",
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}

List<BottomNavigationBarItem> bottomNavigationItem_recruiter(BuildContext context) {
  return [
    tabItem(Icons.article_rounded, Icons.article_outlined, 'Quản lý', 0, context),
    tabItem(Icons.assignment_ind_rounded, Icons.assignment_ind_outlined, 'Ứng viên', 1, context),
    hiddenTabItem(),
    tabItem(Icons.notifications_rounded, Icons.notifications_outlined, 'Thông báo', 3, context),
    tabItem(Icons.person_2_rounded, Icons.person_2_outlined, 'Hồ sơ', 4, context),
  ];
}

Positioned buttonAddJDforRecruiter(role Role, BuildContext context) {
  var navigationProvider = Provider.of<BottomNavigationViewModel>(context);
  if (Role == role.recruiter) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + (kBottomNavigationBarHeight / 2) - 25,
      left: MediaQuery.of(context).size.width / 2 - 25,
      child: AnimatedBuilder(
        animation: navigationProvider.animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: navigationProvider.animationController.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () => navigationProvider.onCenterButtonTap(context),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFF071E26), // Xanh den
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  } else {
    return Positioned(child: SizedBox.shrink());
  }
}

Widget? appbarTitle_recruiter(int selectedIndex) {
  // Can be modified to better fit the design objectives
  switch (selectedIndex) {
    case 0:
      return Text('Quản lý',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
    case 1:
      return Text('Danh sách ứng viên',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
    case 2:
      return Text('Thêm tin tuyển dụng',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
    case 3:
      return Text('Thông báo',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
    case 4:
      return Text('Hồ sơ cá nhân',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
  }
  return null;
}