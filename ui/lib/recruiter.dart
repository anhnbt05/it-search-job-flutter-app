import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/helpers.dart';
import 'package:ui/providers.dart';
import 'package:ui/model.dart';

List<Widget> pageView_recruiter(BuildContext context) {
  return [
    ManagementScreen(),
    CandidatesAppliedScreen(),
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

Widget CandidatesAppliedScreen() {
  // TODO: Modify section below
  return Container(
    color: Colors.blue.shade100, // Màu nền nhạt
    child: Center(
      child: Text(
        "Danh sách ứng viên đã ứng tuyển",
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}

Widget PostJobScreen(BuildContext context) {
  // TODO: Modify section below
  var jobLocationProvider = Provider.of<JobLocationProvider>(context);

  return Container(
    color: Colors.white,
    child: SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, right: 5),
                      child: Text(
                        'Công ty TNHH Phát triển Công nghệ Thông tin và Truyền thông Việt Nam',
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 19,
                          fontFamily: 'Anton',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, size: 15),
                          SizedBox(width: 5),
                          Text(
                            'Hồ Văn Tên',
                            style: TextStyle(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          titleinJD(title: 'Tên công việc:'),
          customTextField(hintText: 'Nhập tên công việc...', height: 38, textInputType: TextInputType.text),
          titleinJD(title: 'Nơi làm việc:'),
          Column(
            children: List.generate(locations.length, (index) {
              return CheckboxListTile(
                title: Text(
                  locations[index],
                  style: TextStyle(
                    fontSize: 13,
                  ),),
                value: selectedLocations[index],
                onChanged: (bool? value) {
                  jobLocationProvider.setLocationSelected(index, value);
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
          ),
          titleinJD(title: 'Mô tả công việc:'),
          customTextField(hintText: 'Nhập mô tả công việc...', height: 350),
          titleinJD(title: 'Yêu cầu công việc:'),
          customTextField(hintText: 'Nhập yêu cầu công việc...', height: 300),
          Container(height: 400, color: Colors.red),
          Container(height: 500, color: Colors.green),
          Container(height: 400, color: Colors.red),
          Container(height: 500, color: Colors.green),
        ],
      ),
    ),
  );

}

Align titleinJD({required String title}) {
  return Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: EdgeInsets.only(top: 5, left: 10, bottom: 3), // Thêm padding nếu cần
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Container customTextField({required String? hintText,required double height, TextInputType textInputType = TextInputType.multiline}) {
  return Container(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 10),
    child :SizedBox.expand(
    child: TextField(
        textAlignVertical: TextAlignVertical.top,
        keyboardType: textInputType,
        expands: true,
        maxLines: null,
        minLines: null,
        style: TextStyle(
            fontSize: 14
        ),
        decoration: InputDecoration(
          hintText: hintText ,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          isDense: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey, width: 0.1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.blue, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        )

    ),
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
  var navigationProvider = Provider.of<BottomNavigationProvider>(context);
  if (Role == role.recruiter)
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
          onTap: navigationProvider.onCenterButtonTap,
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
  else
    return Positioned(child: SizedBox.shrink());
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