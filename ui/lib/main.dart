import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/providers.dart';
import 'package:ui/helpers.dart';
import 'package:ui/recruiter.dart';
import 'package:ui/candidate.dart';
import 'package:ui/model.dart';
import 'package:ui/admin.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomNavigationProvider()),
        ChangeNotifierProvider(create: (context) => JoblistNavigationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  role _role = role.candidate;

  @override
  void initState() {
    super.initState();
    final bottomNavigationProvider =
    Provider.of<BottomNavigationProvider>(context, listen: false);
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
    final bottomNavigationProvider =
    Provider.of<BottomNavigationProvider>(context, listen: false);
    bottomNavigationProvider.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bottomNavigationProvider = Provider.of<BottomNavigationProvider>(context);
    var joblistNavigationProvider = Provider.of<JoblistNavigationProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedIconTheme: IconThemeData(size: 25, color: color),
          unselectedIconTheme: IconThemeData(size: 23, color: Colors.black),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          selectedItemColor: Colors.black,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.grey.withOpacity(0.5),
      ),
      home: Scaffold(
        //extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 45,
          backgroundColor: color,
          centerTitle: true,
          title: appbarTitle(_role, bottomNavigationProvider.selectedIndex),
          bottom: bottomJobBar(_role, bottomNavigationProvider.selectedIndex, context),
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
    if (Role == role.candidate) return appbarTitle_cadidate(selectedIndex);
    else if (Role == role.recruiter) return appbarTitle_recruiter(selectedIndex);
    else return null;
  }

  List<BottomNavigationBarItem> bottomNavigationItem(role Role) {
    if (Role == role.recruiter)
      return bottomNavigationItem_recruiter(context);
    else if (Role == role.candidate)
      return bottomNavigationItem_candidate(context);
    else
      return bottomNavigationItem_admin();
  }

  List<Widget> pageView(role Role, JoblistNavigationProvider joblistNavigationProvider) {
    if (Role == role.candidate)
      return pageView_candidate(context);
    else if (Role == role.recruiter)
      return pageView_recruiter(context);
    else
      return pageView_admin(context);
  }
}
