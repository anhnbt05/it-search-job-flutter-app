import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class APIConstants {
  static final String baseUrl = 'https://it-searcj-job-app-be.onrender.com';
  static final String getCategories_endpoint = 'auth/categories';
  static final String postJob_endpoint = 'jobs';
  static final String token = "eyJhbGciOiJIUzI1NiIsImtpZCI6ImVJclVSTTROUldPb3FDS2UiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3F3aWxkZGFxbnJ6bnFiaHVza3p4LnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI2NzRjNzIwNC0xMDZlLTRkN2YtOGRjMy0zZjYzODlkMGFhOGUiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzQ1NzQxNzAyLCJpYXQiOjE3NDU3MzgxMDIsImVtYWlsIjoibGVuZ29jYW5ocHluZTM2M0BnbWFpbC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl0sInJvbGUiOiJyZWNydWl0ZXIifSwidXNlcl9tZXRhZGF0YSI6eyJlbWFpbCI6ImxlbmdvY2FuaHB5bmUzNjNAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInBob25lX3ZlcmlmaWVkIjpmYWxzZSwic3ViIjoiNjc0YzcyMDQtMTA2ZS00ZDdmLThkYzMtM2Y2Mzg5ZDBhYThlIn0sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3NDU3MzgxMDJ9XSwic2Vzc2lvbl9pZCI6IjkxNWFhMzE4LTQ2MjQtNGVmZS04YTNiLThjZGMwN2M2M2RjMiIsImlzX2Fub255bW91cyI6ZmFsc2V9.qtj6xrpjJ_eF2-CZn15dcrKnrnxPLtGBTsb-_9KfezY";
  static final String userId = JwtDecoder.decode(token)["sub"] as String;
  static final String getApplications_recruiter_endpoint1 = 'jobs';
  static final String getApplications_recruiter_endpoint2 = 'applications';
  static final String getJob_endpoint = 'jobs';
  static final String getUser_endpoint = 'users';
  static final String responseJobApplication_endpoint = 'applications/process';
}