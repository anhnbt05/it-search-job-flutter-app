import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/ViewModels/login/LoginNavigationViewModel.dart';
import 'package:ui/Views/recruiter/recruiter.dart';
import 'package:ui/Views/candidate/candidate.dart';
import 'package:ui/Models/model.dart';
import 'package:ui/Views/admin/admin.dart';

import 'ViewModels/BottomNavigationViewModel.dart';
import 'ViewModels/candidate/JoblistNavigationViewModel.dart';
import 'ViewModels/recruiter/JobPostViewModel.dart';
import 'Views/login/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ToastificationWrapper(child:
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BottomNavigationViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => JoblistNavigationViewModel(),
        ),
        ChangeNotifierProvider(create: (context) => JobPostViewModel()),
        ChangeNotifierProvider(create: (context) => LoginViewModel()),
      ],
      child: MyApp(),
    ),
  )
  );
}

class MyApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

/*
class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  void loginSuccess() {
    setState(() {
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? _MainApp() : LoginPage(onLoginSuccess: loginSuccess),
    );
  }
}

class _MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}
*/

class _MainAppState extends State<MyApp> with TickerProviderStateMixin {
  role _role = role.candidate;

  @override
  void initState() {
    super.initState();
    final bottomNavigationProvider = Provider.of<BottomNavigationViewModel>(
      context,
      listen: false,
    );
    bottomNavigationProvider.setAnimationController(
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 1.0,
        upperBound: 1.05,
      ),
    );
  }

  @override
  void dispose() {
    final bottomNavigationProvider = Provider.of<BottomNavigationViewModel>(
      context,
      listen: false,
    );
    bottomNavigationProvider.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bottomNavigationProvider = Provider.of<BottomNavigationViewModel>(
      context,
    );
    var joblistNavigationProvider = Provider.of<JoblistNavigationViewModel>(
      context,
    );

    return MaterialApp(
      locale: Locale('vi', 'VN'),
      supportedLocales: [Locale('vi', 'VN'), Locale('en', 'US')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedIconTheme: IconThemeData(size: 25, color: color),
          unselectedIconTheme: IconThemeData(size: 23, color: Colors.black),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          selectedItemColor: Colors.black,
        ),
        highlightColor: Colors.grey.withOpacity(0.5),
      ),
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 45,
          backgroundColor: color,
          centerTitle: true,
          title: appbarTitle(_role, bottomNavigationProvider.selectedIndex),
          bottom: bottomJobBar(
            _role,
            bottomNavigationProvider.selectedIndex,
            context,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: IconButton(
                //Used to switch between "recruiter" and "candidate", excluding admin
                onPressed: () {
                  setState(() {
                    _role =
                        (_role == role.candidate)
                            ? role.recruiter
                            : role.candidate;
                  });
                },
                icon: Icon(Icons.change_circle_outlined, size: 25),
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: bottomNavigationProvider.pageController,
          children: pageView(_role, joblistNavigationProvider),
        ),
        bottomNavigationBar: Stack(
          children: [
            BottomNavigationBar(
              currentIndex: bottomNavigationProvider.selectedIndex,
              backgroundColor: Colors.white,
              onTap: bottomNavigationProvider.onItemTapped,
              type: BottomNavigationBarType.fixed,
              items: bottomNavigationItem(_role),
            ),

            buttonAddJDforRecruiter(_role, context),
          ],
        ),
      ),
    );
  }

  Widget? appbarTitle(role Role, int selectedIndex) {
    if (Role == role.candidate)
      return appbarTitle_cadidate(selectedIndex);
    else if (Role == role.recruiter)
      return appbarTitle_recruiter(selectedIndex);
    else
      return null;
  }

  List<BottomNavigationBarItem> bottomNavigationItem(role Role) {
    if (Role == role.recruiter)
      return bottomNavigationItem_recruiter(context);
    else if (Role == role.candidate)
      return bottomNavigationItem_candidate(context);
    else
      return bottomNavigationItem_admin();
  }

  List<Widget> pageView(
    role Role,
    JoblistNavigationViewModel joblistNavigationProvider,
  ) {
    if (Role == role.candidate)
      return pageView_candidate(context);
    else if (Role == role.recruiter)
      return pageView_recruiter(context);
    else
      return pageView_admin(context);
  }
}
