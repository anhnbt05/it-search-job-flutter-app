import 'package:flutter/material.dart';
import 'package:ui/Models/Provinces.dart';
import '../../Services/auth_provinces_service.dart';

class ProvincesViewModel extends ChangeNotifier {
  final AuthProvincesService _service = AuthProvincesService();

  List<cProvinces> _provinces = [];
  List<cProvinces> get provinces => _provinces;

  bool isLoading = false;

  Future<void> fetchProvinces() async {
    isLoading = true;
    notifyListeners();

    final response = await _service.getProvinces();
    if (response.success && response.data is List<cProvinces>) {
      _provinces = response.data;
    }

    isLoading = false;
    notifyListeners();
  }
}