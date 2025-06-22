import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../Services/workexperiences_service.dart';

class WorkExperiencesViewModel extends ChangeNotifier {
  final List<String> jobTypeOptions = [
    "Bán thời gian",
    "Toàn thời gian",
    "Làm việc từ xa",
    "Làm việc tự do"
  ];

  final Map<String, String> jobTypeApiMapping = {
    "Bán thời gian": "part_time",
    "Toàn thời gian": "full_time",
    "Làm việc từ xa": "remote",
    "Làm việc tự do": "freelance"
  };

  final WorkExperiencesService _workExperiencesService = WorkExperiencesService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> addWorkExperience({
    required String companyName,
    required String position,
    required String startDate,
    required String? endDate,
    required String descriptions,
    required String location,
    required String jobType,
    required File? logoFile,
    required BuildContext context,
  }) async {
    setLoading(true);

    final descriptionsArray = descriptions.split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final success = await _workExperiencesService.postWorkExperience(
      companyName: companyName,
      position: position,
      startDate: startDate,
      endDate: endDate,
      descriptions: jsonEncode(descriptionsArray),
      location: location,
      jobType: jobType,
      logoFile: logoFile,
      context: context,
    );
    setLoading(false);
    return success;
  }

  Future<bool> updateWorkExperience({
    required String id,
    required String companyName,
    required String position,
    required String startDate,
    required String? endDate,
    required String descriptions,
    required String location,
    required String jobType,
    required File? logoFile,
    required BuildContext context,
  }) async {
    setLoading(true);
    final success = await _workExperiencesService.patchWorkExperience(
      workexperienceId: id,
      companyName: companyName,
      position: position,
      startDate: startDate,
      endDate: endDate,
      descriptions: descriptions,
      location: location,
      jobType: jobType,
      logoFile: logoFile,
      context: context,
    );
    setLoading(false);
    return success;
  }

  Future<bool> deleteWorkExperience({
    required String id,
    required BuildContext context,
  }) async {
    setLoading(true);
    final success = await _workExperiencesService.deleteWorkExperience(
      experienceId: id,
      context: context,
    );
    setLoading(false);
    return success;
  }
}