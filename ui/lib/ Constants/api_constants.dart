import 'package:flutter/material.dart';

class APIConstants {
  static final String baseUrl = 'https://it-searcj-job-app-be.onrender.com';
  static final String getCategories_endpoint = 'auth/categories';
  static final String postJob_endpoint = 'jobs';
  static final String token = "...";
  static final String getApplications_recruiter_endpoint1 = 'jobs';
  static final String getApplications_recruiter_endpoint2 = 'applications';
  static final String getJob_endpoint = 'jobs';
  static final String responseJobApplication_endpoint = 'applications/process';
  static final Color successColor_toast = Colors.green;
  static final Color errorColor_toast = Colors.red;
}