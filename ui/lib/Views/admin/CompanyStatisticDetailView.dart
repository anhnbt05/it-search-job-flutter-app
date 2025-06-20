import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Constants/color_constants.dart';
import '../../ViewModels/admin/CompanyStatisticDetailViewModel.dart';

class CompanyStatisticDetailScreen extends StatefulWidget {
  const CompanyStatisticDetailScreen({super.key});

  @override
  State<CompanyStatisticDetailScreen> createState() =>
      _CompanyStatisticDetailScreenState();
}

class _CompanyStatisticDetailScreenState
    extends State<CompanyStatisticDetailScreen> {
  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<CompanyStatisticViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: ColorConstants.appbarColor,
        title: Center(
          child: Text(
            'Thông tin bài đăng',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
          ),
        ),
      ),
      body: CompanyDetailBody(context, viewModel),
    );
  }
}

Widget CompanyDetailBody(
  BuildContext context,
  CompanyStatisticViewModel viewModel,
) {
  return Padding(
    padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 10,),
              Container(
                height: 70,
                width: 70,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: (viewModel.company.companyLogoUrl != null)
                    ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Image.network(
                    viewModel.company.companyLogoUrl!,
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
                  children: [
                    Text(viewModel.company.companyName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              )
            ],
          ),
          Column(
            children: [
              SizedBox(height: 15,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 20, color: Colors.black54),
                  SizedBox(width: 5),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Tổng số bài đăng: ',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                        ),
                        TextSpan(
                          text: '${viewModel.company.totalJobs}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.subTextColor,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.star_rate_outlined, size: 20, color: Colors.black54),
                  SizedBox(width: 5),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(text: 'Tỉ lệ chấp nhận ứng viên: ', style: TextStyle(fontFamily: 'Poppins', fontSize: 18)),
                        TextSpan(
                          text: '${(viewModel.company.acceptanceRate * 100).toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.subTextColor,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer_outlined, size: 20, color: Colors.black54),
                    SizedBox(width: 5,),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Vị trí được ứng tuyển nhiều nhất: ',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 5,),
                    SizedBox(width: 5,),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 140,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blue,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        child: Text(
                          viewModel.company.mostAppliedJobTitle,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )

                  ]
              ),
      
            ],
          ),
          SizedBox(height: 40,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thống kê đơn ứng tuyển:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 23,
                  fontWeight: FontWeight.bold
                )
              ),
              SizedBox(height: 10,),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.width / 2,
                        child: (viewModel.company.totalApplications > 0) ? SfCircularChart(
                          margin: EdgeInsets.zero,
                          series: <PieSeries<CompanyChartData, String>>[
                            PieSeries<CompanyChartData, String>(
                              explode: false,
                              animationDuration: 300,
                              radius: '100%',
                              dataSource: viewModel.company_chartData,
                              xValueMapper: (CompanyChartData data, _) => data.xData,
                              yValueMapper: (CompanyChartData data, _) => data.yData,
                              dataLabelMapper: (CompanyChartData data, _) => data.yData == 0 ? null : data.text,
                              pointColorMapper: (CompanyChartData data, _) => data.color,
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
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 20),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  child: Text(
                                    "Tổng: ${viewModel.company.totalApplications}",
                                    style: TextStyle(fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 17),),
                                )
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: viewModel.company_chartData.map((item) {
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
                  SizedBox(height: 40,),
                  Text('Thống kê theo năm', style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Năm: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<int>(
                          isDense: true,
                          value: viewModel.year,
                          items: (viewModel.company.applicationTrendMonthly.isNotEmpty) ? List.generate(
                            DateTime.now().year -
                                viewModel.company.applicationTrendMonthly
                                    .map((e) => int.parse(e.month.split('-')[0]))
                                    .reduce((a, b) => a < b ? a : b) +
                                1,
                                (idx) =>
                            viewModel.company.applicationTrendMonthly
                                .map((e) => int.parse(e.month.split('-')[0]))
                                .reduce((a, b) => a < b ? a : b) +
                                idx,
                          ).map((e) {
                            return DropdownMenuItem<int>(
                              value: e,
                              child: Text(e.toString(), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15)),
                            );
                          }).toList() :
                          [DropdownMenuItem<int>(
                            value: DateTime.now().year,
                            child: Text(DateTime.now().year.toString(), style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),),
                          )],
                          buttonStyleData: ButtonStyleData(
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            elevation: 1,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white
                            ),
                          ),
                          onChanged: (value){
                            viewModel.changeYear(value);
                          },
                          iconStyleData: IconStyleData(
                            icon: Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 10,),
              Column(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.width / 1.5,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(
                            text: 'Tháng',
                            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(
                            text: 'Số lượng',
                            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: false),
                        series: <CartesianSeries<CompanyChartData, String>>[
                          LineSeries<CompanyChartData, String>(
                            dataSource: viewModel.applicationTrendMonthly_chartData,
                            xValueMapper: (CompanyChartData data, _) => data.xData,
                            yValueMapper: (CompanyChartData data, _) => data.yData,
                            dataLabelMapper: (CompanyChartData data, _) =>
                            data.yData == 0 ? null : data.text,
                            pointColorMapper: (CompanyChartData data, _) => data.color,
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                            markerSettings: const MarkerSettings(isVisible: true),
                          )
                        ],
                      )

                  )

                ],
              )
            ],
          ),
        ],
      ),
    ),
  );
}
