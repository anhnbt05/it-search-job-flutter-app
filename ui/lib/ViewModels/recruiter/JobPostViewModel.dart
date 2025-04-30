import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:ui/Helpers/toastification.dart';
import '../../Models/Enum.dart';
import 'package:ui/Services/job_service.dart';

List<String> jobType_value = [
  "Bán thời gian",
  "Toàn thời gian",
  "Làm việc từ xa",
  "Làm việc tự do",
];
List<String> jobLevel_value = ["Intern", "Fresher", "Mid", "Junior", "Senior"];

class JobPostViewModel extends ChangeNotifier {
  bool _check = false;
  final String _branchName = "Thành phố Hồ Chí Minh"; //recruiter.branchname
  final String _address =
      "Số 12 Nguyễn Văn Bảo, Phường 4, Quận Gò Vấp, Thành phố Hồ Chí Minh"; //companyAddress

  eJobType? _jobTypeSelected;
  eLevel? _jobLevelSelected;
  Color _jobTypeBorderColor = Colors.grey.shade400;
  Color _jobLevelBorderColor = Colors.grey.shade400;
  Color _salaryUnitBorderColor = Colors.grey.shade400;
  Color _salaryTypeBorderColor = Colors.grey.shade400;
  Color _jobCategoryBorderColor = Colors.grey.shade400;
  Color _expiredDateBorderColor = Colors.grey.shade400;
  bool _isAccept = false;
  String? _salaryTypeSelected = null;
  String _salaryUnitSelected = "triệu VNĐ/tháng";
  DateTime? _selectedDate;

  List<String> _jobCategorySelectedList = [];
  String? _jobCategorySelected = null;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _nameText = TextEditingController();
  final TextEditingController _descriptionText = TextEditingController();
  final TextEditingController _vacancyText = TextEditingController();
  late final TextEditingController _jobDescriptionsText =
      TextEditingController();
  late final TextEditingController _jobRequirementsText =
      TextEditingController();
  late final TextEditingController _jobBenefitsText = TextEditingController();
  TextEditingController _salaryNumber1 = TextEditingController();
  TextEditingController _salaryNumber2 = TextEditingController();
  final TextEditingController _workingTimeText = TextEditingController();
  List<Map<String, String>>? _categoriesList = [];
  List<String>? _jobCategoryIDList;

  String get address => _address;

  String get branchName => _branchName;

  final List<Map<String, String>> _jobType = List.generate(
    eJobType.values.length,
    (index) => {
      eJobType.values[index].toString().split('.').last: jobType_value[index],
    },
  );

  final List<Map<String, String>> _jobLevel = List.generate(
    eLevel.values.length,
    (index) => {
      eLevel.values[index].toString().split(".").last: jobLevel_value[index],
    },
  );

  eJobType? get jobTypeSelected => _jobTypeSelected;

  eLevel? get jobLevelSelected {
    if (_check == true && _jobLevelSelected == null) {
      _jobLevelBorderColor = Colors.red;
    }
    return _jobLevelSelected;
  }

  Color get jobLevelBorderColor => _jobLevelBorderColor;

  Color get jobTypeBorderColor {
    if (_check == true && _jobTypeSelected == null) {
      _jobTypeBorderColor = Colors.red;
    }
    return _jobTypeBorderColor;
  }

  Color get salaryUnitBorderColor => _salaryUnitBorderColor;

  Color get salaryTypeBorderColor {
    if (_check == true && _salaryTypeSelected == null) {
      _salaryTypeBorderColor = Colors.red;
    }
    return _salaryTypeBorderColor;
  }

  Color get jobCategoryBorderColor {
    if (_check == true && _jobCategorySelectedList.isEmpty) {
      _jobCategoryBorderColor = Colors.red;
    }
    return _jobCategoryBorderColor;
  }

  Color get expiredDateBorderColor {
    if (_check == true && _selectedDate == null) {
      _expiredDateBorderColor = Colors.red;
    }
    return _expiredDateBorderColor;
  }

  bool get isAccept => _isAccept;

  String? get salaryTypeSelected => _salaryTypeSelected;

  String? get salaryUnitSelected => _salaryUnitSelected;

  DateTime? get selectedDate => _selectedDate;

  List<String>? get jobCategoryIDList => _jobCategoryIDList;

  List<String> get jobCategorySelectedList => _jobCategorySelectedList;

  String? get jobCategorySelected => _jobCategorySelected;

  TextEditingController get textEditingController => _textEditingController;

  TextEditingController get nameText => _nameText;

  TextEditingController get descriptionText => _descriptionText;

  TextEditingController get vacancyText => _vacancyText;

  TextEditingController get jobRequirementsText => _jobRequirementsText;

  TextEditingController get jobBenefitsText => _jobBenefitsText;

  TextEditingController get jobDescriptionsText => _jobDescriptionsText;

  TextEditingController get salaryNumber2 => _salaryNumber2;

  TextEditingController get salaryNumber1 => _salaryNumber1;

  TextEditingController get workingTimeText => _workingTimeText;

  List<Map<String, String>> get jobType => _jobType;

  List<Map<String, String>> get jobLevel => _jobLevel;

  List<Map<String, String>>? get categoriesList => _categoriesList;

  bool get check => _check;

  set categoriesList(List<Map<String, String>>? value) {
    _categoriesList = value;
    notifyListeners();
  }

  set jobCategoryIDList(List<String>? value) {
    _jobCategoryIDList = value;
    notifyListeners();
  }

  set check(bool value) {
    _check = true;
    notifyListeners();
  }

  void setJobTypeSelected(eJobType? newValue) {
    _jobTypeSelected = newValue;
    if (_jobTypeBorderColor == Colors.red)
      _jobTypeBorderColor = Colors.grey.shade400;
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

  void setIsAccept() {
    _isAccept = !_isAccept;
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

  void setSalaryUnitBorderColor(Color value) {
    _salaryUnitBorderColor = value;
    notifyListeners();
  }

  void setSalaryTypeBorderColor(Color value) {
    _salaryTypeBorderColor = value;
    notifyListeners();
  }

  void setJobCategoryBorderColor(Color value) {
    _jobCategoryBorderColor = value;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    if (_expiredDateBorderColor == Colors.red)
      _expiredDateBorderColor = Colors.grey.shade400;
    notifyListeners();
  }

  void deleteSelectedJobCategory(int index) {
    _jobCategoryIDList!.add(
      _categoriesList!
          .firstWhere((e) => e.values.first == _jobCategorySelectedList[index])
          .keys
          .first,
    );
    _jobCategorySelectedList.remove(_jobCategorySelectedList[index]);
    notifyListeners();
  }

  void setSelectedJobCategory(String? value) {
    if (_jobCategoryIDList != null) {
      _jobCategoryIDList!.removeWhere((e) => e.toString() == value);
      _jobCategorySelectedList.add(
        _categoriesList!.firstWhere((e) => e.keys.first == value).values.first,
      );
      if (_jobCategoryBorderColor == Colors.red)
        _jobCategoryBorderColor = Colors.grey.shade400;
      notifyListeners();
    }
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

  void post() async {
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
      return;
    }
    if (!_isAccept) {
      showTopToastification(
        content: 'Vui lòng đồng ý với điều khoản và chính sách đăng bài',
        title: 'Lỗi!',
        color: Colors.red,
        icon: Icons.error,
      );
      return;
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
    await new JobService().postJob(
      accessToken: "...",
      jobData: {
        "Title": _nameText.text,
        "Description": _descriptionText.text,
        "Address": _address, //
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
  }
}
