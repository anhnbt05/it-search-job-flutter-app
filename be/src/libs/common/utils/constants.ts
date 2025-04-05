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

export const excludes = [
  '/auth/sign-in',
  '/auth/sign-up',
  '/auth/refresh-token',
  '/auth/verify-email',
  '/auth/provinces',
  '/auth/companies',
  '/auth/forget-password',
  '/auth/reset-password',
  '/auth/verify-reset-password-otp',
  '/auth/update-password',
  '/auth/companies/:companyId/branches',
  '/',
];

export const SUBJECT_EMAIL_MAP = {
  'email-verification': 'Email Verification',
  'email-reset-password': 'Email Reset Password',
  'email-update-password-success': 'Email Reset Password Successful',
  'email-register-account-success': 'Email Registration Successful',
};

export const BULLMQ_RETRY_LIMIT = 3;
export const BULLMQ_RETRY_DELAY = 5000;
export const DEFAULT_MAX_ATTEMPTS = 5;
export const DEFAULT_TTL_OTP_EXPIRED = 600000;
export const DEFAULT_VERIFIED_OTP_RESET_PASSWORD = 600000;
export const DEFAULT_TTL_PROVINCES_CACHE = 600000;
export const HTTP_MODULE_TIMEOUT = 5000;
export const HTTP_MODULE_MAX_REDIRECT = 5;
export const API_END_POINTS_PROVINCES = 'https://provinces.open-api.vn/api/p';
