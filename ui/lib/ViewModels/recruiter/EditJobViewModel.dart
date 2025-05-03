import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Models/Categories.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/Models/Recruiters.dart';
import 'package:ui/Services/job_service.dart';
import 'package:ui/ViewModels/recruiter/PostedJobsManagementViewModel.dart';

import '../../Helpers/toastification.dart';
import '../../Models/Enum.dart';
import '../../Services/category_service.dart';

List<String> jobType_value = [
  "Bán thời gian",
  "Toàn thời gian",
  "Làm việc từ xa",
  "Làm việc tự do",
];

List<String> jobLevel_value = ["Intern", "Fresher", "Mid", "Junior", "Senior"];

class EditJobViewModel extends ChangeNotifier {
  final PostedJobsManagementViewModel vm;
  final cRecruiters recruiter;
  final int index;

  bool _check = false;
  bool get check => _check;

  late Future<cJobs?> _jobFuture;
  late Future<List<Map<String, String>>> _categoriesFuture;
  cJobs? job;

  final TextEditingController _categoriesFindText = TextEditingController();
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

  late List<String> _jobCategoryList;
  late List<String> _jobCategorySelectedList;
  String? _jobCategorySelected;

  void getSalary(String salaryText) {
    final negotiableRegex = RegExp(r'^Thỏa thuận$');
    final fixedRegex = RegExp(r'^(\d+)\s(.+)$');
    final uptoRegex = RegExp(r'^Lên đến\s(\d+)\s(.+)$');
    final rangeRegex = RegExp(r'^Từ\s(\d+)\sđến\s(\d+)\s(.+)$');

    if (negotiableRegex.hasMatch(salaryText)) {
      _salaryTypeSelected = "negotiable";
      _salaryUnitSelected = "triệu VNĐ/tháng";
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

  EditJobViewModel({required this.index, required this.vm, required this.recruiter}) {
    _jobFuture = JobService().getJobByID(Id: vm.jobs[index]!.ID, accessToken: APIConstants.accessToken).then((jobF) {
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
      _jobCategorySelectedList = job!.Categories;
      _jobCategoryList.removeWhere((e) => _jobCategorySelectedList.contains(e));
      return jobF;
    });

    _categoriesFuture = CategoryService().getCategory(
        accessToken: APIConstants.accessToken
    ).then((value) {
      _jobCategoryList = value!.map((e) => e.values.first).toList();
      return value;
    });
  }

  DateTime? get selectedDate => _selectedDate;
  Color _jobTypeBorderColor = Colors.grey.shade400;
  Color _jobLevelBorderColor = Colors.grey.shade400;
  Color _salaryUnitBorderColor = Colors.grey.shade400;
  Color _salaryTypeBorderColor = Colors.grey.shade400;
  Color _expiredDateBorderColor = Colors.grey.shade400;
  Color _jobCategoryBorderColor = Colors.grey.shade400;

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

  TextEditingController get categoriesFindText => _categoriesFindText;

  List<Map<String, String>> get jobType => _jobType;

  List<Map<String, String>> get jobLevel => _jobLevel;

  Color get jobLevelBorderColor => _jobLevelBorderColor;

  Color get jobTypeBorderColor => _jobTypeBorderColor;

  String get salaryUnitSelected => _salaryUnitSelected;

  Color get salaryUnitBorderColor => _salaryUnitBorderColor;

  Color get salaryTypeBorderColor => _salaryTypeBorderColor;

  Color get expiredDateBorderColor => _expiredDateBorderColor;

  Color get jobCategoryBorderColor => _jobCategoryBorderColor;

  List<String> get jobCategorySelectedList => _jobCategorySelectedList;

  Future<cJobs?> get jobFuture => _jobFuture;

  List<String> get jobCategoryList => _jobCategoryList;

  String? get jobCategorySelected => _jobCategorySelected;

  Future<List<Map<String, String>>> get categoriesFuture => _categoriesFuture;

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

  void setJobCategoryBorderColor(Color value) {
    _jobCategoryBorderColor = value;
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

  void deleteSelectedJobCategory(int index) {
    _jobCategoryList.add(_jobCategorySelectedList[index]);
    _jobCategorySelectedList.remove(_jobCategorySelectedList[index]);
    notifyListeners();
  }

  void setSelectedJobCategory(String? value) {
      _jobCategoryList.removeWhere((e) => e.toString() == value);
      _jobCategorySelectedList.add(value!);
      if (_jobCategoryBorderColor == Colors.red)
        _jobCategoryBorderColor = Colors.grey.shade400;
      notifyListeners();
  }

  bool _isSalarySelected() {
    if (_salaryTypeSelected == null) return false;
    if (_salaryTypeSelected == "negotiable") {
      return true;
    }
    if (_salaryTypeSelected == "fixed" || _salaryTypeSelected == "upto") {
      return (_salaryNumber1.text.isNotEmpty);
    }
    if (_salaryTypeSelected == "range")
      return (_salaryNumber1.text.isNotEmpty && _salaryNumber2.text.isNotEmpty);
    return false;
  }

  Future<bool> update() async {
    if (_check == false) _check = true;
    notifyListeners();
    if (_nameText.text.isEmpty ||
        _jobCategorySelectedList.isEmpty ||
        _jobLevelSelected == null ||
        _jobDescriptionsText.text.isEmpty ||
        _jobRequirementsText.text.isEmpty ||
        _jobBenefitsText.text.isEmpty ||
        _vacancyText.text.isEmpty ||
        _jobTypeSelected == null ||
        jobCategorySelectedList.isEmpty ||
        _workingTimeText.text.isEmpty ||
        _selectedDate == null ||
        !_isSalarySelected()
    ) {
      showTopToastification(
        content: 'Vui lòng nhập đầy đủ thông tin.',
        title: 'Lỗi!',
        color: Colors.red,
        icon: Icons.error,
      );
      return false;
    }

    late String salaryText;
    if (_salaryTypeSelected == "negotiable") {
      salaryText = "Thỏa thuận";
    } else if (_salaryTypeSelected == "fixed") {
      salaryText = "${_salaryNumber1.text} ${_salaryUnitSelected}";
    } else if (_salaryTypeSelected == "upto") {
      salaryText = "Lên đến ${_salaryNumber1.text} ${_salaryUnitSelected}";
    } else {
      salaryText =
      "Từ ${_salaryNumber1.text} đến ${_salaryNumber2.text} ${_salaryUnitSelected}";
    }
    bool success = await JobService().editJob(
      Id: job!.ID,
      accessToken: APIConstants.accessToken,
      jobData: {
        "Title": _nameText.text,
        "Description": _descriptionText.text,
        "Address": "${recruiter.CompanyLocations.BranchName}: ${recruiter.CompanyLocations.Address}",
        "Salary": salaryText,
        "Vacancies": int.parse(_vacancyText.text),
        "Type": _jobTypeSelected.toString().split(".").last,
        "WorkingTimes": _workingTimeText.text,
        "ExpiredDate": _selectedDate!.toUtc().toIso8601String(),
        "Level": _jobLevelSelected.toString().split(".").last,
        "Descriptions": _jobDescriptionsText.text.split("\n").toList(),
        "Benefits": _jobBenefitsText.text.split("\n").toList(),
        "Requirements": _jobRequirementsText.text.split("\n").toList(),
        "Categories": _jobCategorySelectedList,
      },
    );
    if (success) {
      vm.jobs[index] = vm.jobs[index]!.copyAll(
        Title: _nameText.text,
        Description: _descriptionText.text,
        Address: "${recruiter.CompanyLocations.BranchName}: ${recruiter.CompanyLocations.Address}",
        Salary: salaryText,
        Vacancies: int.parse(_vacancyText.text),
        Type: _jobTypeSelected.toString().split(".").last,
        WorkingTimes: _workingTimeText.text,
        ExpiredAt: _selectedDate!.toUtc(),
        Level: _jobLevelSelected.toString().split(".").last,
        Categories: _jobCategorySelectedList,
      );
      if (vm.jobs[index]!.Status == 'rejected') {
        final updatedJob = vm.jobs[index]!.copyWith(status: 'pending');
        vm.jobs[index] = updatedJob;
        vm.jobs_pending.add(updatedJob);
        vm.jobs_rejected.removeWhere((e) => e!.ID == updatedJob.ID);
        if (vm.statusFilter != 'all') vm.jobs.removeWhere((e) => e!.ID == updatedJob.ID);
      }
      vm.jobs = List.from(vm.jobs);
      vm.notifyListeners();

    }
    return success;
  }
}