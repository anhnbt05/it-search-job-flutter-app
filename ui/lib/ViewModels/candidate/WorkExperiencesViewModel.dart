import 'package:flutter/material.dart';
import '../../Services/workexperiences_service.dart';

class WorkExperiencesViewModel extends ChangeNotifier {
  final WorkExperiencesService _workExperiencesService = WorkExperiencesService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> addWorkExperience({
    required Map<String, dynamic> workExperienceDto,
    required BuildContext context,
  }) async {
    setLoading(true);
    final success = await _workExperiencesService.postWorkExperience(
      workExperienceDto: workExperienceDto,
      context: context,
    );
    setLoading(false);

    return success;
  }

  Future<bool> updateWorkExperience({
    required String id,
    required Map<String, dynamic> workExperienceDto,
    required BuildContext context,
  }) async {
    setLoading(true);
    final success = await _workExperiencesService.patchWorkExperience(
      workexperienceId: id,
      workExperienceDto: workExperienceDto,
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
