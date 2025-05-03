import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:ui/Constants/color_constants.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/ViewModels/login/CompaniesViewModel.dart';
import 'package:ui/ViewModels/login/LoginNavigationViewModel.dart';
import 'package:ui/ViewModels/login/ProvincesViewModel.dart';
import 'package:ui/ViewModels/login/SignInViewModel.dart';
import 'package:ui/ViewModels/login/SignUpViewModel.dart';
import 'package:ui/Services/application_recruiter_service.dart';
import 'package:ui/ViewModels/recruiter/CandidatesAppliesViewModel.dart';
import 'package:ui/Views/recruiter/recruiter.dart';
import 'package:ui/Views/candidate/candidate.dart';
import 'package:ui/Views/admin/admin.dart';

import 'Constants/api_constants.dart';
import 'Models/Applications.dart';
import 'Models/Jobs.dart';
import 'Models/model.dart';
import 'Services/job_service.dart';
import 'ViewModels/BottomNavigationViewModel.dart';
import 'ViewModels/candidate/JoblistNavigationViewModel.dart';
import 'ViewModels/recruiter/JobPostViewModel.dart';
import 'ViewModels/recruiter/PostedJobsManagementViewModel.dart';
import 'Views/login/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ToastificationWrapper(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BottomNavigationViewModel()),
          ChangeNotifierProvider(create: (_) => JoblistNavigationViewModel()),
          ChangeNotifierProvider(create: (_) => LoginNavigationViewModel()),
          ChangeNotifierProvider(create: (_) => CompaniesViewModel()),
          ChangeNotifierProvider(create: (_) => SignUpViewModel()),
          ChangeNotifierProvider(create: (_) => ProvincesViewModel()),
          ChangeNotifierProvider(create: (_) => PostedJobsManagementViewModel()),
          ChangeNotifierProvider(
            create: (context) {
              final postedJobsVM = Provider.of<PostedJobsManagementViewModel>(context, listen: false);
              return JobPostViewModel(postedJobsManagementViewModel: postedJobsVM);
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              final postedJobsVM = Provider.of<PostedJobsManagementViewModel>(context, listen: false);
              return CandidatesAppliesViewModel(postedJobsManagementViewModel: postedJobsVM);
            },
          ),
          ChangeNotifierProvider(create: (_) => SignInViewModel()),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  String? userRole;

  void loginSuccess(String role) {
    setState(() {
      isLoggedIn = true;
      userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn
          ? _MainApp(role: userRole!)
          : LoginPage(onLoginSuccess: loginSuccess),
    );
  }
}

class _MainApp extends StatefulWidget {
  final String role;

  const _MainApp({Key? key, required this.role}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<_MainApp> with TickerProviderStateMixin {
  late role _role;

  @override
  void initState() {
    super.initState();

    _role = role.values.firstWhere(
          (e) => e.toString().split('.').last == widget.role,
    );

    final bottomNavigationProvider = Provider.of<BottomNavigationViewModel>(context, listen: false);
    final candidateAppliesViewModel = Provider.of<CandidatesAppliesViewModel>(context, listen: false);

    candidateAppliesViewModel.initFutures();
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
    final bottomNavigationProvider = Provider.of<BottomNavigationViewModel>(context, listen: false);
    bottomNavigationProvider.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavigationViewModel = Provider.of<BottomNavigationViewModel>(context);
    
    return MaterialApp(
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedIconTheme: IconThemeData(size: 25, color: ColorConstants.appbarColor),
          unselectedIconTheme: const IconThemeData(size: 23, color: Colors.black),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedLabelStyle: const TextStyle(
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
          backgroundColor: ColorConstants.appbarColor,
          centerTitle: true,
          title: appbarTitle(_role, bottomNavigationViewModel.selectedIndex),
          bottom: bottomJobBar(
            _role,
            bottomNavigationViewModel.selectedIndex,
            context,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _role = (_role == role.candidate) ? role.recruiter : role.candidate;
                  });
                },
                icon: const Icon(Icons.change_circle_outlined, size: 25),
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: bottomNavigationViewModel.pageController,
          children: pageView(_role),
        ),
        bottomNavigationBar: Stack(
          children: [
            BottomNavigationBar(
              currentIndex: bottomNavigationViewModel.selectedIndex,
              backgroundColor: Colors.white,
              onTap: bottomNavigationViewModel.onItemTapped,
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
    if (Role == role.recruiter) return appbarTitle_recruiter(selectedIndex);
    return null;
  }

  List<BottomNavigationBarItem> bottomNavigationItem(role Role) {
    if (Role == role.recruiter) return bottomNavigationItem_recruiter(context);
    if (Role == role.candidate) return bottomNavigationItem_candidate(context);
    return bottomNavigationItem_admin();
  }

  List<Widget> pageView(role Role) {
    if (Role == role.candidate) return pageView_candidate(context);
    if (Role == role.recruiter) return pageView_recruiter(context);
    return pageView_admin(context);
  }
}
