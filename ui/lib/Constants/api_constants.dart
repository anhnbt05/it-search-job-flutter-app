import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Services/auth_refreshtoken_service.dart';
import '../Services/auth_signin_service.dart';

class APIConstants {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  static final AuthSignInService authService = AuthSignInService();
  static final AuthRefreshTokenService refreshTokenService = AuthRefreshTokenService();
  static final FlutterSecureStorage storage = const FlutterSecureStorage();
  static final String getCategories_endpoint = 'auth/categories';
  static final String postJob_endpoint = 'jobs';
  static final String deleteJob_endpoint = 'jobs';
  static final String patchJob_endpoint = 'jobs';
  static late final String accessToken;
  static final String getApplications_recruiter_endpoint1 = 'jobs';
  static final String getApplications_recruiter_endpoint2 = 'applications';
  static final String patchCompany_endpoint = 'companies';
  static final String getJob_endpoint = 'jobs';
  static final String getUser_endpoint = 'users';
  static final String responseJobApplication_endpoint = 'applications/process';
  static String getRecommendedJobs_candidate_endpoint(String candidateId) {
    return 'jobs/candidates/$candidateId/recommended-jobs';
  }
  static String getDetailJob_candidate_endpoint(String jobId) {
    return 'jobs/$jobId';
  }
  static final String FavoritesJobs_endpoint = 'jobs/candidates/favorites';
  static String getJobsbyLocations_endpoint(String locationId) {
    return 'jobs/?locationId=$locationId';
  }
  static String getJobsbyCategories_endpoint(List<String> categoryNames) {
    final query = categoryNames.map((e) => 'categoryNames=${Uri.encodeComponent(e)}').join('&');
    return 'jobs/?$query';
  }
  static String getJobsbyBothLocationCategory_endpoint(String locationId, List<String> categoryNames)
  {
    final query1 = 'locationId=$locationId';
    final query2 = categoryNames.map((e) => 'categoryNames=${Uri.encodeComponent(e)}').join('&');
    return 'jobs/?$query1&$query2';
  }
  static final String postApplication_endpoint = 'applications';
  static final String getApplication_endpoint = 'applications';
  static String getDetailApplication_candidate_endpoint(String applicationId) {
    return 'applications/$applicationId';
  }
  static String deleteApplication_candidate_endpoint(String applicationId) {
    return 'applications/$applicationId';
  }
  static final String patchJob_admin_endpoint = 'jobs/process/status';

  static String getProfile_candidate_endpoint(String Id) {
    return 'users/$Id';
  }
  static final String WorkExperiences_endpoint = 'work-experiences';

  static final String getUser_admin_endpoint = 'users';
  static final String deleteUser_endpoint = 'users';
  static final String postCategory_endpoint = 'auth/categories';

  static final getStatistic_endpoint = "dashboards/summary";
  static final getCompanyStatistic_endpoint = "dashboards/summary/companies";
  static final postSummaryReport_endpoint = "dashboards/summary/companies/report";
}
