import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ui/Helpers/toastification.dart';

import '../../Models/Statistics.dart';
import '../../Services/statistic_service.dart';

class ChartData {
  final String xData;
  final int yData;
  final String text;
  final Color color;

  ChartData(this.xData, this.yData, this.text, this.color);
}

class StatisticsViewModel extends ChangeNotifier {
  final ScrollController _controller = ScrollController();
  ScrollController get controller => _controller;

  cStatistics? _statistics;
  List<cCompanyStatistics>? _baseCompanyStatistics;
  List<cCompanyStatistics>? _companyStatistics;

  cStatistics? get statistics => _statistics;
  List<cCompanyStatistics>? get companyStatistics => _companyStatistics;

  bool _isJobLoading = false;
  bool _isApplicationLoading = false;
  bool _isUserLoading = false;
  bool _isCompanyLoading = false;
  bool _isExportFileExcelLoading = false;
  bool _isExportFilePdfLoading = false;

  late Future<cStatistics?> _statisticsF;
  late Future<List<cCompanyStatistics?>> _companyStatisticsF;

  cJobStatistics? _jobStatistics;
  cApplicationStatistics? _applicationStatistics;
  cUserStatistics? _userStatistics;
  bool _isJobFilterVisible = false;
  bool _isApplicationFilterVisible = false;
  bool _isUserFilterVisible = false;
  bool _isCompanyFilterVisible = false;
  bool _isExportFileFilterVisible = false;

  final TextEditingController _job_startDate = TextEditingController();
  final TextEditingController _job_endDate = TextEditingController();
  final TextEditingController _application_startDate = TextEditingController();
  final TextEditingController _application_endDate = TextEditingController();
  final TextEditingController _user_startDate = TextEditingController();
  final TextEditingController _user_endDate = TextEditingController();
  final TextEditingController _company_startDate = TextEditingController();
  final TextEditingController _company_endDate = TextEditingController();
  final TextEditingController _exportFile_startDate = TextEditingController();
  final TextEditingController _exportFile_endDate = TextEditingController();

  DateTime? _selectedStartDate_job;
  DateTime? _selectedEndDate_job;
  DateTime? _selectedStartDate_application;
  DateTime? _selectedEndDate_application;
  DateTime? _selectedStartDate_user;
  DateTime? _selectedEndDate_user;
  DateTime? _selectedStartDate_company;
  DateTime? _selectedEndDate_company;
  DateTime? _selectedStartDate_exportFile;
  DateTime? _selectedEndDate_exportFile;

  Future<cStatistics?> get statisticsF => _statisticsF;
  Future<List<cCompanyStatistics?>> get companyStatisticsF => _companyStatisticsF;

  cJobStatistics? get jobStatistics => _jobStatistics;
  cApplicationStatistics? get applicationStatistics => _applicationStatistics;
  cUserStatistics? get userStatistics => _userStatistics;

  bool get isJobFilterVisible => _isJobFilterVisible;
  bool get isApplicationFilterVisible => _isApplicationFilterVisible;
  bool get isUserFilterVisible => _isUserFilterVisible;
  bool get isCompanyFilterVisible => _isCompanyFilterVisible;
  bool get isExportFileFilterVisible => _isExportFileFilterVisible;

  TextEditingController get job_startDate => _job_startDate;
  TextEditingController get job_endDate => _job_endDate;
  TextEditingController get application_startDate => _application_startDate;
  TextEditingController get application_endDate => _application_endDate;
  TextEditingController get user_startDate => _user_startDate;
  TextEditingController get user_endDate => _user_endDate;
  TextEditingController get company_startDate => _company_startDate;
  TextEditingController get company_endDate => _company_endDate;
  TextEditingController get exportFile_startDate => _exportFile_startDate;
  TextEditingController get exportFile_endDate => _exportFile_endDate;

  DateTime? get selectedStartDate_job => _selectedStartDate_job;
  DateTime? get selectedEndDate_job => _selectedEndDate_job;
  DateTime? get selectedStartDate_application => _selectedStartDate_application;
  DateTime? get selectedEndDate_application => _selectedEndDate_application;
  DateTime? get selectedStartDate_user => _selectedStartDate_user;
  DateTime? get selectedEndDate_user => _selectedEndDate_user;
  DateTime? get selectedStartDate_company => _selectedStartDate_company;
  DateTime? get selectedEndDate_company => _selectedEndDate_company;
  DateTime? get selectedStartDate_exportFile => _selectedStartDate_exportFile;
  DateTime? get selectedEndDate_exportFile => _selectedEndDate_exportFile;

  List<ChartData> job_getChartData(cJobStatistics stats) {
    return [
      ChartData(
        'Đang mở',
        stats.open,
        '${(stats.open / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff007ce1),
      ),
      ChartData(
        'Chờ duyệt',
        stats.pending,
        '${(stats.pending / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff0090ff),
      ),
      ChartData(
        'Đã đóng',
        stats.closed,
        '${(stats.closed / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff44acff),
      ),
      ChartData(
        'Bị từ chối',
        stats.rejected,
        '${(stats.rejected / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff65bbff),
      ),
      ChartData(
        'Hết hạn',
        stats.expired,
        '${(stats.expired / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff89c7f6),
      ),
    ];
  }

  List<ChartData> application_getChartData(cApplicationStatistics stats) {
    return [
      ChartData(
        'Chờ duyệt',
        stats.pending,
        '${(stats.pending / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xffdad601),
      ),
      ChartData(
        'Chấp nhận',
        stats.accepted,
        '${(stats.accepted / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xfffbf725),
      ),
      ChartData(
        'Từ chối',
        stats.rejected,
        '${(stats.rejected / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xfffffd6a),
      ),
    ];
  }

  List<ChartData> userRole_getChartData(cUserStatistics stats) {
    return [
      ChartData(
        'Ứng viên',
        stats.candidates,
        '${stats.candidates}',
        Color(0xff88f38d),
      ),
      ChartData(
        'Nhà tuyển dụng',
        stats.recruiters,
        '${stats.recruiters}',
        Color(0xffff9b60),
      ),
    ];
  }

  List<ChartData> userStatus_getChartData(cUserStatistics stats) {
    return [
      ChartData(
        'Hoạt động',
        stats.candidates,
        '${stats.candidates}',
        Colors.green,
      ),
      ChartData(
        'Bị khóa',
        stats.recruiters,
        '${stats.recruiters}',
        Colors.red,
      ),
    ];
  }

  late List<ChartData> _job_chartData;
  List<ChartData> get job_chartData => _job_chartData;

  late List<ChartData> _application_chartData;
  List<ChartData> get application_chartData => _application_chartData;

  late List<ChartData> _userRole_chartData;
  List<ChartData> get user_chartData => _userRole_chartData;

  late List<ChartData> _userStatus_chartData;
  List<ChartData> get userStatus_chartData => _userStatus_chartData;

  bool get isJobLoading => _isJobLoading;
  bool get isApplicationLoading => _isApplicationLoading;
  bool get isUserLoading => _isUserLoading;
  bool get isCompanyLoading => _isCompanyLoading;
  bool get isExportFileExcelLoading => _isExportFileExcelLoading;
  bool get isExportFilePdfLoading => _isExportFilePdfLoading;

  void setIsJobLoading(bool value) {
    _isJobLoading = value;
    notifyListeners();
  }

  void setIsApplicationLoading(bool value) {
    _isApplicationLoading = value;
    notifyListeners();
  }

  void setIsUserLoading(bool value) {
    _isUserLoading = value;
    notifyListeners();
  }

  void setIsCompanyLoading(bool value) {
    _isCompanyLoading = value;
    notifyListeners();
  }

  void setIsExportFileExcelLoading(bool value) {
    _isExportFileExcelLoading = value;
    notifyListeners();
  }

  void setIsExportFilePdfLoading(bool value) {
    _isExportFilePdfLoading = value;
    notifyListeners();
  }

  StatisticsViewModel(BuildContext context) {
    _statisticsF = getStatistic(context).then((value) {
      final cStatistics data = value.data as cStatistics;
      _statistics = data;
      _jobStatistics = data.jobStatistics;
      _applicationStatistics = data.applicationStatistics;
      _userStatistics = data.userStatistics;
      _job_chartData = job_getChartData(_jobStatistics!);
      _application_chartData = application_getChartData(_applicationStatistics!);
      _userRole_chartData = userRole_getChartData(_userStatistics!);
      _userStatus_chartData = userStatus_getChartData(_userStatistics!);
      notifyListeners();
      return value.data;
    });

    _companyStatisticsF = getCompanyStatistic(context).then((value) {
      final List<cCompanyStatistics> data = value.data as List<cCompanyStatistics>;
      _baseCompanyStatistics = data;
      _companyStatistics = data;
      _companyStatistics?.sort((a, b) => b.totalJobs.compareTo(a.totalJobs));
      notifyListeners();
      return value.data;
    });
  }

  void setSelectedStartDate_job(DateTime pickedDate) {
    _selectedStartDate_job = pickedDate;
    _job_startDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void setSelectedEndDate_job(DateTime pickedDate) {
    _selectedEndDate_job = pickedDate;
    _job_endDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void setSelectedStartDate_application(DateTime pickedDate) {
    _selectedStartDate_application = pickedDate;
    _application_startDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void setSelectedEndDate_application(DateTime pickedDate) {
    _selectedEndDate_application = pickedDate;
    _application_endDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void setSelectedStartDate_user(DateTime pickedDate) {
    _selectedStartDate_user = pickedDate;
    _user_startDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void setSelectedEndDate_user(DateTime pickedDate) {
    _selectedEndDate_user = pickedDate;
    _user_endDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void setSelectedStartDate_company(DateTime pickedDate) {
    _selectedStartDate_company = pickedDate;
    _company_startDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void setSelectedEndDate_company(DateTime pickedDate) {
    _selectedEndDate_company = pickedDate;
    _company_endDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void setSelectedStartDate_exportFile(DateTime pickedDate) {
    _selectedStartDate_exportFile = pickedDate;
    _exportFile_startDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void setSelectedEndDate_exportFile(DateTime pickedDate) {
    _selectedEndDate_exportFile = pickedDate;
    _exportFile_endDate.text =
    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    notifyListeners();
  }

  void updateJobFilterVisible() {
    _isJobFilterVisible = !_isJobFilterVisible;
    _job_startDate.clear();
    _job_endDate.clear();
    _selectedStartDate_job = null;
    _selectedEndDate_job = null;
    if (!_isJobFilterVisible) {
      _jobStatistics = _statistics!.jobStatistics;
      _job_chartData = job_getChartData(_jobStatistics!);
    }
    notifyListeners();
  }

  void updateApplicationFilterVisible() {
    _isApplicationFilterVisible = !_isApplicationFilterVisible;
    _application_startDate.clear();
    _application_endDate.clear();
    _selectedStartDate_application = null;
    _selectedEndDate_application = null;
    if (!_isApplicationFilterVisible) {
      _applicationStatistics = _statistics!.applicationStatistics;
      _application_chartData = application_getChartData(_applicationStatistics!);
    }
    notifyListeners();
  }

  void updateUserFilterVisible() {
    _isUserFilterVisible = !_isUserFilterVisible;
    _user_startDate.clear();
    _user_endDate.clear();
    _selectedStartDate_user = null;
    _selectedEndDate_user = null;
    if (!_isUserFilterVisible) {
      _userStatistics = _statistics!.userStatistics;
      _userRole_chartData = userRole_getChartData(_userStatistics!);
      _userStatus_chartData = userStatus_getChartData(_userStatistics!);
    }
    notifyListeners();
  }

  void updateExportFileFilterVisible() {
    _isExportFileFilterVisible = !_isExportFileFilterVisible;
    _exportFile_startDate.clear();
    _exportFile_endDate.clear();
    _selectedStartDate_exportFile = null;
    _selectedEndDate_exportFile = null;

    Future.delayed(Duration(milliseconds: 100), () {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });

    notifyListeners();
  }

  void updateCompanyFilterVisible() {
    _isCompanyFilterVisible = !_isCompanyFilterVisible;
    _company_startDate.clear();
    _company_endDate.clear();
    _selectedStartDate_company = null;
    _selectedEndDate_company = null;
    if (!_isCompanyFilterVisible) {
      _companyStatistics = _baseCompanyStatistics;
      _companyStatistics?.sort((a, b) => b.totalAcceptedApplications.compareTo(a.totalAcceptedApplications));
    }
    notifyListeners();
  }

  Future<void> getStatistics_job_applyFilter(BuildContext context) async {
    _statisticsF = getStatistic_filter(
      context,
      _selectedStartDate_job!,
      _selectedEndDate_job!,
    ).then((value) {
      if (value.success) {
        cStatistics data = value.data as cStatistics;
        _jobStatistics = data.jobStatistics;
        _job_chartData = job_getChartData(_jobStatistics!);
        _isJobLoading = false;
        notifyListeners();
      } else {
        showErrorToastification(title: 'Lỗi', message: value.message);
        _isJobLoading = false;
        notifyListeners();
      }
      return value.data;
    });
  }

  Future<void> getStatistics_application_applyFilter(BuildContext context) async {
    _statisticsF = getStatistic_filter(
      context,
      _selectedStartDate_application!,
      _selectedEndDate_application!,
    ).then((value) {
      if (value.success) {
        cStatistics data = value.data as cStatistics;
        _applicationStatistics = data.applicationStatistics;
        _application_chartData = application_getChartData(_applicationStatistics!);
        _isApplicationLoading = false;
        notifyListeners();
      } else {
        showErrorToastification(title: 'Lỗi', message: value.message);
        _isApplicationLoading = false;
        notifyListeners();
      }
      return value.data;
    });
  }

  Future<void> getStatistics_user_applyFilter(BuildContext context) async {
    _statisticsF = getStatistic_filter(
      context,
      _selectedStartDate_user!,
      _selectedEndDate_user!,
    ).then((value) {
      if (value.success) {
        cStatistics data = value.data as cStatistics;
        _userStatistics = data.userStatistics;
        _userRole_chartData = userRole_getChartData(_userStatistics!);
        _userStatus_chartData = userStatus_getChartData(_userStatistics!);
        _isUserLoading = false;
        notifyListeners();
      } else {
        showErrorToastification(title: 'Lỗi', message: value.message);
        _isUserLoading = false;
        notifyListeners();
      }
      return value.data;
    });
  }

  Future<void> getStatistics_company_applyFilter(BuildContext context) async {
    _companyStatisticsF = getCompanyStatistic_filter(
      context,
      _selectedStartDate_company!,
      _selectedEndDate_company!,
    ).then((value) {
      if (value.success) {
        List<cCompanyStatistics> data = value.data as List<cCompanyStatistics>;
        _companyStatistics = data;
        _companyStatistics?.sort((a, b) => b.totalJobs.compareTo(a.totalJobs));
        _isCompanyLoading = false;
        notifyListeners();
      } else {
        showErrorToastification(title: 'Lỗi', message: value.message);
        _isCompanyLoading = false;
      }
      return value.data;
    });
  }

  Future<void> exportFile({required BuildContext context, required String type}) async {
    await postSummaryReport(context, _selectedStartDate_exportFile!, _selectedEndDate_exportFile!, type).then((value) {
      if (type == 'xlsx') {
        _isExportFileExcelLoading = false;
      } else if (type == 'pdf') {
        _isExportFilePdfLoading = false;
      }
      notifyListeners();
      if (value.success) {
        showSuccessToastification(title: 'Hoàn tất', message: value.message);
      }  else {
        showErrorToastification(title: 'Lỗi', message: value.message);
      }
    });
  }
}