import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/Models/Recruiters.dart';
import 'package:ui/Services/job_service.dart';

import '../../Models/Enum.dart';

List<String> jobType_value = [
  "Bán thời gian",
  "Toàn thời gian",
  "Làm việc từ xa",
  "Làm việc tự do",
];

List<String> jobLevel_value = ["Intern", "Fresher", "Mid", "Junior", "Senior"];

class EditJobViewModel extends ChangeNotifier {
  final String ID;
  final cRecruiters recruiter;

  late Future<cJobs?> _jobFuture;
  cJobs? job;

  late TextEditingController _nameText;
  late TextEditingController _descriptionText;
  late TextEditingController _vacancyText;
  late TextEditingController _jobDescriptionsText;
  late TextEditingController _jobRequirementsText;
  late TextEditingController _jobBenefitsText;
  TextEditingController _salaryNumber1 = TextEditingController();
  TextEditingController _salaryNumber2 = TextEditingController();
  late TextEditingController _workingTimeText;

  late eJobType? _jobTypeSelected;
  late eLevel? _jobLevelSelected;

  late String _salaryUnitSelected;
  late DateTime? _selectedDate;

  void getSalary(String salaryText) {
    final negotiableRegex = RegExp(r'^Thỏa thuận$');
    final fixedRegex = RegExp(r'^(\d+)\s(.+)$');
    final uptoRegex = RegExp(r'^Lên đến\s(\d+)\s(.+)$');
    final rangeRegex = RegExp(r'^Từ\s(\d+)\sđến\s(\d+)\s(.+)$');

    if (negotiableRegex.hasMatch(salaryText)) {
      _salaryTypeSelected = "negotiable";
    } else if (fixedRegex.hasMatch(salaryText)) {
      final match = fixedRegex.firstMatch(salaryText)!;
      _salaryTypeSelected = "fixed";
      _salaryNumber1.text = match.group(1)!;
      _salaryUnitSelected = match.group(2)!;
    } else if (uptoRegex.hasMatch(salaryText)) {
      final match = uptoRegex.firstMatch(salaryText)!;
      _salaryTypeSelected = "upto";
      _salaryNumber1.text = match.group(1)!;
      _salaryUnitSelected = match.group(2)!;
    } else if (rangeRegex.hasMatch(salaryText)) {
      final match = rangeRegex.firstMatch(salaryText)!;
      _salaryTypeSelected = "range";
      _salaryNumber1.text = match.group(1)!;
      _salaryNumber2.text = match.group(2)!;
      _salaryUnitSelected = match.group(3)!;
    }
  }

  EditJobViewModel({required this.ID, required this.recruiter}) {
    _jobFuture = JobService().getJobByID(Id: ID, accessToken: APIConstants.token).then((jobF) {
      job = jobF;
      _nameText = TextEditingController(text: jobF!.Title);
      _descriptionText = TextEditingController(text: job!.Description);
      _vacancyText = TextEditingController(text: job!.Vacancies.toString());
      _jobDescriptionsText = TextEditingController(text: job!.JobDescriptions.join('\n'));
      _jobBenefitsText = TextEditingController(text: job!.JobBenefits.join('\n'));
      _jobRequirementsText = TextEditingController(text: job!.JobRequirements.join('\n'));
      _workingTimeText = TextEditingController(text: job!.WorkingTimes);
      _jobTypeSelected = eJobType.values.firstWhere((e) => e.toString().split('.').last == job!.Type);
      _jobLevelSelected = eLevel.values.firstWhere((e) => e.toString().split('.').last == job!.Level);
      _selectedDate = job!.ExpiredAt;
      getSalary(job!.Salary);
      return jobF;
    });
  }

  DateTime? get selectedDate => _selectedDate;
  Color _jobTypeBorderColor = Colors.grey.shade400;
  Color _jobLevelBorderColor = Colors.grey.shade400;
  Color _salaryUnitBorderColor = Colors.grey.shade400;
  Color _salaryTypeBorderColor = Colors.grey.shade400;
  Color _expiredDateBorderColor = Colors.grey.shade400;

  final List<Map<String, String>> _jobLevel = List.generate(
    eLevel.values.length,
        (index) => {
      eLevel.values[index].toString().split(".").last: jobLevel_value[index],
    },
  );

  final List<Map<String, String>> _jobType = List.generate(
    eJobType.values.length,
        (index) => {
      eJobType.values[index].toString().split('.').last: jobType_value[index],
    },
  );

  String? _salaryTypeSelected = null;

  String? get salaryTypeSelected => _salaryTypeSelected;

  eJobType? get jobTypeSelected => _jobTypeSelected;

  eLevel? get jobLevelSelected => _jobLevelSelected;

  TextEditingController get nameText => _nameText;

  TextEditingController get descriptionText => _descriptionText;

  TextEditingController get vacancyText => _vacancyText;

  TextEditingController get jobDescriptionsText => _jobDescriptionsText;

  TextEditingController get workingTimeText => _workingTimeText;

  TextEditingController get salaryNumber2 => _salaryNumber2;

  TextEditingController get salaryNumber1 => _salaryNumber1;

  TextEditingController get jobBenefitsText => _jobBenefitsText;

  TextEditingController get jobRequirementsText => _jobRequirementsText;

  List<Map<String, String>> get jobType => _jobType;

  List<Map<String, String>> get jobLevel => _jobLevel;

  Color get jobLevelBorderColor => _jobLevelBorderColor;

  Color get jobTypeBorderColor => _jobTypeBorderColor;

  String get salaryUnitSelected => _salaryUnitSelected;

  Color get salaryUnitBorderColor => _salaryUnitBorderColor;

  Color get salaryTypeBorderColor => _salaryTypeBorderColor;

  Color get expiredDateBorderColor => _expiredDateBorderColor;


  Future<cJobs?> get jobFuture => _jobFuture;

  void setJobTypeSelected(eJobType? newValue) {
    _jobTypeSelected = newValue;
    notifyListeners();
  }

  void setJobTypeBorderColor(Color value) {
    _jobTypeBorderColor = value;
    notifyListeners();
  }

  void setJobLevelBorderColor(Color value) {
    _jobLevelBorderColor = value;
    notifyListeners();
  }

  void setJobLevelSelected(eLevel? newValue) {
    _jobLevelSelected = newValue;
    if (_jobLevelBorderColor == Colors.red)
      _jobLevelBorderColor = Colors.grey.shade400;
    notifyListeners();
  }

  void setSalaryTypeSelected(String? value) {
    _salaryTypeSelected = value;
    _salaryNumber1 = TextEditingController();
    _salaryNumber2 = TextEditingController();
    if (_salaryTypeBorderColor == Colors.red)
      _salaryTypeBorderColor = Colors.grey.shade400;
    notifyListeners();
  }

  void setSalaryUnitSelected(String value) {
    _salaryUnitSelected = value;
    notifyListeners();
  }

  void setSalaryTypeBorderColor(Color value) {
    _salaryTypeBorderColor = value;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    if (_expiredDateBorderColor == Colors.red)
      _expiredDateBorderColor = Colors.grey.shade400;
    notifyListeners();
  }

  void setSalaryUnitBorderColor(Color value) {
    _salaryUnitBorderColor = value;
    notifyListeners();
  }
}