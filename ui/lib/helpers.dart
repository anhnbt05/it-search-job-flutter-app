import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/providers.dart';
import 'package:provider/provider.dart';
import 'package:ui/model.dart';

String removeVietnameseAccentsRegex(String text) {
  return text.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
      .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
      .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
      .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
      .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
      .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
      .replaceAll(RegExp(r'[đ]'), 'd')
      .replaceAll(RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'), 'A')
      .replaceAll(RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'), 'E')
      .replaceAll(RegExp(r'[ÌÍỊỈĨ]'), 'I')
      .replaceAll(RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'), 'O')
      .replaceAll(RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'), 'U')
      .replaceAll(RegExp(r'[ỲÝỴỶỸ]'), 'Y')
      .replaceAll(RegExp(r'[Đ]'), 'D');
}


BottomNavigationBarItem tabItem(
    IconData iconSelected,
    IconData iconUnselected,
    String label,
    int index,
    BuildContext context,
    ) {
  var selectedIndex = Provider.of<BottomNavigationProvider>(context).selectedIndex;
  return BottomNavigationBarItem(
    icon: Icon(selectedIndex == index ? iconSelected : iconUnselected),
    label: label,
  );
}

BottomNavigationBarItem hiddenTabItem() {
  return BottomNavigationBarItem(icon: SizedBox.shrink(), label: '');
}

PreferredSize? bottomJobBar(role Role, int index, BuildContext context) {
  var joblistNavigationProvider = Provider.of<JoblistNavigationProvider>(context);
  if (index != 2 && Role == role.candidate || Role != role.candidate) return null;
  else {
    return
    PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Container(
          height: 50,
          child: ClipRect(child: BottomNavigationBar(
            selectedItemColor: color,
            unselectedLabelStyle: TextStyle(
                fontSize: 18
            ),
            selectedLabelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
            showUnselectedLabels: true,
            currentIndex: joblistNavigationProvider.joblistIndex,
            type: BottomNavigationBarType.fixed,
            onTap: joblistNavigationProvider.onTapAppliedJob_FavJob,
            items: [
              BottomNavigationBarItem(
                icon: Container(height: 0, width: 0),
                label: 'Đã ứng tuyển',
              ),
              BottomNavigationBarItem(
                icon: Container(height: 0, width: 0),
                label: 'Đã thích',
              ),
            ],
          ),
          ),
        )
    );
  }
}