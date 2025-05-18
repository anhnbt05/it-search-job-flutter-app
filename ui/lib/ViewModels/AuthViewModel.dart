// Create a new file: lib/Services/AuthService.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BottomNavigationViewModel.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userRole;
  String? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;
  String? get userId => _userId;

  void login(String role, String id) {
    _isLoggedIn = true;
    _userRole = role;
    _userId = id;
    notifyListeners();
  }

  void logout(BuildContext context) {
    var btNavVM = Provider.of<BottomNavigationViewModel>(context, listen: false);
    _isLoggedIn = false;
    _userRole = null;
    _userId = null;
    btNavVM.setIndex(0);
    notifyListeners();
  }
}