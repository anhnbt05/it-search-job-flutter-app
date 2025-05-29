import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Helpers/helpers.dart';
import 'RecruitmentApprovalView.dart';

List<BottomNavigationBarItem> bottomNavigationItem_admin(BuildContext context) {
  return [
    tabItem(Icons.fact_check_rounded, Icons.fact_check_outlined, 'Kiểm duyệt', 0, context),
    tabItem(Icons.group_rounded, Icons.group_outlined, 'Người dùng', 1, context),
    tabItem(Icons.category_rounded, Icons.category_outlined, 'Danh mục', 2, context),
    tabItem(Icons.table_chart_rounded, Icons.table_chart_outlined, 'Thống kê', 3, context),
  ];
}

List<Widget> pageView_admin (BuildContext context) {
  return [
    RecruitmentApprovalScreen(context),
    page2(context),
    page3(context),
    page4(context),
  ];
}

Widget page2(BuildContext context) {
  return Center(child: Text("2", style: TextStyle(fontSize: 24)));
}

Widget page3(BuildContext context) {
  return Center(child: Text("3", style: TextStyle(fontSize: 24)));
}

Widget page4(BuildContext context) {
  return Center(child: Text("4", style: TextStyle(fontSize: 24)));
}

Widget? appbarTitle_admin(int selectedIndex) {
  switch (selectedIndex) {
    case 0:
      return Text('Kiểm duyệt bài đăng',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),);
    case 1:
      return Text('Quản lý người dùng',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),);
    case 2:
      return Text('Quản lý danh mục',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),);
    case 3:
      return Text('Thống kê',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),);
  }
  return null;
}