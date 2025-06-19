import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Helpers/toastification.dart';
import '../../ViewModels/admin/CompanyStatisticDetailViewModel.dart';
import '../../ViewModels/admin/StatisticsViewModel.dart';
import 'CompanyStatisticDetailView.dart';

Widget StatisticsScreen(BuildContext context) {
  var viewModel = Provider.of<StatisticsViewModel>(context);
  if (viewModel.statistics == null || viewModel.companyStatistics == null) {
    return FutureBuilder(
      future: Future.wait([
        viewModel.statisticsF,
        viewModel.companyStatisticsF,
      ]),
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
      SizedBox(height: 5,),
      companyStatistics(viewModel: viewModel, context: context),
      SizedBox(height: 5,),
      jobStatistics(viewModel: viewModel, context: context),
      SizedBox(height: 5,),
      applicationStatistics(viewModel: viewModel, context: context),
      SizedBox(height: 5,),
      userStatistics(viewModel: viewModel, context: context),
    ],
  );
}

companyStatistics({required StatisticsViewModel viewModel, required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(padding: const EdgeInsets.only(top: 5, left: 7), child: Text("Thống kê công ty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            )
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: (){
                    viewModel.updateCompanyFilterVisible();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: (!viewModel.isCompanyFilterVisible) ? Colors.black : Colors.red,
                        width: 1.0,
                      ),
                      color: Colors.white,
                    ),
                    child: (!viewModel.isCompanyFilterVisible) ? Icon(Icons.filter_alt_outlined) : Icon(Icons.filter_alt_off_outlined, color: Colors.red,),
                  ),
                ),
                SizedBox(width: 10,),
              ],
            ),
          ],
        ),
        SizedBox(height: 10,),
        (viewModel.isCompanyFilterVisible)
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
                          controller: viewModel.company_startDate,
                          decoration: InputDecoration(
                            hintText: 'Từ',
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
                              initialDate: viewModel.selectedStartDate_company??DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              viewModel.setSelectedStartDate_company(pickedDate);
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
                          controller: viewModel.company_endDate,
                          decoration: InputDecoration(
                            hintText: 'Đến',
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
                              initialDate: viewModel.selectedEndDate_company??DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              viewModel.setSelectedEndDate_company(pickedDate);
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
        (viewModel.isCompanyFilterVisible) ? SizedBox(height: 8,) : SizedBox.shrink(),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3 + 30,
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: viewModel.companyStatistics!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => CompanyStatisticViewModel(company: viewModel.companyStatistics![index], context: context),
                            child: CompanyStatisticDetailScreen(),
                          ),
                        ),
                      );
                    },
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
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 60,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        "${index + 1}.",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Container(
                                    height: 65,
                                    width: 65,
                                    margin: EdgeInsets.only(right: 10),
                                    child: (viewModel.companyStatistics![index]
                                        .companyLogoUrl != null)
                                        ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Image.network(
                                        viewModel.companyStatistics![index].companyLogoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            color: Colors.grey.shade50,
                                            child: Icon(
                                                Icons.broken_image, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    )
                                        : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Icon(Icons.business, color: Colors.grey),
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(viewModel.companyStatistics![index].companyName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.bar_chart, color: Colors.green, size: 15,),
                                            SizedBox(width: 2,),
                                            Text("Số bài đăng: ${viewModel.companyStatistics![index].totalAcceptedApplications} bài",),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 5,),
                              SizedBox(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 13, color: Colors.black),
                                      children: [
                                        TextSpan(text: "Tỉ lệ chấp nhận: ", style: TextStyle(fontFamily: "Poppins")),
                                        TextSpan(
                                          text:
                                          "${(viewModel.companyStatistics![index].acceptanceRate * 100).toStringAsFixed(2)}%",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                            fontFamily: "Poppins"
                                          ),
                                        ),
                                      ],
                                    ),
                                  )

                                ),
                              )
                            ],
                          )
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        (viewModel.isCompanyFilterVisible)
            ? Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                viewModel.setIsCompanyLoading(true);
                if (viewModel.selectedStartDate_company == null) {
                  showErrorToastification(title: 'Lỗi', message: 'Vui lòng chọn ngày bắt đầu');
                  viewModel.setIsCompanyLoading(false);
                  return;
                }
                if (viewModel.selectedEndDate_company == null) {
                  showErrorToastification(title: 'Lỗi', message: 'Vui lòng chọn ngày kết thúc');
                  viewModel.setIsCompanyLoading(false);
                  return;
                }
                await viewModel.getStatistics_company_applyFilter(context);
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
              child: (viewModel.isCompanyLoading) ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white,)) : Text(
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
                            hintText: 'Từ',
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
                              hintText: 'Đến',
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
                    series: <PieSeries<ChartData, String>>[
                      PieSeries<ChartData, String>(
                        explode: true,
                        animationDuration: 300,
                        radius: '90%',
                        dataSource: viewModel.job_chartData,
                        xValueMapper: (ChartData data, _) => data.xData,
                        yValueMapper: (ChartData data, _) => data.yData,
                        dataLabelMapper: (ChartData data, _) => (data.yData == 0) ? null : data.text,
                        pointColorMapper: (ChartData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ) : Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.width / 2.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.5,
                          )
                        ),
                        child: Center(
                          child: Text(
                            'Không có\nbài tuyển dụng',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ),
                  ),
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
                      children: viewModel.job_chartData.map((item) {
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
                              hintText: 'Từ',
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
                              hintText: 'Đến',
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
                    series: <PieSeries<ChartData, String>>[
                      PieSeries<ChartData, String>(
                        explode: true,
                        animationDuration: 300,
                        radius: '90%',
                        dataSource: viewModel.application_chartData,
                        xValueMapper: (ChartData data, _) => data.xData,
                        yValueMapper: (ChartData data, _) => data.yData,
                        dataLabelMapper: (ChartData data, _) => (data.yData == 0) ? null : data.text,
                        pointColorMapper: (ChartData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ) : Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      height: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.5,
                          )
                      ),
                      child: Center(
                        child: Text(
                          'Không có\nđơn ứng tuyển',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
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
                      children: viewModel.application_chartData.map((item) {
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

Widget userStatistics({required StatisticsViewModel viewModel, required BuildContext context}) {
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
              Padding(padding: const EdgeInsets.only(top: 5, left: 7), child: Text("Thống kê người dùng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      viewModel.updateUserFilterVisible();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: (!viewModel.isUserFilterVisible) ? Colors.black : Colors.red,
                          width: 1.0,
                        ),
                        color: Colors.white,
                      ),
                      child: (!viewModel.isUserFilterVisible) ? Icon(Icons.filter_alt_outlined) : Icon(Icons.filter_alt_off_outlined, color: Colors.red,),
                    ),
                  ),
                  SizedBox(width: 10,),
                ],
              ),
            ],
          ),
          SizedBox(height: 10,),
          (viewModel.isUserFilterVisible)
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
                            controller: viewModel.user_startDate,
                            decoration: InputDecoration(
                              hintText: 'Từ',
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
                                initialDate: viewModel.selectedStartDate_user??DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                viewModel.setSelectedStartDate_user(pickedDate);
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
                            controller: viewModel.user_endDate,
                            decoration: InputDecoration(
                              hintText: 'Đến',
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
                                initialDate: viewModel.selectedEndDate_user??DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                viewModel.setSelectedEndDate_user(pickedDate);
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
          (viewModel.isUserFilterVisible) ? SizedBox(height: 20,) : SizedBox(height: 15,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2 + 20,
                child: Align(
                  child: (viewModel.userStatistics!.total > 0) ? SfCartesianChart(
                    margin: EdgeInsets.zero,
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries<ChartData, String>>[
                      ColumnSeries<ChartData, String>(
                        dataSource: viewModel.user_chartData,
                        animationDuration: 300,
                        xValueMapper: (ChartData data, _) => data.xData,
                        yValueMapper: (ChartData data, _) => data.yData,
                        pointColorMapper: (ChartData data, _) => data.color,
                        dataLabelMapper: (ChartData data, _) => (data.yData == 0) ? null : data.text,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      )
                    ],
                  )
                      : Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.width / 2.5,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.5,
                            )
                        ),
                        child: Center(
                          child: Text(
                            'Không có\nngười dùng',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ),
                  ),
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
                            color: Color(0xffffa11d)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          child: Text(
                            "Tổng: ${viewModel.userStatistics!.total}",
                            style: TextStyle(fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 17),),
                        )
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: viewModel.userStatus_chartData.map((item) {
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
          (viewModel.isUserFilterVisible)
              ? Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  viewModel.setIsUserLoading(true);
                  if (viewModel.selectedStartDate_user == null) {
                    showErrorToastification(title: 'Lỗi', message: 'Vui lòng chọn ngày bắt đầu');
                    viewModel.setIsUserLoading(false);
                    return;
                  }
                  if (viewModel.selectedEndDate_user == null) {
                    showErrorToastification(title: 'Lỗi', message: 'Vui lòng chọn ngày kết thúc');
                    viewModel.setIsUserLoading(false);
                    return;
                  }
                  await viewModel.getStatistics_user_applyFilter(context);
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
                child: (viewModel.isUserLoading) ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white,)) : Text(
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