import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/Views/candidate/AppliedJobsView.dart';
import 'package:ui/Views/candidate/NotificationView.dart';
import 'package:ui/Views/candidate/ProfileCandidateView.dart';

import '../../ViewModels/candidate/JoblistNavigationViewModel.dart';
import 'FavoritesJobsView.dart';
import 'FindJobsView.dart';

List<Widget> pageView_candidate(BuildContext context) {
  return [
    HomeScreen(),
    FindJobsView(),
    JobListScreen(context),
    NotificationView(),
    ProfileCandidateView(),
  ];
}

Widget HomeScreen() {
  // TODO: Modify section below
  return Container(
    color: Colors.blue.shade100,
    child: Center(child: Text("Trang chủ", style: TextStyle(fontSize: 24))),
  );
}

Widget JobListScreen(BuildContext context) {
  var joblistNavigationProvider = Provider.of<JoblistNavigationViewModel>(
    context,
  );
  return Container(
    color: Colors.orange.shade100,
    child: PageView(
      controller: joblistNavigationProvider.pageController,
      children: [
        AppliedJobsView(),
        FavoritesJobsView(),
      ],
    ),
  );
}

List<BottomNavigationBarItem> bottomNavigationItem_candidate(
    BuildContext context,
    ) {
  return [
    tabItem(Icons.home_rounded, Icons.home_outlined, 'Trang chủ', 0, context),
    tabItem(
      Icons.search_rounded,
      Icons.search_outlined,
      'Tìm kiếm',
      1,
      context,
    ),
    tabItem(
      Icons.library_books_rounded,
      Icons.library_books_outlined,
      'Danh sách',
      2,
      context,
    ),
    tabItem(Icons.notifications_rounded, Icons.notifications_outlined, 'Thông báo', 3, context),
    tabItem(
      Icons.person_2_rounded,
      Icons.person_2_outlined,
      'Hồ sơ',
      4,
      context,
    ),
  ];
}

Widget? appbarTitle_cadidate(int selectedIndex) {
  // Can be modified to better fit the design objectives
  switch (selectedIndex) {
    case 0:
      return Text(
        'My Application',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      );
    case 1:
      return Text(
        'Tìm kiếm',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      );
    case 2:
      return Text(
        'Danh sách công việc',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      );
    case 3:
      return Text(
        'Thông báo',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      );
    case 4:
      return Text(
        'Hồ sơ cá nhân',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      );
  }
  return null;
}
