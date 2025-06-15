import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Helpers/toastification.dart';
import '../../ViewModels/admin/StatisticsViewModel.dart';

Widget StatisticsScreen(BuildContext context) {
  var viewModel = Provider.of<StatisticsViewModel>(context);
  if (viewModel.statistics == null) {
    return FutureBuilder(
    future: viewModel.statisticsF,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        );
      } else {
        return body(viewModel: viewModel, context: context);
      }
    },
  );
  } else {
    return body(viewModel: viewModel, context: context);
  }
}

Widget body({required StatisticsViewModel viewModel, required BuildContext context}) {
  return ListView(
    children: [
      jobStatistics(viewModel: viewModel, context: context),
      SizedBox(height: 5,),
      applicationStatistics(viewModel: viewModel, context: context),
    ],
  );
}

Widget jobStatistics({required StatisticsViewModel viewModel, required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: const EdgeInsets.only(top: 5, left: 7), child: Text("Thống kê bài tuyển dụng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      viewModel.updateJobFilterVisible();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: (!viewModel.isJobFilterVisible) ? Colors.black : Colors.red,
                          width: 1.0,
                        ),
                        color: Colors.white,
                      ),
                      child: (!viewModel.isJobFilterVisible) ? Icon(Icons.filter_alt_outlined) : Icon(Icons.filter_alt_off_outlined, color: Colors.red,),
                    ),
                  ),
                  SizedBox(width: 10,),
                ],
              ),
            ],
          ),
          SizedBox(height: 10,),
          (viewModel.isJobFilterVisible)
              ? Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  height: 30,
                  child: Builder(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextField(
                          readOnly: true,
                          textAlign: TextAlign.left,
                          controller: viewModel.job_startDate,
                          decoration: InputDecoration(
                            hintText: 'Ngày bắt đầu',
                            suffixIcon: Icon(Icons.calendar_today, size: 15),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.only(top: 2),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              locale: Locale('vi', 'VN'),
                              context: context,
                              initialDate: viewModel.selectedStartDate_job??DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              viewModel.setSelectedStartDate_job(pickedDate);
                            }
                          },
                        ),
                      );
                    }
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  height: 30,
                  child: Builder(
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: TextField(
                            readOnly: true,
                            textAlign: TextAlign.left,
                            controller: viewModel.job_endDate,
                            decoration: InputDecoration(
                              hintText: 'Ngày kết thúc',
                              suffixIcon: Icon(Icons.calendar_today, size: 15),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.only(top: 2),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                locale: Locale('vi', 'VN'),
                                context: context,
                                initialDate: viewModel.selectedEndDate_job??DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                viewModel.setSelectedEndDate_job(pickedDate);
                              }
                            },
                          ),
                        );
                      }
                  ),
                ),
              )
            ],
          )
              : SizedBox.shrink(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2 + 20,
                child: Align(
                  child: (viewModel.jobStatistics!.total > 0) ? SfCircularChart(
                    margin: EdgeInsets.zero,
                    series: <PieSeries<PieData, String>>[
                      PieSeries<PieData, String>(
                        explode: true,
                        animationDuration: 300,
                        radius: '90%',
                        dataSource: viewModel.job_pieData,
                        xValueMapper: (PieData data, _) => data.xData,
                        yValueMapper: (PieData data, _) => data.yData,
                        dataLabelMapper: (PieData data, _) => data.text,
                        pointColorMapper: (PieData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ) : SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        decoration:
                        BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.lightBlue
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          child: Text(
                            "Tổng: ${viewModel.jobStatistics!.total}",
                            style: TextStyle(fontWeight: FontWeight.w500,
                                color: Colors.white,
                            fontSize: 17),),
                        )
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: viewModel.job_pieData.map((item) {
                        return Row(
                          children: [
                            Text("●", style: TextStyle(fontSize: 16, color: item.color)),
                            const SizedBox(width: 4),
                            Text("${item.xData}: ${item.yData}"),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
            ],
          ),
          (viewModel.isJobFilterVisible)
              ? Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      viewModel.setIsJobLoading(true);
                      if (viewModel.selectedStartDate_job == null) {
                        showErrorToastification(title: 'Lỗi', message: 'Vui lòng chọn ngày bắt đầu');
                        viewModel.setIsJobLoading(false);
                        return;
                      }
                      if (viewModel.selectedEndDate_job == null) {
                        showErrorToastification(title: 'Lỗi', message: 'Vui lòng chọn ngày kết thúc');
                        viewModel.setIsJobLoading(false);
                        return;
                      }
                      await viewModel.getStatistics_job_applyFilter(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xee65c29c),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      minimumSize: Size(0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius
                            .circular(7),
                      ),
                    ),
                    child: (viewModel.isJobLoading) ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white,)) : Text(
                      'Thống kê',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )
              : SizedBox.shrink(),
        ],
      ),
    ),
  );
}

Widget applicationStatistics({required StatisticsViewModel viewModel, required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: const EdgeInsets.only(top: 5, left: 7), child: Text("Thống kê đơn ứng tuyển",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      viewModel.updateApplicationFilterVisible();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: (!viewModel.isApplicationFilterVisible) ? Colors.black : Colors.red,
                          width: 1.0,
                        ),
                        color: Colors.white,
                      ),
                      child: (!viewModel.isApplicationFilterVisible) ? Icon(Icons.filter_alt_outlined) : Icon(Icons.filter_alt_off_outlined, color: Colors.red,),
                    ),
                  ),
                  SizedBox(width: 10,),
                ],
              ),
            ],
          ),
          SizedBox(height: 10,),
          (viewModel.isApplicationFilterVisible)
              ? Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  height: 30,
                  child: Builder(
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: TextField(
                            readOnly: true,
                            textAlign: TextAlign.left,
                            controller: viewModel.application_startDate,
                            decoration: InputDecoration(
                              hintText: 'Ngày bắt đầu',
                              suffixIcon: Icon(Icons.calendar_today, size: 15),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.only(top: 2),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                locale: Locale('vi', 'VN'),
                                context: context,
                                initialDate: viewModel.selectedStartDate_application??DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                viewModel.setSelectedStartDate_application(pickedDate);
                              }
                            },
                          ),
                        );
                      }
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  width: (MediaQuery.of(context).size.width - 40) / 2,
                  height: 30,
                  child: Builder(
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: TextField(
                            readOnly: true,
                            textAlign: TextAlign.left,
                            controller: viewModel.application_endDate,
                            decoration: InputDecoration(
                              hintText: 'Ngày kết thúc',
                              suffixIcon: Icon(Icons.calendar_today, size: 15),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.only(top: 2),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                locale: Locale('vi', 'VN'),
                                context: context,
                                  initialDate: viewModel.selectedEndDate_application??DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                viewModel.setSelectedEndDate_application(pickedDate);
                              }
                            },
                          ),
                        );
                      }
                  ),
                ),
              )
            ],
          )
              : SizedBox.shrink(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2 + 20,
                child: Align(
                  child: (viewModel.applicationStatistics!.total > 0) ? SfCircularChart(
                    margin: EdgeInsets.zero,
                    series: <PieSeries<PieData, String>>[
                      PieSeries<PieData, String>(
                        explode: true,
                        animationDuration: 300,
                        radius: '90%',
                        dataSource: viewModel.application_pieData,
                        xValueMapper: (PieData data, _) => data.xData,
                        yValueMapper: (PieData data, _) => data.yData,
                        dataLabelMapper: (PieData data, _) => data.text,
                        pointColorMapper: (PieData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ) : SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        decoration:
                        BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color(0xfffae600)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          child: Text(
                            "Tổng: ${viewModel.applicationStatistics!.total}",
                            style: TextStyle(fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 17),),
                        )
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: viewModel.application_pieData.map((item) {
                        return Row(
                          children: [
                            Text("●", style: TextStyle(fontSize: 16, color: item.color)),
                            const SizedBox(width: 4),
                            Text("${item.xData}: ${item.yData}"),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
            ],
          ),
          (viewModel.isApplicationFilterVisible)
              ? Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  viewModel.setIsApplicationLoading(true);
                  if (viewModel.selectedStartDate_application == null) {
                    showErrorToastification(title: 'Lỗi', message: 'Vui lòng chọn ngày bắt đầu');
                    viewModel.setIsApplicationLoading(false);
                    return;
                  }
                  if (viewModel.selectedEndDate_application == null) {
                    showErrorToastification(title: 'Lỗi', message: 'Vui lòng chọn ngày kết thúc');
                    viewModel.setIsApplicationLoading(false);
                    return;
                  }
                  await viewModel.getStatistics_application_applyFilter(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xee65c29c),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  minimumSize: Size(0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius
                        .circular(7),
                  ),
                ),
                child: (viewModel.isApplicationLoading) ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white,)) : Text(
                  'Thống kê',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          )
              : SizedBox.shrink(),
        ],
      ),
    ),
  );
}