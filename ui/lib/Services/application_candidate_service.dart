  import 'dart:convert';
  import 'package:flutter/cupertino.dart';
import 'package:ui/Helpers/toastification.dart';
  import 'package:ui/Constants/api_constants.dart';
  import '../Helpers/helpers.dart';
import '../Models/Applications.dart';
  import 'api_service.dart';

  class ApplicationCandidateService {
    final ApiService _apiService = ApiService();

    Future<bool> applyForJob({
      required BuildContext context,
      required String jobId,
    }) async {
      try {
        final validToken = await getValidAccessToken(context);
        final response = await _apiService.postWithToken(
          endpoint: APIConstants.postApplication_endpoint,
          body: {
            "JobId": jobId,
          },
          accessToken: validToken!,
        );

        final statusCode = response.statusCode;
        final body = response.body;
        print("📤 [applyForJob] Status code: $statusCode");
        print("📤 [applyForJob] Raw response body: $body");


        String extractMessage(dynamic data, {bool isSuccess = true}) {
          if (data is Map<String, dynamic> && data.containsKey('message')) {
            return data['message'].toString();
          } else if (data is List && data.isNotEmpty) {
            return data.first.toString();
          } else if (data is String) {
            return data;
          } else {
            return isSuccess ? 'Đã ứng tuyển thành công.' : 'Đã xảy ra lỗi.';
          }
        }

        final decodedData = jsonDecode(body);
        print("📤 [applyForJob] Decoded data: $decodedData (${decodedData.runtimeType})");
        if (statusCode == 201 || statusCode == 200) {
          showSuccessToastification(
            message: extractMessage(decodedData, isSuccess: true),
            title: "Thành công",
          );
          return true;
        } else {
          showErrorToastification(
            message: extractMessage(decodedData, isSuccess: false),
            title: "Lỗi",
          );
          return false;
        }
      } catch (e) {
        showErrorToastification(message: e.toString(), title: "Lỗi");
        return false;
      }
    }

    Future<List<cApplications_candidate>?> getApplicationsForCandidate({
      required BuildContext context,
    }) async {
      try {
        final validToken = await getValidAccessToken(context);
        final response = await _apiService.getWithToken(
          endpoint: APIConstants.getApplication_endpoint,
          accessToken: validToken!,
        );

        if (response.statusCode == 200) {
          print("Successfully fetched applications list.");
          final decoded = jsonDecode(response.body);
          print("Decoded data: $decoded (${decoded.runtimeType})");

          if (decoded is List) {
            final result = <cApplications_candidate>[];

            for (var e in decoded) {
              if (e != null && e is Map<String, dynamic>) {
                result.add(cApplications_candidate.fromJson(e));
              } else {
                print("Skipped invalid item: $e");
              }
            }

            result.sort((a, b) => b.AppliedAt.compareTo(a.AppliedAt));
            return result;
          } else {
            print("Expected a list but got: $decoded");
            return null;
          }
        } else {
          print("Failed to fetch applications list: ${response.body}");
          return null;
        }
      } catch (e) {
        print("Error fetching applications list: $e");
        return null;
      }
    }


    Future<List<cApplications_candidate>?> getDetailApplicationForCandidate({
      required String applicationID,
      required BuildContext context,
    }) async {
      try {
        final validToken = await getValidAccessToken(context);
        final response = await _apiService.getWithToken(
          endpoint: APIConstants.getDetailApplication_candidate_endpoint(
              applicationID),
          accessToken: validToken!,
        );

        if (response.statusCode == 200) {
          print("Successfully fetched application detail.");
          final decoded = jsonDecode(response.body);
          print("Decoded data: $decoded (${decoded.runtimeType})");
          if (decoded is List) {
            final result = <cApplications_candidate>[];

            for (var e in decoded) {
              if (e != null && e is Map<String, dynamic>) {
                result.add(cApplications_candidate.fromJson(e));
              } else {
                print("Skipped invalid item: $e");
              }
            }

            result.sort((a, b) => b.AppliedAt.compareTo(a.AppliedAt));
            return result;
          } else {
            print("Expected a list but got: $decoded");
            return null;
          }
        } else {
          print("Failed to fetch application detail: ${response.body}");
          return null;
        }
      } catch (e) {
        print("Error fetching application detail: $e");
        return null;
      }
    }
  }