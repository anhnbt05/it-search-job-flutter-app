import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ui/Models/Statistics.dart';
import 'package:ui/Services/api_service.dart';

import '../Constants/api_constants.dart';
import '../Helpers/helpers.dart';
import '../Models/ResponseModel.dart';

Future<ResponseModel> getStatistic(BuildContext context)  async {
  final validToken = await getValidAccessToken(context);
  final response = await ApiService().getWithToken(endpoint: APIConstants.getStatistic_endpoint, accessToken: validToken??'');
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    cJobStatistics jobStatistics = cJobStatistics.fromJson(data['jobStats']);
    cApplicationStatistics applicationStatistics = cApplicationStatistics.fromJson(data['applicationStats']);
    cUserStatistics userStatistics = cUserStatistics.fromJson(data['userStats']);
    cStatistics statistics = cStatistics(jobStatistics: jobStatistics, applicationStatistics: applicationStatistics, userStatistics: userStatistics);
    return ResponseModel(data: statistics, success: true, message: '', messageList: []);
  }
  return ResponseModel(data: null, success: false, message: json.decode(response.body)['message'], messageList: [json.decode(response.body)['message']]);
}

Future<ResponseModel> getStatistic_filter(BuildContext context, DateTime startDate, DateTime endDate)  async {
  final validToken = await getValidAccessToken(context);
  final response = await ApiService().getWithToken(endpoint: "${APIConstants.getStatistic_endpoint}"
      "?StartDate=${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}"
      "&EndDate=${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}", accessToken: validToken??'');
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    cJobStatistics jobStatistics = cJobStatistics.fromJson(data['jobStats']);
    cApplicationStatistics applicationStatistics = cApplicationStatistics.fromJson(data['applicationStats']);
    cUserStatistics userStatistics = cUserStatistics.fromJson(data['userStats']);
    cStatistics statistics = cStatistics(jobStatistics: jobStatistics, applicationStatistics: applicationStatistics, userStatistics: userStatistics);
    return ResponseModel(data: statistics, success: true, message: '', messageList: []);
  }
  return ResponseModel(data: null, success: false, message: json.decode(response.body)['message'], messageList: [json.decode(response.body)['message']]);
}

Future<ResponseModel> getCompanyStatistic(BuildContext context) async {
  final validToken = await getValidAccessToken(context);
  final response = await ApiService().getWithToken(
    endpoint: APIConstants.getCompanyStatistic_endpoint,
    accessToken: validToken ?? '',
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<cCompanyStatistics> companyStatistics = data
        .map((jsonItem) => cCompanyStatistics.fromJson(jsonItem))
        .toList();
    return ResponseModel(
      data: companyStatistics,
      success: true,
      message: '',
      messageList: [],
    );
  }

  final errorMsg = json.decode(response.body)['message'];
  return ResponseModel(
    data: null,
    success: false,
    message: errorMsg,
    messageList: [errorMsg],
  );
}

Future<ResponseModel> getCompanyStatistic_filter(BuildContext context, DateTime startDate, DateTime endDate) async {
  final validToken = await getValidAccessToken(context);
  final response = await ApiService().getWithToken(
    endpoint: "${APIConstants.getCompanyStatistic_endpoint}"
        "?StartDate=${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}"
        "&EndDate=${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    accessToken: validToken ?? '',
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<cCompanyStatistics> companyStatistics = data
        .map((jsonItem) => cCompanyStatistics.fromJson(jsonItem))
        .toList();
    return ResponseModel(
      data: companyStatistics,
      success: true,
      message: '',
      messageList: [],
    );
  }

  final errorMsg = json.decode(response.body)['message'];
  return ResponseModel(
    data: null,
    success: false,
    message: errorMsg,
    messageList: [errorMsg],
  );
}