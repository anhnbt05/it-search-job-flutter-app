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
    FindJobsView(),
    JobListScreen(),
    NotificationView(),
    ProfileCandidateView(),
  ];
}

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  late JoblistNavigationViewModel joblistNavigationProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    joblistNavigationProvider = Provider.of<JoblistNavigationViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (joblistNavigationProvider.pageController.hasClients) {
        joblistNavigationProvider.pageController.jumpToPage(joblistNavigationProvider.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: joblistNavigationProvider.pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        AppliedJobsView(),
        FavoritesJobsView(),
      ],
    );
  }
}


List<BottomNavigationBarItem> bottomNavigationItem_candidate(
    BuildContext context,
    ) {
  return [
    // tabItem(Icons.home_rounded, Icons.home_outlined, 'Trang chủ', 0, context),
    tabItem(
      Icons.search_rounded,
      Icons.search_outlined,
      'Tìm kiếm',
      0,
      context,
    ),
    tabItem(
      Icons.library_books_rounded,
      Icons.library_books_outlined,
      'Danh sách',
      1,
      context,
    ),
    tabItem(Icons.notifications_rounded, Icons.notifications_outlined, 'Thông báo', 2, context),
    tabItem(
      Icons.person_2_rounded,
      Icons.person_2_outlined,
      'Hồ sơ',
      3,
      context,
    ),
  ];
}

Widget? appbarTitle_cadidate(int selectedIndex) {
  // Can be modified to better fit the design objectives
  switch (selectedIndex) {
    // case 0:
    //   return Text(
    //     'My Application',
    //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    //   );
    case 0:
      return Text(
        'Tìm kiếm',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      );
    case 1:
      return Text(
        'Danh sách công việc',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      );
    case 2:
      return Text(
        'Thông báo',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      );
    case 3:
      return Text(
        'Hồ sơ cá nhân',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      );
  }
  return null;
}
