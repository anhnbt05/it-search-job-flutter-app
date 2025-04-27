import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class APIConstants {
  static final String baseUrl = 'https://it-searcj-job-app-be.onrender.com';
  static final String getCategories_endpoint = 'auth/categories';
  static final String postJob_endpoint = 'jobs';
  static final String token = "...";
  static final String userId = JwtDecoder.decode(token)["sub"] as String;
  static final String getApplications_recruiter_endpoint1 = 'jobs';
  static final String getApplications_recruiter_endpoint2 = 'applications';
  static final String getJob_endpoint = 'jobs';
  static final String getUser_endpoint = 'users';
  static final String responseJobApplication_endpoint = 'applications/process';
}