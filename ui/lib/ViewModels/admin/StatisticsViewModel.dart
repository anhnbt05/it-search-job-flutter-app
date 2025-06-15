import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:ui/Helpers/toastification.dart';

import '../../Models/Statistics.dart';
import '../../Services/statistic_service.dart';

class PieData {
  final String xData;
  final int yData;
  final String text;
  final Color color;

  PieData(this.xData, this.yData, this.text, this.color);
}

class StatisticsViewModel extends ChangeNotifier {
  cStatistics? _statistics;
  cStatistics? get statistics => _statistics;

  bool _isJobLoading = false;
  bool _isApplicationLoading = false;

  Future<cStatistics?>? _statisticsF;
  cJobStatistics? _jobStatistics;
  cApplicationStatistics? _applicationStatistics;
  bool _isJobFilterVisible = false;
  bool _isApplicationFilterVisible = false;

  final TextEditingController _job_startDate = TextEditingController();
  final TextEditingController _job_endDate = TextEditingController();
  final TextEditingController _application_startDate = TextEditingController();
  final TextEditingController _application_endDate = TextEditingController();

  DateTime? _selectedStartDate_job;
  DateTime? _selectedEndDate_job;
  DateTime? _selectedStartDate_application;
  DateTime? _selectedEndDate_application;

  Future<cStatistics?> get statisticsF => _statisticsF!;

  cJobStatistics? get jobStatistics => _jobStatistics;

  cApplicationStatistics? get applicationStatistics => _applicationStatistics;

  bool get isJobFilterVisible => _isJobFilterVisible;

  bool get isApplicationFilterVisible => _isApplicationFilterVisible;

  TextEditingController get job_startDate => _job_startDate;

  TextEditingController get job_endDate => _job_endDate;

  TextEditingController get application_startDate => _application_startDate;

  TextEditingController get application_endDate => _application_endDate;

  DateTime? get selectedStartDate_job => _selectedStartDate_job;

  DateTime? get selectedEndDate_job => _selectedEndDate_job;

  DateTime? get selectedStartDate_application => _selectedStartDate_application;

  DateTime? get selectedEndDate_application => _selectedEndDate_application;

  List<PieData> job_getPieData(cJobStatistics stats) {
    return [
      PieData(
        'Đang mở',
        stats.open,
        '${(stats.open / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff007ce1),
      ),
      PieData(
        'Chờ duyệt',
        stats.pending,
        '${(stats.pending / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff0090ff),
      ),
      PieData(
        'Đã đóng',
        stats.closed,
        '${(stats.closed / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff44acff),
      ),
      PieData(
        'Bị từ chối',
        stats.rejected,
        '${(stats.rejected / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff65bbff),
      ),
      PieData(
        'Hết hạn',
        stats.expired,
        '${(stats.expired / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xff89c7f6),
      ),
    ];
  }

  List<PieData> application_getPieData(cApplicationStatistics stats) {
    return [
      PieData(
        'Chờ duyệt',
        stats.pending,
        '${(stats.pending / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xffdad601),
      ),
      PieData(
        'Chấp nhận',
        stats.accepted,
        '${(stats.accepted / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xfffbf725),
      ),
      PieData(
        'Từ chối',
        stats.rejected,
        '${(stats.rejected / stats.total * 100).toStringAsFixed(1)}%',
        Color(0xfffffd6a),
      ),
    ];
  }

  late List<PieData> _job_pieData;

  List<PieData> get job_pieData => _job_pieData;
  late List<PieData> _application_pieData;

  List<PieData> get application_pieData => _application_pieData;

  bool get isJobLoading => _isJobLoading;

  void setIsJobLoading(bool value) {
    _isJobLoading = value;
    notifyListeners();
  }

  bool get isApplicationLoading => _isApplicationLoading;

  void setIsApplicationLoading(bool value) {
    _isApplicationLoading = value;
    notifyListeners();
  }

  StatisticsViewModel(BuildContext context) {
    _statisticsF = getStatistic(context).then((value) {
      final cStatistics data = value.data as cStatistics;
      _statistics = data;
      _jobStatistics = data.jobStatistics;
      _applicationStatistics = data.applicationStatistics;
      _job_pieData = job_getPieData(_jobStatistics!);
      _application_pieData = application_getPieData(_applicationStatistics!);
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

  void updateJobFilterVisible() {
    _isJobFilterVisible = !_isJobFilterVisible;
    _job_startDate.clear();
    _job_endDate.clear();
    _selectedStartDate_job = null;
    _selectedEndDate_job = null;
    if (!_isJobFilterVisible) _jobStatistics = _statistics!.jobStatistics;
    notifyListeners();
  }

  void updateApplicationFilterVisible() {
    _isApplicationFilterVisible = !_isApplicationFilterVisible;
    _application_startDate.clear();
    _application_endDate.clear();
    _selectedStartDate_application = null;
    _selectedEndDate_application = null;
    if (!_isApplicationFilterVisible)
      _applicationStatistics = _statistics!.applicationStatistics;
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
        _isJobLoading = false;
        notifyListeners();
      } else {
        showErrorToastification(title: 'Lỗi', message: value.message);
        _isJobLoading = false;
        notifyListeners();
      }
      ;
      return value.data;
    });
  }

  Future<void> getStatistics_application_applyFilter(
    BuildContext context,
  ) async {
    _statisticsF = getStatistic_filter(
      context,
      _selectedStartDate_application!,
      _selectedEndDate_application!,
    ).then((value) {
      if (value.success) {
        cStatistics data = value.data as cStatistics;
        _applicationStatistics = data.applicationStatistics;
        _isApplicationLoading = false;
        notifyListeners();
      } else {
        showErrorToastification(title: 'Lỗi', message: value.message);
        _isApplicationLoading = false;
        notifyListeners();
      };
      return value.data;
    });
  }
}
