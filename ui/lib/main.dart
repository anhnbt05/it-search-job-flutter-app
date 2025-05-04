import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:ui/ViewModels/recruiter/CandidatesAppliesViewModel.dart';
import 'package:ui/Views/admin/admin.dart';
import 'package:ui/Views/candidate/candidate.dart';
import 'package:ui/Views/recruiter/recruiter.dart';

import 'ViewModels/BottomNavigationViewModel.dart';
import 'ViewModels/candidate/JoblistNavigationViewModel.dart';
import 'ViewModels/recruiter/JobPostViewModel.dart';
import 'ViewModels/recruiter/PostedJobsManagementViewModel.dart';
import 'Views/login/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await initializeOneSignal();
  runApp(ToastificationWrapper(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  String? userRole;
  String? userId;

  void loginSuccess(String role, String id) {
    setState(() {
      isLoggedIn = true;
      userRole = role;
      userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavigationViewModel()),
        ChangeNotifierProvider(create: (_) => JoblistNavigationViewModel()),
        ChangeNotifierProvider(create: (_) => LoginNavigationViewModel()),
        ChangeNotifierProvider(create: (_) => CompaniesViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        ChangeNotifierProvider(create: (_) => ProvincesViewModel()),
        ChangeNotifierProvider(create: (_) => SignInViewModel()),

        if (isLoggedIn && userId != null) ...[
          ChangeNotifierProvider(
            create: (_) => PostedJobsManagementViewModel(userId!),
          ),
          ChangeNotifierProvider(
            create: (context) {
              final postedJobsVM = Provider.of<PostedJobsManagementViewModel>(
                context,
                listen: false,
              );
              return JobPostViewModel(
                postedJobsManagementViewModel: postedJobsVM,
              );
            },
          ),
          ChangeNotifierProvider(
            create: (context) {
              final postedJobsVM = Provider.of<PostedJobsManagementViewModel>(
                context,
                listen: false,
              );
              return CandidatesAppliesViewModel(
                postedJobsManagementViewModel: postedJobsVM,
              );
            },
          ),
        ],
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
            isLoggedIn && userRole != null
                ? _MainApp(role: userRole!, userId: userId!)
                : LoginPage(onLoginSuccess: loginSuccess),
      ),
    );
  }
}

class _MainApp extends StatefulWidget {
  final String role;
  final String userId;

  const _MainApp({Key? key, required this.role, required this.userId})
    : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<_MainApp> with TickerProviderStateMixin {
  late String _role;

  @override
  void initState() {
    super.initState();
    _role = widget.role;
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
    final bottomNavigationViewModel = Provider.of<BottomNavigationViewModel>(
      context,
    );

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
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedIconTheme: IconThemeData(
            size: 25,
            color: ColorConstants.appbarColor,
          ),
          unselectedIconTheme: const IconThemeData(
            size: 23,
            color: Colors.black,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
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

  Widget? appbarTitle(String Role, int selectedIndex) {
    if (Role == 'candidate') return appbarTitle_cadidate(selectedIndex);
    if (Role == 'recruiter') return appbarTitle_recruiter(selectedIndex);
    return null;
  }

  List<BottomNavigationBarItem> bottomNavigationItem(String Role) {
    if (Role == 'recruiter') return bottomNavigationItem_recruiter(context);
    if (Role == 'candidate') return bottomNavigationItem_candidate(context);
    return bottomNavigationItem_admin();
  }

  List<Widget> pageView(String Role) {
    if (Role == 'candidate') return pageView_candidate(context);
    if (Role == 'recruiter') return pageView_recruiter(context);
    return pageView_admin(context);
  }
}
