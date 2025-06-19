import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/Constants/color_constants.dart';

import '../../Models/Statistics.dart';

class CompanyChartData {
  final String xData;
  final int yData;
  final String text;
  final Color color;

  CompanyChartData(this.xData, this.yData, this.text, this.color);
}

class CompanyStatisticViewModel extends ChangeNotifier {
  late cCompanyStatistics _company;
  cCompanyStatistics get company => _company;
  late List<CompanyChartData> _company_chartData;
  List<CompanyChartData> get company_chartData => _company_chartData;
  late List<CompanyChartData> _baseApplicationTrendMonthly_chartData;
  List<CompanyChartData> get baseApplicationTrendMonthly_chartData => _baseApplicationTrendMonthly_chartData;
  late List<CompanyChartData> _applicationTrendMonthly_chartData;
  List<CompanyChartData> get applicationTrendMonthly_chartData => _applicationTrendMonthly_chartData;

  int _year = DateTime.now().year;
  int get year => _year;

  CompanyStatisticViewModel({required cCompanyStatistics company, required BuildContext context}) {
    _company = company;
    _company_chartData = company_getChartData(company);
    _baseApplicationTrendMonthly_chartData = getapplicationTrendMonthly_ChartData(company.applicationTrendMonthly, _year);
    _applicationTrendMonthly_chartData = _baseApplicationTrendMonthly_chartData;
  }

  List<CompanyChartData> company_getChartData(cCompanyStatistics stats) {
    return [
      CompanyChartData(
        'Chờ duyệt',
        stats.totalPendingApplications,
        '${(stats.totalPendingApplications / stats.totalApplications * 100).toStringAsFixed(1)}%',
        Colors.yellow.shade400,
      ),
      CompanyChartData(
        'Chấp nhận',
        stats.totalAcceptedApplications,
        '${(stats.totalAcceptedApplications / stats.totalApplications * 100).toStringAsFixed(1)}%',
        Colors.green.shade400,
      ),
      CompanyChartData(
        'Từ chối',
        stats.totalRejectedApplications,
        '${(stats.totalRejectedApplications / stats.totalApplications * 100).toStringAsFixed(1)}%',
        Colors.red.shade400,
      ),
    ];
  }

  List<CompanyChartData> getapplicationTrendMonthly_ChartData(List<cApplicationTrends> stats, int year) {
    return List.generate(12, (idx) {
      int month = idx + 1;
      var data = stats.firstWhere(
            (item) => int.parse(item.month.split('-')[1]) == month && item.month.split('-')[0] == year.toString(),
        orElse: () => cApplicationTrends(month: '$year-${month.toString().padLeft(2, '0')}', totalApplications: 0),
      );

      return CompanyChartData(
        month.toString(),
        data.totalApplications,
        data.totalApplications.toString(),
        ColorConstants.subTextColor,
      );
    });
  }

  void changeYear(int? value) {
    _year = value!;
    print(_year.toString());
    _applicationTrendMonthly_chartData = getapplicationTrendMonthly_ChartData(company.applicationTrendMonthly, _year);
    notifyListeners();
  }

}