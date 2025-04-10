export enum RoleEnum {
  CANDIDATE = 'candidate',
  ADMIN = 'admin',
  RECRUITER = 'recruiter',
}

export enum LevelEnum {
  INTERN = 'intern',
  FRESHER = 'fresher',
  MID = 'mid',
  JUNIOR = 'junior',
  SENIOR = 'senior',
}

export enum EmailTemplateNameEnum {
  EMAIL_VERIFICATION = 'email-verification',
  EMAIL_RESET_PASSWORD = 'email-reset-password',
  EMAIL_UPDATE_PASSWORD_SUCCESS = 'email-update-password-success',
  EMAIL_REGISTER_ACCOUNT_SUCCESS = 'email-register-account-success',
  EMAIL_APPLICATION_APPROVED = 'email-application-approved',
  EMAIL_APPLICATION_REJECTED = 'email-application-rejected',
  EMAIL_REPORT = 'email-report',
}

export type SupabaseUserToken = {
  id: string;
  aud: string;
  role: string;
  email: string;
  email_confirmed_at: string;
  phone: string;
  confirmed_at: string;
  last_sign_in_at: string;
  app_metadata: {
    provider: string;
    providers: string[];
    role: string;
  };
  user_metadata: {
    email?: string;
    email_verified?: boolean;
    phone_verified?: boolean;
    sub?: string;
  };
  identities: {
    identity_id: string;
    id: string;
    user_id: string;
    identity_data: {
      email: string;
      email_verified: boolean;
      phone_verified: boolean;
      sub: string;
    };
    provider: string;
    last_sign_in_at: string;
    created_at: string;
    updated_at: string;
    email: string;
  }[];
  created_at: string;
  updated_at: string;
  is_anonymous: boolean;
};

export type Province = {
  name: string;
  code: number;
  division_type: string;
  codename: string;
  phone_code: number;
  districts: string[];
};

export const SUBJECT_EMAIL_MAP = {
  'email-verification': 'Xác Minh Email',
  'email-reset-password': 'Đặt Lại Mật Khẩu',
  'email-update-password-success': 'Đổi Mật Khẩu Thành Công',
  'email-register-account-success': 'Đăng Ký Tài Khoản Thành Công',
  'email-application-approved': 'Hồ Sơ Ứng Tuyển Được Chấp Thuận',
  'email-application-rejected': 'Hồ Sơ Ứng Tuyển Bị Từ Chối',
  'email-report': 'Báo Cáo Tổng Quan Việc Làm',
};

export type AdminNewJobPostMetadata = RecruiterJobApprovedMetadata & {
  recruiterId: string;
  companyName: string;
};

export type CandidateApplicationApprovedMetadata =
  RecruiterJobApprovedMetadata & {
    recruiterId: string;
    companyName: string;
    applicationId: string;
  };

export type CandidateApplicationRejectedMetadata =
  CandidateApplicationApprovedMetadata & {
    reason?: string;
  };

export type RecruiterJobApprovedMetadata = {
  jobId: string;
  jobTitle: string;
};

export type RecruiterJobRejectedMetadata = RecruiterJobApprovedMetadata & {
  reason?: string;
};

export type RecruiterNewApplicationMetadata = RecruiterJobApprovedMetadata & {
  candidateId: string;
  candidateName: string;
  applicationId: string;
};

export enum ReportType {
  PDF = 'pdf',
  EXCEL = 'xlsx',
}

export enum API_TAGS {
  AUTH = 'Xác thực',
  JOB = 'Công việc',
  USER = 'Người dùng',
  WORK_EXPERIENCE = 'Kinh nghiệm làm việc',
  COMPANY = 'Công ty',
  APPLICATION = 'Đơn ứng tuyển',
  DASHBOARD = 'Bảng điều khiển',
  APP = 'Ứng dụng gốc',
}

export const BULLMQ_RETRY_LIMIT = 3;
export const BULLMQ_RETRY_DELAY = 5000;
export const DEFAULT_MAX_ATTEMPTS = 5;
export const DEFAULT_TTL_OTP_EXPIRED = 600000;
export const DEFAULT_VERIFIED_OTP_RESET_PASSWORD = 600000;
export const DEFAULT_TTL_PROVINCES_CACHE = 600000;
export const HTTP_MODULE_TIMEOUT = 5000;
export const HTTP_MODULE_MAX_REDIRECT = 5;
export const API_END_POINTS_PROVINCES = 'https://provinces.open-api.vn/api/p';
export const DEFAULT_TTL_SUMMARY_CACHED = 600000;
export const REPORT_FILE_NAME = 'tong-quan-cong-ty';
export const TITLE_REPORT = 'Báo cáo thống kê tuyển dụng theo công ty';
export const REPORT_FLOW_PRODUCER = 'reportFlowProducer';
export const UPLOAD_REPORT_QUEUE_NAME = 'upload-report-queue';
export const GENERATE_REPORT_QUEUE_NAME = 'generate-report-queue';
export const EMAIL_QUEUE_NAME = 'emails-queue';
