import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:ui/Constants/color_constants.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/ViewModels/AuthViewModel.dart';
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
import 'ViewModels/admin/RecruimentApprovalViewModel.dart';
import 'ViewModels/candidate/JoblistNavigationViewModel.dart';
import 'ViewModels/recruiter/JobPostViewModel.dart';
import 'ViewModels/recruiter/PostedJobsManagementViewModel.dart';
import 'ViewModels/recruiter/ProfileViewModel.dart';
import 'Views/login/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await initializeOneSignal();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: ToastificationWrapper(child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavigationViewModel()),
        ChangeNotifierProvider(create: (_) => LoginNavigationViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        ChangeNotifierProvider(create: (_) => SignInViewModel()),
        ChangeNotifierProvider(create: (_) => JoblistNavigationViewModel()),

        if (authVM.isLoggedIn && authVM.userId != null && authVM.userRole == 'recruiter') ...[
          ChangeNotifierProvider(create: (_) => ProvincesViewModel()),
          ChangeNotifierProvider(create: (_) => CompaniesViewModel()),
          ChangeNotifierProvider(create: (context) => RecruiterProfileViewModel(authVM.userId!, context)),
          ChangeNotifierProvider(
            create: (context) => PostedJobsManagementViewModel(authVM.userId!, context),
          ),
          ChangeNotifierProvider(
            create: (context) {
              final postedJobsVM = Provider.of<PostedJobsManagementViewModel>(context, listen: false,);
              return JobPostViewModel(
                postedJobsManagementViewModel: postedJobsVM,
                context: context,
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
                context: context
              );
            },
          ),
        ],
        if (authVM.isLoggedIn && authVM.userId != null && authVM.userRole == 'admin') ...[
          ChangeNotifierProvider(create: (context) => RecruiterApprovalViewModel(context))
        ]
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
        authVM.isLoggedIn && authVM.userRole != null
            ? _MainApp(role: authVM.userRole!, userId: authVM.userId!)
            : LoginPage(onLoginSuccess: (role, id) {
          authVM.login(role, id);
        }),
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
    if (Role == 'admin') return appbarTitle_admin(selectedIndex);
    return null;
  }

  List<BottomNavigationBarItem> bottomNavigationItem(String Role) {
    if (Role == 'recruiter') return bottomNavigationItem_recruiter(context);
    if (Role == 'candidate') return bottomNavigationItem_candidate(context);
    if (Role == 'admin') return bottomNavigationItem_admin(context);
    return [];
  }

  List<Widget> pageView(String Role) {
    if (Role == 'candidate') return pageView_candidate(context);
    if (Role == 'recruiter') return pageView_recruiter(context);
    if (Role == 'admin') return pageView_admin(context);
    return [];
  }
}
