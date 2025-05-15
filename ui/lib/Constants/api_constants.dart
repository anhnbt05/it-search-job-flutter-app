import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class APIConstants {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'https://it-searcj-job-app-be.onrender.com';
  static final FlutterSecureStorage storage = const FlutterSecureStorage();
  static final String getCategories_endpoint = 'auth/categories';
  static final String postJob_endpoint = 'jobs';
  static final String deleteJob_endpoint = 'jobs';
  static final String patchJob_endpoint = 'jobs';
  static late final String accessToken;
  static late final String refreshToken;
  static final String getApplications_recruiter_endpoint1 = 'jobs';
  static final String getApplications_recruiter_endpoint2 = 'applications';
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
    return 'jobs/locations/$locationId';
  }
  static String getJobsbyCategories_endpoint(String categoryName) {
    return 'jobs/categories/$categoryName';
  }
}
