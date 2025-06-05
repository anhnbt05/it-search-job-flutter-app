import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ui/Constants/color_constants.dart';

import '../Constants/api_constants.dart';
import '../ViewModels/BottomNavigationViewModel.dart';
import '../ViewModels/admin/UserNavigationViewModel.dart';
import '../ViewModels/candidate/JoblistNavigationViewModel.dart';
import '../ViewModels/login/SignInViewModel.dart';

String removeVietnameseAccentsRegex(String text) {
  return text
      .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
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
  var selectedIndex =
      Provider.of<BottomNavigationViewModel>(context).selectedIndex;
  return BottomNavigationBarItem(
    icon: Icon(selectedIndex == index ? iconSelected : iconUnselected),
    label: label,
  );
}

BottomNavigationBarItem hiddenTabItem() {
  return BottomNavigationBarItem(icon: SizedBox.shrink(), label: '');
}

PreferredSize? candidateBottomBar(String Role, int index, BuildContext context) {
  var joblistNavigationProvider = Provider.of<JoblistNavigationViewModel>(
    context,
  );
  if (index != 2)
    return null;
  else if (index == 2) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: Container(
        height: 50,
        child: ClipRect(
          child: BottomNavigationBar(
            selectedItemColor: ColorConstants.appbarColor,
            unselectedLabelStyle: TextStyle(fontSize: 18),
            selectedLabelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            showUnselectedLabels: true,
            currentIndex: joblistNavigationProvider.index,
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
      ),
    );
  }
}

PreferredSize? adminBottomBar(String Role, int index, BuildContext context) {
  var joblistNavigationProvider = Provider.of<UserNavigationViewModel>(
    context,
  );
  if (index != 1)
    return null;
  else if (index == 1) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: Container(
        height: 50,
        color: Colors.white,
        child: ClipRect(
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: ColorConstants.appbarColor,
            unselectedLabelStyle: TextStyle(fontSize: 16),
            selectedLabelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            showUnselectedLabels: true,
            currentIndex: joblistNavigationProvider.index,
            type: BottomNavigationBarType.fixed,
            onTap: joblistNavigationProvider.onTapAppliedJob_FavJob,
            items: [
              BottomNavigationBarItem(
                icon: Container(height: 0, width: 0),
                label: 'Ứng viên ',
              ),
              BottomNavigationBarItem(
                icon: Container(height: 0, width: 0),
                label: 'Nhà tuyển dụng',
              ),
            ],
          ),
        ),
      ),
    );
  }
  return null;
}

Future<Map<String, String>> getDeviceInfo() async {
  final deviceInfoPlugin = DeviceInfoPlugin();

  try {
    if (kIsWeb) {
      final webInfo = await deviceInfoPlugin.webBrowserInfo;
      return {
        'platform': 'Web',
        'deviceInfo':
            'Browser: ${webInfo.browserName.name}, Platform: ${webInfo.platform}, UserAgent: ${webInfo.userAgent}',
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return {
        'platform': 'Android',
        'deviceInfo':
            'Brand: ${androidInfo.brand}, Model: ${androidInfo.model}, Android ${androidInfo.version.release}',
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      return {
        'platform': 'iOS',
        'deviceInfo':
            'Model: ${iosInfo.model}, iOS ${iosInfo.systemVersion}, Device: ${iosInfo.name}',
      };
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfoPlugin.macOsInfo;
      return {
        'platform': 'macOS',
        'deviceInfo': 'Model: ${macInfo.model}, macOS ${macInfo.osRelease}',
      };
    } else if (Platform.isWindows) {
      final winInfo = await deviceInfoPlugin.windowsInfo;
      return {
        'platform': 'Windows',
        'deviceInfo':
            'Computer: ${winInfo.computerName}, RAM: ${winInfo.systemMemoryInMegabytes}MB',
      };
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfoPlugin.linuxInfo;
      return {
        'platform': 'Linux',
        'deviceInfo': 'Distro: ${linuxInfo.prettyName}',
      };
    }
  } catch (e) {
    return {
      'platform': 'Unknown',
      'deviceInfo': 'Failed to get device info: $e',
    };
  }

  return {
    'platform': 'Unsupported',
    'deviceInfo': 'This platform is not supported',
  };
}

Future<String?> getOneSignalPlayerId() async {
  try {
    final playerId = await OneSignal.User.getOnesignalId();

    if (playerId != null && playerId.isNotEmpty) return playerId;

    return null;
  } catch (e) {
    print('Lỗi khi lấy OneSignal PlayerID: $e');
    return null;
  }
}

Future<void> initializeOneSignal() async {
  try {
    String oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';

    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize(oneSignalAppId);

    await OneSignal.Notifications.clearAll();

    await OneSignal.Notifications.requestPermission(true);
  } catch (e) {
    print('Error initializing OneSignal: $e');
  }
}

Future<String?> getValidAccessToken(BuildContext context) async {
  var authViewModel = Provider.of<SignInViewModel>(context, listen: false);
  if (await authViewModel.isAccessTokenExpired()) {
    await authViewModel.refreshAccessToken();
  }
  return await APIConstants.storage.read(key: 'accessToken');
}