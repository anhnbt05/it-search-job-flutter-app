  import 'dart:convert';
import 'dart:io';
  import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
      File? cvFile,
      bool useProfileCV = true,
    }) async {
      try {
        final validToken = await getValidAccessToken(context);
        final request = http.MultipartRequest(
          'POST',
          Uri.parse("${APIConstants.baseUrl}/${APIConstants.postApplication_endpoint}"),
        );
        request.headers['Authorization'] = 'Bearer $validToken';
        request.headers['Accept'] = 'application/json';

        request.fields['JobId'] = jobId;


          if (cvFile != null && cvFile.existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'resumeFile',
                cvFile.path,
                contentType: MediaType('docx', 'pdf'),
              ),
            );
          }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print("📤 [applyForJob] Status code: ${response.statusCode}");
        print("📤 [applyForJob] Raw response body: $responseBody");

        if (response.statusCode == 201 || response.statusCode == 200) {
          showSuccessToastification(
            message: "Ứng tuyển công việc thành công",
            title: "Thành công",
          );
          return true;
        } else {
          final errorMsg = jsonDecode(responseBody)['message'] ??
              "Không thể ứng tuyển. Vui lòng thử lại sau";
          showErrorToastification(
            message: errorMsg,
            title: "Lỗi",
          );
          return false;
        }
      } catch (e) {
        showErrorToastification(
          message: "Có lỗi xảy ra khi ứng tuyển: ${e.toString()}",
          title: "Lỗi",
        );
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
    Future<bool> deleteApplication({
      required BuildContext context,
      required String applicationId,
    }) async {
      try {
        final validToken = await getValidAccessToken(context);
        if (validToken == null) {
          showErrorToastification(
            message: "Không thể xác thực người dùng",
            title: "Lỗi",
          );
          return false;
        }
        final response = await _apiService.deleteApplicationWithToken(
          applicationId: applicationId,
          accessToken: validToken,
        );

        final statusCode = response.statusCode;
        final body = response.body;
        print("📤 [deleteApplication] Status code: $statusCode");
        print("📤 [deleteApplication] Raw response body: $body");

        final decodedData = jsonDecode(body);
        print("📤 [deleteApplication] Decoded data: $decodedData (${decodedData.runtimeType})");

        if (statusCode == 200 || statusCode == 204) {
          showSuccessToastification(
            message: "Đã hủy đơn ứng tuyển thành công",
            title: "Thành công",
          );
          return true;
        } else {
          showErrorToastification(
            message: "Không thể hủy đơn ứng tuyển. Vui lòng thử lại sau",
            title: "Lỗi",
          );
          return false;
        }
      } catch (e) {
        showErrorToastification(
          message: "Lỗi khi xóa đơn ứng tuyển: ${e.toString()}",
          title: "Lỗi",
        );
        return false;
      }
    }
  }